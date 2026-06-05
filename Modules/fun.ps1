# BUXE_OS v24.0 -- FUN MODULE

try {

# === TTS ===
# TTS lives in the main profile (Say, Set-Voice, Show-Voices, Clip-Say).
# Removed duplicate say/voice/clip-say/stop-say/voices from here to avoid shadowing.

# === GAGS ===
# (Entfernt: genact, parrot, sneakers, uwu, rig, bs, sudo-insult)

# === API WRAPPER ===
function Invoke-PublicApi($Url, $PropertyPath, $Color, $Headers = @{}) {
    try {
        $r = Invoke-RestMethod $Url -Headers $Headers -TimeoutSec 5
        $value = Invoke-Expression "`$r.$PropertyPath"
        Write-Host "`n  $value`n" -ForegroundColor $Color
    } catch { Write-Host "API offline." -ForegroundColor DarkGray }
}

function chuck   { Invoke-PublicApi "https://api.chucknorris.io/jokes/random" "value" "Yellow" }
function cat     { Invoke-PublicApi "https://catfact.ninja/fact" "fact" "Cyan" }
function dog     { Invoke-PublicApi "https://dog.ceo/api/breeds/image/random" "message" "Cyan" }
function btc     { Invoke-PublicApi "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd" "bitcoin.usd" "Yellow" }
function bored   { Invoke-PublicApi "https://www.boredapi.com/api/activity" "activity" "Magenta" }
function kanye   { Invoke-PublicApi "https://api.kanye.rest" "quote" "White" }
function dadjoke { Invoke-PublicApi "https://icanhazdadjoke.com/" "joke" "Green" @{Accept = "application/json"} }
function zen     { Invoke-PublicApi "https://zenquotes.io/api/random" "[0].q + ' -- ' + [0].a" "Cyan" }

# === TOOLS ===
function pomodoro { param($min = 25); Write-Host "  Pomodoro: $min Minuten..." -ForegroundColor Red; Start-Sleep -Seconds ($min * 60); Write-Host "  Zeit um!" -ForegroundColor Green; say "Pomodoro complete" }
function roast { $roasts = @("Your code is like your dating life -- full of exceptions.","I have seen better variable names from a random string generator.","You are the reason we have code reviews.","Your README is longer than your attention span.","You commit like you text -- way too often with no meaning."); Write-Host "`n  ROAST: $($roasts | Get-Random)`n" -ForegroundColor Red }

} catch {
    Write-Host "[fun] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
