<#
.SYNOPSIS
  Auditoría de SOLO LECTURA de metadatos de una base de datos (por defecto SONARMANDO).
.DESCRIPTION
  Ejecuta únicamente los .sql de la carpeta .\sql y guarda cada resultado como CSV en .\salida (ignorada por git).
  Configuración exclusivamente por variables de entorno (falla si falta alguna):
    CONTPAQ_SQL_SERVER    p. ej. EQUIPO\INSTANCIA  (no se adivina ni se escanea)
    CONTPAQ_SQL_USER      usuario (se acordó 'sa')
    CONTPAQ_SQL_PASSWORD  contraseña (nunca se imprime ni se guarda)
    CONTPAQ_SQL_DATABASE  opcional, por defecto SONARMANDO
  Salvaguardas: rechaza cualquier script con palabras de escritura/ejecución, abre la conexión con
  ApplicationIntent=ReadOnly, TrustServerCertificate solo con -ConfiarCertificado, timeout de comando de 60 s,
  y envuelve todo en una transacción que siempre se revierte.
  No lee datos de negocio: los scripts consultan sys.* únicamente.
.EXAMPLE
  $env:CONTPAQ_SQL_SERVER='EQUIPO\INSTANCIA'; $env:CONTPAQ_SQL_USER='sa'
  $env:CONTPAQ_SQL_PASSWORD = Read-Host -AsSecureString | ConvertFrom-SecureString -AsPlainText   # pwsh 7
  .\Invoke-AuditoriaSql.ps1
#>
[CmdletBinding()]
param([switch]$ConfiarCertificado)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

foreach ($n in 'CONTPAQ_SQL_SERVER', 'CONTPAQ_SQL_USER', 'CONTPAQ_SQL_PASSWORD') {
    if (-not [Environment]::GetEnvironmentVariable($n)) { throw "Falta la variable de entorno $n. No se hace ninguna conexión." }
}
$db = if ($env:CONTPAQ_SQL_DATABASE) { $env:CONTPAQ_SQL_DATABASE } else { 'SONARMANDO' }
$prohibido = '\b(INSERT|UPDATE|DELETE|MERGE|DROP|ALTER|CREATE|TRUNCATE|EXEC|EXECUTE|GRANT|REVOKE|DENY|BACKUP|RESTORE|DBCC|SHUTDOWN|RECONFIGURE|OPENROWSET|OPENQUERY|OPENDATASOURCE|xp_\w+|sp_\w+|INTO\s+#?\w+)\b'

$sb = New-Object System.Data.SqlClient.SqlConnectionStringBuilder
$sb['Data Source'] = $env:CONTPAQ_SQL_SERVER
$sb['Initial Catalog'] = $db
$sb['User ID'] = $env:CONTPAQ_SQL_USER
$sb['Password'] = $env:CONTPAQ_SQL_PASSWORD
$sb['ApplicationIntent'] = 'ReadOnly'
$sb['Application Name'] = 'AuditoriaSoloLectura'
$sb['Connect Timeout'] = 15
$sb['Encrypt'] = $true
$sb['TrustServerCertificate'] = [bool]$ConfiarCertificado

$salida = Join-Path $PSScriptRoot 'salida'
New-Item -ItemType Directory -Force -Path $salida | Out-Null
$archivos = Get-ChildItem (Join-Path $PSScriptRoot 'sql') -Filter *.sql | Sort-Object Name

# Validar TODOS los scripts antes de abrir la conexión.
foreach ($f in $archivos) {
    $sinComentarios = (Get-Content $f.FullName -Raw) -replace '--.*', ''
    if ($sinComentarios -match $prohibido) { throw "Script rechazado por contener operaciones no permitidas: $($f.Name)" }
}

$tx = $null
$cn = New-Object System.Data.SqlClient.SqlConnection($sb.ConnectionString)
try {
    $cn.Open()
    $tx = $cn.BeginTransaction([System.Data.IsolationLevel]::ReadUncommitted)
    foreach ($f in $archivos) {
        $cmd = $cn.CreateCommand(); $cmd.Transaction = $tx; $cmd.CommandTimeout = 60
        $cmd.CommandText = Get-Content $f.FullName -Raw
        $ds = New-Object System.Data.DataSet
        (New-Object System.Data.SqlClient.SqlDataAdapter($cmd)).Fill($ds) | Out-Null
        $i = 0
        foreach ($t in $ds.Tables) {
            $i++
            $dest = Join-Path $salida ("{0}_{1}.csv" -f $f.BaseName, $i)
            $t | Export-Csv -Path $dest -NoTypeInformation -Encoding UTF8
            Write-Host ("{0}: {1} filas -> {2}" -f $f.Name, $t.Rows.Count, (Split-Path $dest -Leaf))
        }
    }
}
finally {
    if ($tx) { $tx.Rollback() }
    $cn.Dispose()
}
Write-Host "Listo. Revise .\salida antes de compartirla (solo metadatos; no debe contener datos personales)."
