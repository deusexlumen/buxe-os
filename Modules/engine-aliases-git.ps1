# BUXE_OS v24.0 -- GIT ALIASES

try {

function g    { git @args }
function gs   { git status -sb }
function ga   { git add @args }
function gc   { 
    param($m)
    if (-not $m) { Write-Host "Usage: gc \"message\"" -ForegroundColor Yellow; return }
    git commit -m "$m" 
}
function gp   { git push }
function gl   { git pull }
function gco  { git checkout @args }
function gb   { 
    if ($args.Count -eq 0) { git branch -v } 
    elseif ($args[0] -eq '-d') { git branch -d $args[1] }
    else { git branch @args }
}
function gd   { git diff }
function glog { git log --oneline --graph --decorate -20 }
function gcm  { git checkout (git branch --show-current) }
function gundo { git reset --soft HEAD~1 }
function gunstage { git restore --staged @args }

} catch {
    Write-Host "[engine-aliases-git] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
