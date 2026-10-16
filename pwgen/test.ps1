# =====================================================
# test.ps1 - Tests automatises de pwgen.bf
# =====================================================
# Verifie :
#   1. Determinisme            seed fixe --> sortie identique
#   2. Longueur                100 runs --> tous 16 chars
#   3. Charset                 100 runs x 16 chars --> tous dans [33,126]
#   4. Rejet actif             seed 128 x 0xBC --> tous rejetes --> 16 x '!'
#   5. Rejet borne             seed 128 x 0xBB --> tous acceptes --> 16 x '~'
#   6. Non repetition          100 runs crypto --> aucune paire identique
#   7. Distribution uniforme   10000 chars agreges --> chaque char >= 50 fois
#
# Utilisation :  powershell .\test.ps1
#                (ou  powershell -File .\test.ps1 si execution policy le permet)
# =====================================================

$ErrorActionPreference = 'Stop'

$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$bfjs = Join-Path (Split-Path -Parent $here) 'bf.js'
$prog = Join-Path $here 'pwgen.bf'

function Run-Pwgen {
    param([byte[]] $Seed)
    $seedPath = Join-Path $env:TEMP "pwgen-test-$PID-$([guid]::NewGuid()).bin"
    [IO.File]::WriteAllBytes($seedPath, $Seed)
    try {
        $out = cmd /c "type `"$seedPath`" | node `"$bfjs`" `"$prog`"" 2>&1
        # cmd retourne la sortie avec \r\n. On enleve les trailing whitespace.
        return $out.TrimEnd()
    } finally {
        Remove-Item $seedPath -ErrorAction SilentlyContinue
    }
}

function Assert {
    param([string] $Name, [bool] $Condition, [string] $Detail = '')
    $script:testsRun++
    if ($Condition) {
        Write-Host "  [OK]   $Name" -ForegroundColor Green
        $script:testsOk++
    } else {
        Write-Host "  [FAIL] $Name" -ForegroundColor Red
        if ($Detail) { Write-Host "         $Detail" -ForegroundColor Yellow }
        $script:testsFail++
    }
}

$script:testsRun = 0
$script:testsOk = 0
$script:testsFail = 0

Write-Host ""
Write-Host "======================================================"
Write-Host "  Tests pwgen.bf"
Write-Host "======================================================"

# ---------------------------------------------------------------
# TEST 1  Determinisme
# ---------------------------------------------------------------
Write-Host ""
Write-Host "TEST 1 - Determinisme (meme seed --> meme sortie)"
$seed = [byte[]]::new(128)
for ($i = 0; $i -lt 128; $i++) { $seed[$i] = ($i * 17) -band 0xFF }
$run1 = Run-Pwgen -Seed $seed
$run2 = Run-Pwgen -Seed $seed
$run3 = Run-Pwgen -Seed $seed
Assert 'Run 1 = Run 2' ($run1 -eq $run2) "run1='$run1'  run2='$run2'"
Assert 'Run 2 = Run 3' ($run2 -eq $run3) "run2='$run2'  run3='$run3'"
Write-Host "         sortie deterministe = '$run1'"

# ---------------------------------------------------------------
# TEST 2  Longueur
# ---------------------------------------------------------------
Write-Host ""
Write-Host "TEST 2 - Longueur exacte 16 caracteres (100 runs)"
$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
$lengthOk = 0
$lengthWrongs = @()
try {
    for ($i = 0; $i -lt 100; $i++) {
        $b = [byte[]]::new(128)
        $rng.GetBytes($b)
        $out = Run-Pwgen -Seed $b
        if ($out.Length -eq 16) { $lengthOk++ }
        else { $lengthWrongs += "run $i : $($out.Length) chars ('$out')" }
    }
} finally { $rng.Dispose() }
Assert '100 runs tous a 16 chars' ($lengthOk -eq 100) ($lengthWrongs -join '; ')

