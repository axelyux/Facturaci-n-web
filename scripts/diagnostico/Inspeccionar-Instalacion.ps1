<#
.SYNOPSIS
  Inventario de SOLO LECTURA de la instalación local de CONTPAQi (versión, DLL, registros COM, bitness).
  No instala, no registra ni ejecuta nada de CONTPAQi. Escribe .\salida\instalacion.txt (sin secretos).
#>
$ErrorActionPreference = 'Stop'
$salida = Join-Path $PSScriptRoot 'salida'; New-Item -ItemType Directory -Force -Path $salida | Out-Null
$o = New-Object System.Collections.Generic.List[string]
$o.Add("SO: $([Environment]::OSVersion.VersionString)  64bitSO=$([Environment]::Is64BitOperatingSystem)  PS=$($PSVersionTable.PSVersion)")

$o.Add("== Programas instalados con 'CONTPAQ' ==")
foreach ($k in 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*') {
    Get-ItemProperty $k -ErrorAction SilentlyContinue | Where-Object { $_.PSObject.Properties['DisplayName'] -and $_.DisplayName -match 'CONTPAQ|Comercial' } |
        ForEach-Object { $o.Add(("{0} | {1} | {2} | {3}" -f $_.DisplayName, $_.DisplayVersion, $_.InstallLocation, $k)) }
}

$o.Add("== Servicios con 'CONTPAQ|Comercial|MGW' ==")
Get-CimInstance Win32_Service | Where-Object { $_.Name -match 'CONTPAQ|Comercial|MGW' -or $_.DisplayName -match 'CONTPAQ' } |
    ForEach-Object { $o.Add(("{0} | {1} | {2}" -f $_.Name, $_.State, $_.PathName)) }

$o.Add("== DLL/EXE en carpetas de CONTPAQi (bitness por cabecera PE) ==")
$raices = @($env:ProgramFiles, ${env:ProgramFiles(x86)}) | ForEach-Object { Join-Path $_ 'Compac*' ; Join-Path $_ 'CONTPAQ*' } | Where-Object { $_ }
foreach ($r in $raices) {
    Get-ChildItem $r -Recurse -Include *.dll,*.tlb -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'SDK|MGW|Comercial|Interop|Timbr' } | ForEach-Object {
        $bytes = [IO.File]::ReadAllBytes($_.FullName)[0..1023]
        $pe = [BitConverter]::ToInt32($bytes, 0x3C); $m = [BitConverter]::ToUInt16($bytes, $pe + 4)
        $arq = switch ($m) { 0x14c { 'x86' } 0x8664 { 'x64' } default { "0x{0:x}" -f $m } }
        $o.Add(("{0} | v{1} | {2}" -f $_.FullName, $_.VersionInfo.FileVersion, $arq))
    }
}

$o.Add("== Clases COM registradas (ProgID) con 'CONTPAQ|MGW|Comercial' ==")
foreach ($h in 'HKLM:\SOFTWARE\Classes', 'HKLM:\SOFTWARE\WOW6432Node\Classes') {
    Get-ChildItem $h -ErrorAction SilentlyContinue | Where-Object { $_.PSChildName -match 'CONTPAQ|MGW|Comercial' } |
        ForEach-Object { $o.Add(("{0} | {1}" -f $h, $_.PSChildName)) }
}
$o | Set-Content (Join-Path $salida 'instalacion.txt') -Encoding UTF8
Write-Host "Escrito $(Join-Path $salida 'instalacion.txt'). Revíselo antes de compartirlo."
