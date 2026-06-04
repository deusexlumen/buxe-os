# BUXE_OS v24.0 - PowerShell 7/5.1 Compatible Profile
try {

# === MODULES & TOOLS ===
Import-Module Terminal-Icons -ErrorAction SilentlyContinue
Import-Module PSFzf -ErrorAction SilentlyContinue
try { oh-my-posh init pwsh --config "$PSScriptRoot\buxe.omp.json" | Invoke-Expression } catch { Write-Host "  [WARN] OhMyPosh not available" -ForegroundColor DarkGray }
try { Invoke-Expression (& { (zoxide init powershell | Out-String) }) } catch { Write-Host "  [WARN] Zoxide not available" -ForegroundColor DarkGray }

Remove-Item alias:h -Force -ErrorAction SilentlyContinue
Remove-Item alias:sl -Force -ErrorAction SilentlyContinue

# === LOAD v24 ENGINE ===
$modulesDir = Join-Path $PSScriptRoot "modules"
. "$modulesDir\engine-state-core.ps1"
. "$modulesDir\engine-state-migration.ps1"
. "$modulesDir\engine-state-advanced.ps1"
Load-State
. "$modulesDir\engine-ui.ps1"
. "$modulesDir\engine-game.ps1"
. "$modulesDir\engine-render.ps1"
. "$modulesDir\engine-input.ps1"
. "$modulesDir\engine-scene.ps1"
. "$modulesDir\engine-aliases.ps1"
. "$modulesDir\boot.ps1"
. "$modulesDir\casino-engine.ps1"
. "$modulesDir\casino-blackjack.ps1"
. "$modulesDir\casino-roulette.ps1"
. "$modulesDir\casino-craps.ps1"
. "$modulesDir\casino-hilo.ps1"
. "$modulesDir\casino-baccarat.ps1"
. "$modulesDir\casino-slot.ps1"
. "$modulesDir\casino.ps1"
. "$modulesDir\arcade.ps1"
. "$modulesDir\strategy-poker.ps1"
. "$modulesDir\strategy-td.ps1"
. "$modulesDir\strategy-rogue.ps1"
# === LOAD ADVENTURE MODULES ===
. "$modulesDir\adventure-engine.ps1"
. "$modulesDir\adventure-world.ps1"
. "$modulesDir\adventure-companion-ai.ps1"
. "$modulesDir\adventure.ps1"
# === LOAD PET SYSTEM v2.0 ===
$petModules = Get-ChildItem "$modulesDir\pet\*.ps1" | Sort-Object Name
foreach ($pm in $petModules) { . $pm.FullName }
. "$modulesDir\fun.ps1"
. "$modulesDir\handbook.ps1"
. "$modulesDir\ralph-loop.ps1"

# === BOOT SEQUENCE ===
Invoke-BootSequence

} catch {
    Write-Host "Fehler beim Laden des Profils: $_" -ForegroundColor Red
}

# === Edge-TTS Simple Voice Setup ===
# Einfache Stimmenauswahl für edge-tts + ffplay

# --- Stimmenlisten (vorbefüllt für Schnelligkeit) ---
$script:EnglishVoices = @(
    @{ Num=1;  Name="en-US-AvaNeural";                Gender="Female"; Desc="Expressive, Caring" },
    @{ Num=2;  Name="en-US-AndrewNeural";             Gender="Male";   Desc="Warm, Confident" },
    @{ Num=3;  Name="en-US-EmmaNeural";               Gender="Female"; Desc="Cheerful, Clear" },
    @{ Num=4;  Name="en-US-BrianNeural";              Gender="Male";   Desc="Approachable, Casual" },
    @{ Num=5;  Name="en-US-JennyNeural";              Gender="Female"; Desc="Friendly, Considerate" },
    @{ Num=6;  Name="en-US-GuyNeural";                Gender="Male";   Desc="Passion" },
    @{ Num=7;  Name="en-US-AriaNeural";               Gender="Female"; Desc="Positive, Confident" },
    @{ Num=8;  Name="en-US-ChristopherNeural";        Gender="Male";   Desc="Reliable, Authority" },
    @{ Num=9;  Name="en-GB-SoniaNeural";              Gender="Female"; Desc="Friendly, Positive" },
    @{ Num=10; Name="en-GB-RyanNeural";               Gender="Male";   Desc="Friendly, Positive" },
    @{ Num=11; Name="en-GB-LibbyNeural";              Gender="Female"; Desc="Friendly, Positive" },
    @{ Num=12; Name="en-AU-NatashaNeural";            Gender="Female"; Desc="Friendly, Positive" },
    @{ Num=13; Name="en-IN-NeerjaNeural";             Gender="Female"; Desc="Friendly, Positive" },
    @{ Num=14; Name="en-CA-ClaraNeural";              Gender="Female"; Desc="Friendly, Positive" },
    @{ Num=15; Name="en-US-AnaNeural";                Gender="Female"; Desc="Cute, Cartoon" },
    @{ Num=16; Name="en-US-RogerNeural";              Gender="Male";   Desc="Lively" },
    @{ Num=17; Name="en-US-MichelleNeural";           Gender="Female"; Desc="Friendly, Pleasant" },
    @{ Num=18; Name="en-US-EricNeural";               Gender="Male";   Desc="Rational" }
)

