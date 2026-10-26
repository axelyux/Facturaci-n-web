# Lectura de cabeceras PE (solo lectura; no carga ni ejecuta la DLL). Compatible con PowerShell 5.1.
function ConvertFrom-PeRva([byte[]]$b, [int]$rva, $secciones) {
    foreach ($s in $secciones) {
        if ($rva -ge $s.Va -and $rva -lt ($s.Va + [Math]::Max($s.VSize, $s.RawSize))) { return ($rva - $s.Va + $s.Raw) }
    }
    return -1
}
function Get-PeInfo([string]$Ruta) {
    $b = [IO.File]::ReadAllBytes($Ruta)
    if ($b.Length -lt 64 -or $b[0] -ne 0x4D -or $b[1] -ne 0x5A) { return [pscustomobject]@{ Ruta = $Ruta; Valido = $false } }
    $pe = [BitConverter]::ToInt32($b, 0x3C)
    $maquina = [BitConverter]::ToUInt16($b, $pe + 4)
    $nSec = [BitConverter]::ToUInt16($b, $pe + 6)
    $tamOpt = [BitConverter]::ToUInt16($b, $pe + 20)
    $opt = $pe + 24
    $magia = [BitConverter]::ToUInt16($b, $opt)
    $dd = if ($magia -eq 0x20b) { $opt + 112 } else { $opt + 96 }
    $sec = @()
    $st = $opt + $tamOpt
    for ($i = 0; $i -lt $nSec; $i++) {
        $o = $st + 40 * $i
        $sec += [pscustomobject]@{ VSize = [BitConverter]::ToInt32($b, $o + 8); Va = [BitConverter]::ToInt32($b, $o + 12)
            RawSize = [BitConverter]::ToInt32($b, $o + 16); Raw = [BitConverter]::ToInt32($b, $o + 20) }
    }
    $arq = switch ($maquina) { 0x14c { 'x86' } 0x8664 { 'x64' } 0xAA64 { 'arm64' } default { ('0x{0:x}' -f $maquina) } }
    $clrRva = [BitConverter]::ToInt32($b, $dd + 14 * 8); $clrTam = [BitConverter]::ToInt32($b, $dd + 14 * 8 + 4)
    $gestionado = ($clrRva -ne 0 -and $clrTam -ne 0)
    $solo32 = $null
    if ($gestionado) {
        $off = ConvertFrom-PeRva $b $clrRva $sec
        if ($off -ge 0) { $flags = [BitConverter]::ToInt32($b, $off + 16); $solo32 = (($flags -band 2) -ne 0) }
    }
    $exportaciones = @()
    $expRva = [BitConverter]::ToInt32($b, $dd); $expTam = [BitConverter]::ToInt32($b, $dd + 4)
    if ($expRva -ne 0 -and $expTam -ne 0) {
        $e = ConvertFrom-PeRva $b $expRva $sec
        if ($e -ge 0) {
            $n = [BitConverter]::ToInt32($b, $e + 24)
            $nombres = ConvertFrom-PeRva $b ([BitConverter]::ToInt32($b, $e + 32)) $sec
            if ($nombres -ge 0 -and $n -gt 0 -and $n -lt 20000) {
                for ($i = 0; $i -lt $n; $i++) {
                    $p = ConvertFrom-PeRva $b ([BitConverter]::ToInt32($b, $nombres + 4 * $i)) $sec
                    if ($p -lt 0) { continue }
                    $f = $p; while ($b[$f] -ne 0) { $f++ }
                    $exportaciones += [Text.Encoding]::ASCII.GetString($b, $p, $f - $p)
                }
            }
        }
    }
    [pscustomobject]@{ Ruta = $Ruta; Valido = $true; Arquitectura = $arq; Gestionado = $gestionado; Requiere32Bits = $solo32; Exportaciones = $exportaciones }
}
