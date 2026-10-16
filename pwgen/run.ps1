# =====================================================
# run.ps1 - Wrapper du generateur de mot de passe Brainfuck
# =====================================================
# Genere 128 octets cryptographiquement surs, les envoie
# a pwgen.bf via node bf.js, et affiche le mot de passe.
#
# Usage :  .\run.ps1
#
# Note : passe par un fichier temporaire + cmd type pour
#        eviter le BOM UTF-8 que le StreamWriter .NET
#        insererait sur StandardInput.
# =====================================================

$ErrorActionPreference = 'Stop'

$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$bfjs = Join-Path (Split-Path -Parent $here) 'bf.js'
$prog = Join-Path $here 'pwgen.bf'

if (-not (Test-Path $bfjs)) {
    Write-Error "bf.js introuvable a : $bfjs"
    exit 1
}
if (-not (Test-Path $prog)) {
    Write-Error "pwgen.bf introuvable a : $prog"
    exit 1
}

# Verifie que Node est present.
try {
    $null = & node --version 2>&1
} catch {
    Write-Error "Node.js n'est pas disponible dans le PATH."
    exit 1
}

# Genere 128 octets cryptographiques via l'API Windows.
$bytes = [byte[]]::new(128)
$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
try {
    $rng.GetBytes($bytes)
} finally {
    $rng.Dispose()
}

# Ecrit les octets dans un fichier temporaire.
$seed = Join-Path $env:TEMP "pwgen-seed-$PID.bin"
[IO.File]::WriteAllBytes($seed, $bytes)

try {
    # Passe le fichier a node via cmd type (aucun BOM ajoute).
    cmd /c "type `"$seed`" | node `"$bfjs`" `"$prog`""
} finally {
    Remove-Item $seed -ErrorAction SilentlyContinue
}
