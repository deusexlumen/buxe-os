# BUXE_OS v25.0 — COMPANION STORY ENGINE v1.0
# Generic episode runner for companion storylines

try {

function Invoke-CompanionEpisode {
    param([string]$CompanionName)

    $pet = Get-PetState
    $cp = $pet.Companion
    if (-not $cp) { Write-Host "Kein Companion aktiv."; Wait-Enter; return }
    if ($cp.Name -ne $CompanionName) {
        Write-Host "Diese Story ist fuer $CompanionName. Dein Companion ist $($cp.Name)."
        Wait-Enter; return
    }

    $story = $pet.CompanionStories[$CompanionName]
    if (-not $story) { Write-Host "Keine Story-Daten gefunden."; Wait-Enter; return }

    $episodeNum = $story.Episode
    if ($episodeNum -eq 0) { Write-Host "Keine Episode verfuegbar."; Wait-Enter; return }
    if ($story.Completed) { Write-Host "Diese Episode ist abgeschlossen."; Wait-Enter; return }

    $episode = Get-CompanionEpisodeData -Companion $CompanionName -Episode $episodeNum
    if (-not $episode) { Write-Host "Episode $episodeNum nicht gefunden."; Wait-Enter; return }

    # Title screen
    try { Clear-Host } catch {}
    Show-PetFrame "$($episode.Title)" -Double | Out-Null
    Write-Host "`n  Episode $episodeNum — $($episode.Subtitle)" -ForegroundColor Yellow
    Write-Host "  Companion: $($cp.Name) | Bond: $($cp.Bond)/100" -ForegroundColor DarkGray
    Write-Host "`n  [ENTER] Starten" -ForegroundColor White
    Wait-Enter

    $currentSceneId = 1
    $choicesMade = @()

    while ($currentSceneId -ne -1) {
        $scene = $episode.Scenes | Where-Object { $_.Id -eq $currentSceneId } | Select-Object -First 1
        if (-not $scene) {
            Write-Host "  [FEHLER] Szene $currentSceneId nicht gefunden." -ForegroundColor Red
            Wait-Enter
            return
        }

        try { Clear-Host } catch {}
        Show-PetFrame "$($episode.Title) — Szene $currentSceneId" -Double | Out-Null

        foreach ($line in $scene.Text) {
            Write-Host "  $line" -ForegroundColor White
            Start-Sleep -Milliseconds 200
        }

        if ($scene.DialogLine) {
            Show-CompanionDialog $cp $scene.DialogLine -Fast
        }

        if ($scene.Choices) {
            Write-Host ""
            $choiceKeys = @()
            $i = 1
            foreach ($choice in $scene.Choices) {
                $key = [char](64 + $i)
                $choiceKeys += $key
                Write-Host "  [$key] $($choice.Text)" -ForegroundColor Cyan
                $i++
            }
            Write-Host "  [Q] Abbrechen" -ForegroundColor DarkGray

            $validPattern = '^[' + ($choiceKeys -join '') + 'Q]$'
            $input = Read-Choice "Waehle" $validPattern

            if ($input -eq 'Q') {
                Save-PetState $pet
                return
            }

            $selected = $scene.Choices[$choiceKeys.IndexOf($input)]
            $choicesMade += @{ Scene = $currentSceneId; Choice = $input; Text = $selected.Text }

            if ($selected.BondDelta) {
                $cp.Bond = [math]::Min(100, [math]::Max(0, $cp.Bond + $selected.BondDelta))
            }

            if ($selected.Outcome) {
                Write-Host "`n  $($selected.Outcome)" -ForegroundColor Magenta
                Start-Sleep -Milliseconds 500
            }

            $currentSceneId = $selected.NextScene
        } else {
            Wait-Enter
            $currentSceneId = $scene.NextScene
        }
    }

    $story.Completed = $true
    $story.Choices = $choicesMade
    $story.LastPlayed = (Get-Date).ToString("yyyy-MM-dd HH:mm")

    $nextEpisode = Get-CompanionEpisodeData -Companion $CompanionName -Episode ($episodeNum + 1)
    if ($nextEpisode) {
        $story.Episode = $episodeNum + 1
        $story.Completed = $false
        Write-Host "`n  [FREIGESCHALTET] Episode $($episodeNum + 1)!" -ForegroundColor Green
    } else {
        Write-Host "`n  [ABGESCHLOSSEN] Story von $($cp.Name) beendet!" -ForegroundColor Green
    }

    Add-PetXP 15 "Story"
    Save-PetState $pet
    Show-CompanionDialog $cp (Get-CompanionLine $cp "story_complete") -Fast
    Wait-Enter
}

function Get-CompanionEpisodeData {
    param([string]$Companion, [int]$Episode)

    if (-not $script:CompanionEpisodeData) {
        $dataPath = Join-Path $PSScriptRoot "companion-story-data.ps1"
        if (Test-Path $dataPath) {
            try { . $dataPath } catch { return $null }
        }
    }

    if ($script:CompanionEpisodeData -and $script:CompanionEpisodeData[$Companion]) {
        return $script:CompanionEpisodeData[$Companion][$Episode]
    }
    return $null
}

} catch {
    Write-Host "Fehler in companion-story.ps1: $_" -ForegroundColor Red
}