$script:MultilingualVoices = @(
    @{ Num=1;  Name="en-US-AvaMultilingualNeural";    Gender="Female"; Desc="Expressive, Caring" },
    @{ Num=2;  Name="en-US-AndrewMultilingualNeural"; Gender="Male";   Desc="Warm, Confident" },
    @{ Num=3;  Name="en-US-EmmaMultilingualNeural";   Gender="Female"; Desc="Cheerful, Clear" },
    @{ Num=4;  Name="en-US-BrianMultilingualNeural";  Gender="Male";   Desc="Approachable, Casual" },
    @{ Num=5;  Name="de-DE-FlorianMultilingualNeural"; Gender="Male";  Desc="German, Friendly" },
    @{ Num=6;  Name="de-DE-SeraphinaMultilingualNeural"; Gender="Female"; Desc="German, Friendly" },
    @{ Num=7;  Name="fr-FR-RemyMultilingualNeural";   Gender="Male";   Desc="French, Friendly" },
    @{ Num=8;  Name="fr-FR-VivienneMultilingualNeural"; Gender="Female"; Desc="French, Friendly" },
    @{ Num=9;  Name="it-IT-GiuseppeMultilingualNeural"; Gender="Male";   Desc="Italian, Friendly" },
    @{ Num=10; Name="pt-BR-ThalitaMultilingualNeural"; Gender="Female"; Desc="Portuguese, Friendly" },
    @{ Num=11; Name="ko-KR-HyunsuMultilingualNeural"; Gender="Male";   Desc="Korean, Friendly" },
    @{ Num=12; Name="en-GB-WilliamMultilingualNeural"; Gender="Male";  Desc="British, Friendly" },
    @{ Num=13; Name="ja-JP-KeitaNeural";              Gender="Male";   Desc="Japanese, Friendly" },
    @{ Num=14; Name="ja-JP-NanamiNeural";             Gender="Female"; Desc="Japanese, Friendly" },
    @{ Num=15; Name="zh-CN-XiaoxiaoNeural";           Gender="Female"; Desc="Chinese, Warm" },
    @{ Num=16; Name="es-ES-AlvaroNeural";             Gender="Male";   Desc="Spanish, Friendly" },
    @{ Num=17; Name="es-ES-ElviraNeural";             Gender="Female"; Desc="Spanish, Friendly" },
    @{ Num=18; Name="ru-RU-DmitryNeural";             Gender="Male";   Desc="Russian, Friendly" },
    @{ Num=19; Name="ru-RU-SvetlanaNeural";           Gender="Female"; Desc="Russian, Friendly" },
    @{ Num=20; Name="hi-IN-MadhurNeural";             Gender="Male";   Desc="Hindi, Friendly" },
    @{ Num=21; Name="ar-EG-SalmaNeural";              Gender="Female"; Desc="Arabic, Friendly" },
    @{ Num=22; Name="pl-PL-MarekNeural";              Gender="Male";   Desc="Polish, Friendly" }
)

# --- Stimmen-Speicher ---
$script:TtsConfigFile = "$env:USERPROFILE\.kimi\tts-config.json"
function Load-TtsVoice {
    if (Test-Path $script:TtsConfigFile) {
        try { return (Get-Content $script:TtsConfigFile -Raw | ConvertFrom-Json).Voice } catch {}
    }
    return "de-DE-SeraphinaMultilingualNeural"
}
function Save-TtsVoice {
    param([string]$Voice)
    $dir = Split-Path $script:TtsConfigFile -Parent
    if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    @{ Voice = $Voice } | ConvertTo-Json | Set-Content $script:TtsConfigFile -Force
}

# --- Aktive Stimme laden (Default: Seraphina) ---
$script:ActiveVoice = Load-TtsVoice

