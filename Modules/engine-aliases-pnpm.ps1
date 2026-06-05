# BUXE_OS v24.2 -- PNPM ALIASES
# Standard package manager wrapper. Falls pnpm nicht installiert ist,
# wird automatisch npm als Fallback verwendet.

try {

function _Get-PackageManager {
    if (Get-Command pnpm -ErrorAction SilentlyContinue) { return "pnpm" }
    if (Get-Command npm -ErrorAction SilentlyContinue) { return "npm" }
    return $null
}

function p     { & (_Get-PackageManager) @args }
function pi    { & (_Get-PackageManager) install @args }
function pib   { & (_Get-PackageManager) install @args; if ($LASTEXITCODE -eq 0) { & (_Get-PackageManager) run build } }
function ps    { & (_Get-PackageManager) run start }
function pb    { & (_Get-PackageManager) run build }
function pd    { & (_Get-PackageManager) run dev }
function pt    { & (_Get-PackageManager) test }
function pl    { & (_Get-PackageManager) list }
function po    { & (_Get-PackageManager) outdated }
function pr    { & (_Get-PackageManager) run @args }
function px    { & (_Get-PackageManager) exec @args }
function pclean {
    $pm = _Get-PackageManager
    if ($pm -eq "pnpm") { & pnpm store prune }
    else { Remove-Item "node_modules" -Recurse -Force -ErrorAction SilentlyContinue }
    Write-Host "  node_modules bereinigt." -ForegroundColor Green
}

} catch {
    Write-Host "[engine-aliases-pnpm] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