# ---------------------------------------------------------------
# TEST 3  Charset
# ---------------------------------------------------------------
Write-Host ""
Write-Host "TEST 3 - Charset ASCII imprimable 33-126 (100 runs x 16 chars)"
$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
$charsetOk = $true
$badChar = ''
try {
    for ($i = 0; $i -lt 100; $i++) {
        $b = [byte[]]::new(128)
        $rng.GetBytes($b)
        $out = Run-Pwgen -Seed $b
        foreach ($ch in $out.ToCharArray()) {
            $code = [int]$ch
            if ($code -lt 33 -or $code -gt 126) {
                $charsetOk = $false
                $badChar = "code $code trouve dans '$out' (run $i)"
                break
            }
        }
        if (-not $charsetOk) { break }
    }
} finally { $rng.Dispose() }
Assert 'Tous les chars dans [33, 126]' $charsetOk $badChar

# ---------------------------------------------------------------
# TEST 4  Rejet actif  (bytes 188-255 rejetes)
# ---------------------------------------------------------------
Write-Host ""
Write-Host "TEST 4 - Rejet actif (128 x 0xBC = 188 tous rejetes)"
$seed = [byte[]]::new(128)
for ($i = 0; $i -lt 128; $i++) { $seed[$i] = 0xBC }
$out = Run-Pwgen -Seed $seed
Assert 'Sortie 16 x <!> (EOF -> 0 accepte)' ($out -eq ('!' * 16)) "recu '$out'"

# ---------------------------------------------------------------
# TEST 5  Rejet borne  (byte 187 = 0xBB accepte, r = 93)
# ---------------------------------------------------------------
Write-Host ""
Write-Host "TEST 5 - Rejet borne (128 x 0xBB = 187 accepte, r = 93)"
$seed = [byte[]]::new(128)
for ($i = 0; $i -lt 128; $i++) { $seed[$i] = 0xBB }
$out = Run-Pwgen -Seed $seed
Assert 'Sortie 16 x <~> (r=93+33=126)' ($out -eq ('~' * 16)) "recu '$out'"

# ---------------------------------------------------------------
# TEST 6  Non repetition entre 100 runs crypto
# ---------------------------------------------------------------
Write-Host ""
Write-Host "TEST 6 - Non repetition (100 runs crypto)"
$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
$results = @{}
$dup = $null
try {
    for ($i = 0; $i -lt 100; $i++) {
        $b = [byte[]]::new(128)
        $rng.GetBytes($b)
        $out = Run-Pwgen -Seed $b
        if ($results.ContainsKey($out)) {
            $dup = "collision : '$out' au run $i et $($results[$out])"
            break
        }
        $results[$out] = $i
    }
} finally { $rng.Dispose() }
Assert 'Aucune paire identique' ($null -eq $dup) $dup

# ---------------------------------------------------------------
# TEST 7  Distribution uniforme (10000 chars agreges)
# ---------------------------------------------------------------
Write-Host ""
Write-Host "TEST 7 - Distribution uniforme (chaque char >= 50 fois sur 10000)"
$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
$counts = @{}
for ($c = 33; $c -le 126; $c++) { $counts[$c] = 0 }
try {
    # 10000 chars = 625 runs de 16
    for ($i = 0; $i -lt 625; $i++) {
        $b = [byte[]]::new(128)
        $rng.GetBytes($b)
        $out = Run-Pwgen -Seed $b
        foreach ($ch in $out.ToCharArray()) {
            $counts[[int]$ch]++
        }
    }
} finally { $rng.Dispose() }
$minCount = ($counts.Values | Measure-Object -Minimum).Minimum
$maxCount = ($counts.Values | Measure-Object -Maximum).Maximum
$expected = 10000 / 94  # ~ 106
Write-Host "         min=$minCount max=$maxCount attendu ~$([math]::Round($expected,1))"
Assert 'Chaque char apparu au moins 50 fois' ($minCount -ge 50) "min=$minCount trop bas"

# ---------------------------------------------------------------
# RESUME
# ---------------------------------------------------------------
Write-Host ""
Write-Host "======================================================"
Write-Host "  Resume : $script:testsOk / $script:testsRun tests OK"
if ($script:testsFail -eq 0) {
    Write-Host "  Tous les tests passent." -ForegroundColor Green
    exit 0
} else {
    Write-Host "  $script:testsFail tests ont echoue." -ForegroundColor Red
    exit 1
}
