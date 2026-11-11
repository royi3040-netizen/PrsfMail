# PrsfMail Windows build, managed by PrsfCompilation.
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
        $Git = Get-Command git -ErrorAction SilentlyContinue
        if (-not $Git) { throw 'MailCraft source not found. Install Git or place full upstream source under source/mailcraft.' }
        & git clone --depth 1 https://github.com/UCS-Care-Group/mailcraft.git $Source
        Assert-Success 'Download MailCraft source'
    }
}
if (-not (Test-Path -LiteralPath (Join-Path $Source 'Cargo.lock'))) { throw 'Cargo.lock is missing.' }
$Target = 'x86_64-pc-windows-msvc'
& rustup target add $Target --toolchain stable
Assert-Success 'Rust Windows target setup'
Push-Location $Source
try {
    & cargo +stable build --release --locked -p mailcraft --target $Target
    Assert-Success 'MailCraft Windows build'
} finally { Pop-Location }
$Exe = Join-Path $env:CARGO_TARGET_DIR "$Target/release/mailcraft.exe"
if (-not (Test-Path -LiteralPath $Exe)) { throw "Built executable not found: $Exe" }
$Stage = Join-Path $Work 'PrsfMail-Windows'
if (Test-Path -LiteralPath $Stage) { Remove-Item -LiteralPath $Stage -Recurse -Force }
New-Item -ItemType Directory -Path $Stage | Out-Null
Copy-Item -LiteralPath $Exe -Destination (Join-Path $Stage 'PrsfMail.exe')
foreach ($Name in @('LICENSE-MIT','LICENSE-APACHE','NOTICE','ATTRIBUTION.md')) {
    $File = Join-Path $Source $Name
    if (Test-Path -LiteralPath $File) { Copy-Item -LiteralPath $File -Destination $Stage }
}
Set-Content -LiteralPath (Join-Path $Stage 'README.txt') -Value 'PrsfMail preliminary Windows build based on MailCraft. Hebrew/RTL rebranding not yet implemented.' -Encoding UTF8
if (Test-Path -LiteralPath $Output) { Remove-Item -LiteralPath $Output -Force }
Compress-Archive -Path (Join-Path $Stage '*') -DestinationPath $Output -CompressionLevel Optimal
if (-not (Test-Path -LiteralPath $Output) -or (Get-Item -LiteralPath $Output).Length -lt 1024) { throw 'Missing or empty output ZIP.' }
Write-Output "SUCCESS: $Output"
