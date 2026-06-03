# BUXE_OS v24.0 -- FUN MODULE

try {

# === TTS ===
function say { param($t); Add-Type -AssemblyName System.Speech; (New-Object System.Speech.Synthesis.SpeechSynthesizer).Speak($t) }
function voice { param($t); if (-not $t) { $t = Read-Host "Text" }; try { edge-tts --text "$t" --write-media "$env:TEMP\voice.mp3" --voice "en-US-AriaNeural" | Out-Null; ffplay -nodisp -autoexit "$env:TEMP\voice.mp3" 2>$null } catch { say $t } }
function clip-say { $t = Get-Clipboard; if ($t) { voice $t } else { Write-Host "Clipboard ist leer." -ForegroundColor Red } }
function stop-say { Get-Process -Name "ffplay" -ErrorAction SilentlyContinue | Stop-Process -Force }
function voices { Write-Host "Stimmen: edge-tts + ffplay (falls installiert), Fallback: System.Speech" -ForegroundColor Cyan }

# === GAGS ===
function genact { try { curl -s https://raw.githubusercontent.com/svenstaro/genact/master/web/genact.js | node - } catch { Write-Host "genact nicht verfuegbar." -ForegroundColor DarkGray } }
function parrot { try { curl parrot.live } catch { Write-Host "parrot.live nicht erreichbar." -ForegroundColor DarkGray } }
function sneakers { Write-Host "SNEAKERS SNEAKERS SNEAKERS" -ForegroundColor Cyan }
function uwu { param($t); if (-not $t) { $t = Read-Host "Text" }; $t = $t -replace 'r','w' -replace 'l','w' -replace 'R','W' -replace 'L','W'; Write-Host $t -ForegroundColor Magenta }
function rig { param($t); if (-not $t) { $t = Read-Host "Befehl" }; Write-Host "  [RIGGED] $t executed with 420% more style." -ForegroundColor Green }
function bs { Write-Host "  Bullshit detected. Filtering... done." -ForegroundColor Yellow }
function sudo-insult { $insults = @("You are not in the sudoers file. This incident will be reported.","What do you think this is, Linux?","Nice try, user.","Permission denied. As always."); Write-Host ($insults | Get-Random) -ForegroundColor Red }

# === APIs ===
function chuck { try { $r = Invoke-RestMethod "https://api.chucknorris.io/jokes/random" -TimeoutSec 5; Write-Host "`n  $($r.value)`n" -ForegroundColor Yellow } catch { Write-Host "API offline." -ForegroundColor DarkGray } }
function cat { try { $r = Invoke-RestMethod "https://catfact.ninja/fact" -TimeoutSec 5; Write-Host "`n  CAT FACT: $($r.fact)`n" -ForegroundColor Cyan } catch { Write-Host "API offline." -ForegroundColor DarkGray } }
function dog { try { $r = Invoke-RestMethod "https://dog.ceo/api/breeds/image/random" -TimeoutSec 5; Write-Host "`n  DOG PIC: $($r.message)`n" -ForegroundColor Cyan } catch { Write-Host "API offline." -ForegroundColor DarkGray } }
function btc { try { $r = Invoke-RestMethod "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd" -TimeoutSec 5; Write-Host "`n  Bitcoin: $($r.bitcoin.usd) USD`n" -ForegroundColor Yellow } catch { Write-Host "API offline." -ForegroundColor DarkGray } }
function bored { try { $r = Invoke-RestMethod "https://www.boredapi.com/api/activity" -TimeoutSec 5; Write-Host "`n  ACTIVITY: $($r.activity)`n" -ForegroundColor Magenta } catch { Write-Host "API offline." -ForegroundColor DarkGray } }
function kanye { try { $r = Invoke-RestMethod "https://api.kanye.rest" -TimeoutSec 5; Write-Host "`n  Kanye: `"$($r.quote)`"`n" -ForegroundColor White } catch { Write-Host "API offline." -ForegroundColor DarkGray } }
function dadjoke { try { $r = Invoke-RestMethod "https://icanhazdadjoke.com/" -Headers @{Accept = "application/json"} -TimeoutSec 5; Write-Host "`n  JOKE: $($r.joke)`n" -ForegroundColor Green } catch { Write-Host "API offline." -ForegroundColor DarkGray } }
function zen { try { $r = Invoke-RestMethod "https://zenquotes.io/api/random" -TimeoutSec 5; Write-Host "`n  $($r[0].q) -- $($r[0].a)`n" -ForegroundColor Cyan } catch { Write-Host "API offline." -ForegroundColor DarkGray } }

# === TOOLS ===
function pomodoro { param($min = 25); Write-Host "  Pomodoro: $min Minuten..." -ForegroundColor Red; Start-Sleep -Seconds ($min * 60); Write-Host "  Zeit um!" -ForegroundColor Green; say "Pomodoro complete" }
function roast { $roasts = @("Your code is like your dating life -- full of exceptions.","I have seen better variable names from a random string generator.","You are the reason we have code reviews.","Your README is longer than your attention span.","You commit like you text -- way too often with no meaning."); Write-Host "`n  ROAST: $($roasts | Get-Random)`n" -ForegroundColor Red }

} catch {
    Write-Host "[fun] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
