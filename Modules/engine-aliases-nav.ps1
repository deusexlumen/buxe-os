# BUXE_OS v24.0 -- NAVIGATION & FILE ALIASES

try {

function ..  { Set-Location .. }
function ... { Set-Location ..\.. }
function ....{ Set-Location ..\..\.. }
function tmp { Set-Location $env:TEMP }
function dl  { Set-Location "$env:USERPROFILE\Downloads" }
function docs{ Set-Location "$env:USERPROFILE\Documents" }
function mkcd { param($p); New-Item -ItemType Directory -Path $p -Force | Out-Null; Set-Location $p }

function ll    { Get-ChildItem @args | Format-Table -AutoSize }
function la    { Get-ChildItem -Force @args }
function touch { param($p); if (Test-Path $p) { (Get-Item $p).LastWriteTime = Get-Date } else { New-Item -ItemType File -Path $p | Out-Null } }
function rmrf  { param($p); Remove-Item -Recurse -Force $p }
function c     { param($p); Get-Content $p }
function which { param($n); Get-Command $n -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source }
function grep  { param($p, $f); Select-String -Pattern $p -Path $f }

} catch {
    Write-Host "[engine-aliases-nav] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