# --- Hilfsfunktionen ---
function Show-Voices {
    Write-Host "`n=== ENGLISCHE STIMMEN ===" -ForegroundColor Cyan
    Write-Host "----------------------"
    foreach ($v in $script:EnglishVoices) {
        $marker = if ($v.Name -eq $script:ActiveVoice) { " <-- AKTIV" } else { "" }
        Write-Host "  [$($v.Num.ToString().PadLeft(2))] $($v.Name.PadRight(35)) [$($v.Gender)] $($v.Desc)$marker"
    }

    Write-Host "`n=== MULTILINGUALE STIMMEN ===" -ForegroundColor Green
    Write-Host "-------------------------"
    foreach ($v in $script:MultilingualVoices) {
        $marker = if ($v.Name -eq $script:ActiveVoice) { " <-- AKTIV" } else { "" }
        Write-Host "  [$($v.Num.ToString().PadLeft(2))] $($v.Name.PadRight(35)) [$($v.Gender)] $($v.Desc)$marker"
    }

    Write-Host "`n TIP: Set-Voice EN 3    -> English #3 (Emma)"
    Write-Host "      Set-Voice ML 5    -> Multilingual #5 (Florian)"
    Write-Host "      Say 'Hallo Welt'  -> Spricht mit aktiver Stimme"
    Write-Host ""
}

function Set-Voice {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("EN","ML")]
        [string]$Category,

        [Parameter(Mandatory=$true)]
        [int]$Number
    )

    $list = if ($Category -eq "EN") { $script:EnglishVoices } else { $script:MultilingualVoices }
    $selected = $list | Where-Object { $_.Num -eq $Number }

    if (-not $selected) {
        Write-Host "[X] Ungültige Nummer. Nutze Show-Voices um die Liste zu sehen." -ForegroundColor Red
        return
    }

    $script:ActiveVoice = $selected.Name
    Save-TtsVoice $selected.Name
    Write-Host "[OK] Stimme geändert zu: $($selected.Name) ($($selected.Desc))" -ForegroundColor Green
}

function Say {
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string]$Text,

        [switch]$Wait
    )

    begin {
        $allText = @()
    }
    process {
        $allText += $Text
    }
    end {
        $finalText = $allText -join " "
        if ([string]::IsNullOrWhiteSpace($finalText)) { return }

        # Temp-Datei für Audio
        $tmpFile = [System.IO.Path]::GetTempFileName() + ".mp3"

        try {
            # edge-tts generiert Audio
            $null = edge-tts --voice $script:ActiveVoice --text $finalText --write-media $tmpFile 2>$null

            if (Test-Path $tmpFile) {
                if ($Wait) {
                    ffplay -nodisp -autoexit -loglevel quiet $tmpFile
                    if (Test-Path $tmpFile) { Remove-Item $tmpFile -Force }
                } else {
                    # Im Hintergrund abspielen
                    $proc = Start-Process -FilePath "ffplay" -ArgumentList "-nodisp","-autoexit","-loglevel","quiet",$tmpFile -PassThru -WindowStyle Hidden
                    # Aufräumen nach dem Abspielen
                    Start-Job -ScriptBlock {
                        param($p, $f)
                        $p.WaitForExit()
                        Start-Sleep -Seconds 1
                        if (Test-Path $f) { Remove-Item $f -Force }
                    } -ArgumentList $proc, $tmpFile | Out-Null
                }
            } else {
                Write-Host "[X] Fehler beim Generieren der Audio-Datei." -ForegroundColor Red
            }
        }
        catch {
            Write-Host "[X] Fehler: $_" -ForegroundColor Red
            if (Test-Path $tmpFile) { Remove-Item $tmpFile -Force }
        }
    }
}

function Clip-Say {
    $text = Get-Clipboard | Out-String
    if ([string]::IsNullOrWhiteSpace($text)) {
        Write-Host "[X] Zwischenablage ist leer." -ForegroundColor Red
        return
    }
    Write-Host "[TTS] Lese $($text.Length) Zeichen aus Zwischenablage..." -ForegroundColor DarkGray
    Say $text
}

# --- Aliasse für Kurzformen ---
Set-Alias -Name voices -Value Show-Voices
Set-Alias -Name svoice -Value Set-Voice

# --- Begruessung beim Start (optional, auskommentiert) ---
# Write-Host "[TTS] Bereit! Tippe 'Show-Voices' fuer die Stimmenliste." -ForegroundColor DarkGray
