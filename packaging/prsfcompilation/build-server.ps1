# PrsfMail browser/WASM build. Browser does not support desktop IMAP/SMTP Gmail.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
function Assert-Success([string] $Message) { if ($LASTEXITCODE -ne 0) { throw "$Message (exit $LASTEXITCODE)" } }
$Root = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$Work = $env:PRSFCOMPILATION_BUILD_WORK_DIR
$Output = $env:PRSFCOMPILATION_BUILD_OUTPUT
if ([string]::IsNullOrWhiteSpace($Work) -or [string]::IsNullOrWhiteSpace($Output) -or [string]::IsNullOrWhiteSpace($env:CARGO_TARGET_DIR) -or [string]::IsNullOrWhiteSpace($env:CARGO_HOME) -or [string]::IsNullOrWhiteSpace($env:RUSTUP_HOME)) {
    throw 'PrsfMail must be built through PrsfCompilation (managed DATA and Rust variables required).'
}
New-Item -ItemType Directory -Force -Path $Work, (Split-Path -Parent $Output) | Out-Null
$Source = Join-Path $Root 'source/mailcraft'
if (-not (Test-Path -LiteralPath (Join-Path $Source 'Cargo.toml'))) {
    $Source = Join-Path $Work 'mailcraft-source'
    if (-not (Test-Path -LiteralPath (Join-Path $Source 'Cargo.toml'))) {
        if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw 'Git or full local source/mailcraft directory required.' }
        & git clone --depth 1 https://github.com/UCS-Care-Group/mailcraft.git $Source
        Assert-Success 'Download MailCraft source'
    }
}
& rustup target add wasm32-unknown-unknown --toolchain stable
Assert-Success 'Rust WASM target setup'
if (-not (Get-Command trunk -ErrorAction SilentlyContinue)) { throw 'Trunk is unavailable. Run tool preparation in PrsfCompilation.' }
$Web = Join-Path $Source 'apps/mailcraft-web'
if (-not (Test-Path -LiteralPath (Join-Path $Web 'index.html'))) { throw "MailCraft web entry point missing: $Web" }
$Dist = Join-Path $Work 'prsfmail-web-dist'
if (Test-Path -LiteralPath $Dist) { Remove-Item -LiteralPath $Dist -Recurse -Force }
Push-Location $Web
try {
    & trunk build --release --dist $Dist
    Assert-Success 'Trunk browser build'
} finally { Pop-Location }
if (-not (Test-Path -LiteralPath (Join-Path $Dist 'index.html'))) { throw 'Web build has no index.html' }
foreach ($Name in @('LICENSE-MIT','LICENSE-APACHE','NOTICE','ATTRIBUTION.md')) {
    $File = Join-Path $Source $Name
    if (Test-Path -LiteralPath $File) { Copy-Item -LiteralPath $File -Destination $Dist }
}
if (Test-Path -LiteralPath $Output) { Remove-Item -LiteralPath $Output -Force }
Compress-Archive -Path (Join-Path $Dist '*') -DestinationPath $Output -CompressionLevel Optimal
if (-not (Test-Path -LiteralPath $Output) -or (Get-Item -LiteralPath $Output).Length -lt 1024) { throw 'Missing or empty output ZIP.' }
Write-Output "SUCCESS: $Output"
