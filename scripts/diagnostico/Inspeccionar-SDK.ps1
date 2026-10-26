<#
.SYNOPSIS
  Inspección de SOLO LECTURA del SDK instalado de CONTPAQi Comercial Start/Pro, servicios locales e instancias SQL locales.
  No carga ni ejecuta DLL de CONTPAQi, no se conecta a ninguna base y no imprime secretos.
  Escribe .\salida\sdk.txt
#>
param([string]$Carpeta = 'C:\Program Files (x86)\Compac\ComercialSP')
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib\Pe.ps1')
$salida = Join-Path $PSScriptRoot 'salida'; New-Item -ItemType Directory -Force -Path $salida | Out-Null
$o = New-Object System.Collections.Generic.List[string]
$sensible = 'pass|pwd|secret|token|key|clave|connection|cadena|credential'

$o.Add("== DLL/TLB del SDK en $Carpeta (cabeceras PE) ==")
if (Test-Path $Carpeta) {
    Get-ChildItem $Carpeta -File | Where-Object { $_.Name -match '^(SDK|AxInterop|Interop|LC\.|XEngine).*\.(dll|exe)$' } | ForEach-Object {
        $i = Get-PeInfo $_.FullName
        $o.Add(("{0} | v{1} | {2} | gestionado={3} | requiere32bits={4} | exportaciones={5}" -f $_.Name, $_.VersionInfo.FileVersion, $i.Arquitectura, $i.Gestionado, $i.Requiere32Bits, @($i.Exportaciones).Count))
        if ($i.Gestionado) {
            try { $n = [Reflection.AssemblyName]::GetAssemblyName($_.FullName); $o.Add(("    ensamblado: {0} {1} arq={2}" -f $n.Name, $n.Version, $n.ProcessorArchitecture)) } catch { $o.Add('    (no se pudo leer el manifiesto)') }
        }
        foreach ($x in $i.Exportaciones) { $o.Add("    export: $x") }
    }
} else { $o.Add("No existe $Carpeta") }

$ws = Join-Path $Carpeta 'ComercialSPWorkerService'
$o.Add("== Carpeta del servicio ComercialSPWorkerService: archivos (solo nombres) ==")
if (Test-Path $ws) {
    Get-ChildItem $ws -File | Select-Object -First 60 | ForEach-Object { $o.Add($_.Name) }
    $o.Add("== Claves de configuración del servicio (valores omitidos si parecen sensibles) ==")
    Get-ChildItem $ws -Filter 'appsettings*.json' | ForEach-Object {
        $o.Add("-- $($_.Name)")
        function Add-Claves($obj, $pre) {
            foreach ($p in $obj.PSObject.Properties) {
                $k = if ($pre) { "$pre.$($p.Name)" } else { $p.Name }
                if ($p.Value -is [pscustomobject]) { Add-Claves $p.Value $k }
                elseif ($k -match $sensible) { $o.Add("$k = [omitido]") }
                else { $o.Add("$k = $($p.Value)") }
            }
        }
        try { Add-Claves (Get-Content $_.FullName -Raw | ConvertFrom-Json) '' } catch { $o.Add('(no es JSON legible)') }
    }
}

$o.Add("== Servicio ContpaqiBridge (NSSM): solo Application y AppDirectory; demás parámetros solo nombres ==")
$k = 'HKLM:\SYSTEM\CurrentControlSet\Services\ContpaqiBridge\Parameters'
if (Test-Path $k) {
    $p = Get-ItemProperty $k
    foreach ($n in 'Application', 'AppDirectory') { if ($p.PSObject.Properties[$n]) { $o.Add("$n = $($p.$n)") } }
    $otros = (Get-Item $k).Property | Where-Object { $_ -notin 'Application', 'AppDirectory' }
    $o.Add('otros parámetros: ' + ($otros -join ', '))
}

$o.Add("== Puertos en escucha de procesos CONTPAQi/Compac/NSSM/Bridge ==")
try {
    Get-NetTCPConnection -State Listen | ForEach-Object {
        $pr = Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue
        if ($pr -and ($pr.Name -match 'nssm|Compac|Contpaq|Comercial|Bridge|AppKey' -or ($pr.Path -and $pr.Path -match 'Compac'))) {
            $o.Add(("{0}:{1} | {2}" -f $_.LocalAddress, $_.LocalPort, $pr.Name))
        }
    }
} catch { $o.Add('(no disponible: ' + $_.Exception.Message + ')') }

$o.Add("== Instancias de SQL Server en ESTE equipo (servicios locales; no se escanea la red) ==")
try { Get-Service | Where-Object { $_.Name -match '^MSSQL' } | ForEach-Object { $o.Add(("{0} | {1}" -f $_.Name, $_.Status)) } } catch { $o.Add('(no disponible)') }

$o | Set-Content (Join-Path $salida 'sdk.txt') -Encoding UTF8
Write-Host "Escrito $(Join-Path $salida 'sdk.txt')"
