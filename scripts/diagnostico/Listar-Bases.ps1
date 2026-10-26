<#
.SYNOPSIS
  Lista SOLO los nombres, estado y nivel de compatibilidad de las bases de UNA instancia que usted indique (SOLO LECTURA).
  Usa las mismas variables que Invoke-AuditoriaSql.ps1: CONTPAQ_SQL_SERVER, CONTPAQ_SQL_USER, CONTPAQ_SQL_PASSWORD.
  Se conecta a 'master' y ejecuta una sola consulta SELECT sobre sys.databases. No imprime la contraseña.
#>
[CmdletBinding()]
param([switch]$ConfiarCertificado)
$ErrorActionPreference = 'Stop'
foreach ($n in 'CONTPAQ_SQL_SERVER', 'CONTPAQ_SQL_USER', 'CONTPAQ_SQL_PASSWORD') {
    if (-not [Environment]::GetEnvironmentVariable($n)) { throw "Falta la variable de entorno $n. No se hace ninguna conexión." }
}
$sb = New-Object System.Data.SqlClient.SqlConnectionStringBuilder
$sb['Data Source'] = $env:CONTPAQ_SQL_SERVER
$sb['Initial Catalog'] = 'master'
$sb['User ID'] = $env:CONTPAQ_SQL_USER
$sb['Password'] = $env:CONTPAQ_SQL_PASSWORD
$sb['ApplicationIntent'] = 'ReadOnly'
$sb['Application Name'] = 'ListarBasesSoloLectura'
$sb['Connect Timeout'] = 15
$sb['Encrypt'] = $true
$sb['TrustServerCertificate'] = [bool]$ConfiarCertificado
$cn = New-Object System.Data.SqlClient.SqlConnection($sb.ConnectionString)
try {
    $cn.Open()
    $cmd = $cn.CreateCommand(); $cmd.CommandTimeout = 30
    $cmd.CommandText = "SELECT name, state_desc, compatibility_level, create_date FROM sys.databases ORDER BY name"
    $dt = New-Object System.Data.DataTable
    (New-Object System.Data.SqlClient.SqlDataAdapter($cmd)).Fill($dt) | Out-Null
    $dt | Format-Table name, state_desc, compatibility_level, create_date -AutoSize
}
finally { $cn.Dispose() }
