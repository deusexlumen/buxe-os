# BUXE_OS v24.3 -- SCENE ENGINE
# Deklarative Screen-Komposition.
# Spiele definieren WAS gezeigt wird, nicht WIE.

try {

# === SCENE COMPOSITION ===
# Eine Scene ist eine Sammlung von Elementen.
# Jedes Element hat Typ, Position, Content, Style.

function New-Scene($Width = $null, $Height = $null) {
    if (-not $Width) { $Width = $Host.UI.RawUI.WindowSize.Width - 1 }
    if (-not $Height) { $Height = $Host.UI.RawUI.WindowSize.Height - 1 }
    return @{
        Width = $Width
        Height = $Height
        Elements = @()
        Frame = $null
    }
}

function Add-SceneElement($Scene, $Type, $X, $Y, $Content, $Color = 'White', $Width = $null, $Height = $null, [switch]$Double) {
    $Scene.Elements += @{
        Type = $Type      # 'text', 'frame', 'bar', 'block', 'dialog'
        X = $X
        Y = $Y
        Content = $Content
        Color = $Color
        Width = $Width
        Height = $Height
        Double = [bool]$Double
    }
}

function Add-SceneText($Scene, $X, $Y, $Text, $Color = 'White') {
    Add-SceneElement $Scene 'text' $X $Y $Text $Color
}

function Add-SceneFrame($Scene, $X, $Y, $Width, $Height, $Title = $null, $Color = 'Cyan', [switch]$Double) {
    $el = @{ Type = 'frame'; X = $X; Y = $Y; Width = $Width; Height = $Height; Color = $Color; Double = [bool]$Double; Content = $Title }
    $Scene.Elements += $el
}

function Add-SceneBar($Scene, $X, $Y, $Width, $Current, $Max, $Color = 'Green', $EmptyColor = 'DarkGray') {
    $Scene.Elements += @{ Type = 'bar'; X = $X; Y = $Y; Width = $Width; Content = $null; Color = $Color; EmptyColor = $EmptyColor; Current = $Current; Max = $Max }
}

function Add-SceneBlock($Scene, $X, $Y, $Width, $Height, $Char = ' ', $Color = 'White') {
    $Scene.Elements += @{ Type = 'block'; X = $X; Y = $Y; Width = $Width; Height = $Height; Content = $Char; Color = $Color }
}

# === RENDER SCENE TO FRAME ===
# Baut alle Elemente in einen Frame und rendert ihn.

function Show-Scene($Scene, [switch]$Force) {
    # Build frame
    $f = New-Frame $Scene.Width $Scene.Height
    Clear-Frame $f
    
    foreach ($el in $Scene.Elements) {
        switch ($el.Type) {
            'text' { Set-FrameText $f $el.X $el.Y $el.Content $el.Color }
            'frame' {
                Draw-FrameBorder $f $el.X $el.Y $el.Width $el.Height $el.Color -Double:$el.Double
                if ($el.Content) { Draw-FrameTitle $f $el.X $el.Y $el.Width $el.Content $el.Color }
            }
            'bar' { Draw-Bar $f $el.X $el.Y $el.Width $el.Current $el.Max $el.Color $el.EmptyColor }
            'block' { Set-FrameBlock $f $el.X $el.Y $el.Width $el.Height $el.Content $el.Color }
        }
    }
    
    $Scene.Frame = $f
    Render-Frame $f -ForceFull:$Force
}

# === HIGH-LEVEL SCENE BUILDERS ===
# Wiederverwendbare Scene-Templates fuer Spiele.

function New-GameScene($Title, $Subtitle = $null) {
    $w = [math]::Min(70, $Host.UI.RawUI.WindowSize.Width - 2)
    $h = [math]::Min(24, $Host.UI.RawUI.WindowSize.Height - 2)
    $s = New-Scene $w $h
    Add-SceneFrame $s 0 0 $w $h $Title 'Cyan' -Double
    if ($Subtitle) {
        Add-SceneText $s 2 2 $Subtitle 'DarkGray'
    }
    return $s
}

function New-MenuScene($Title, $Options) {
    # Options: @(@{ Key = '1'; Label = 'Talk' }, ...)
    $w = [math]::Min(50, $Host.UI.RawUI.WindowSize.Width - 2)
    $h = 4 + $Options.Count + 2
    $s = New-Scene $w $h
    Add-SceneFrame $s 0 0 $w $h $Title 'Cyan'
    $y = 2
    foreach ($opt in $Options) {
        Add-SceneText $s 2 $y "[$($opt.Key)] $($opt.Label)" 'White'
        $y++
    }
    Add-SceneText $s 2 $y "[Q] Exit" 'DarkGray'
    return $s
}

# === LEGACY COMPATIBILITY ===
# NOTE: Show-Frame lives in engine-ui.ps1 (ASCII frames).
# TUI games use New-Scene + Add-ToScene + Show-Scene directly.

function Show-BarLegacy($Current, $Max, $Width = 20) {
    $f = New-Frame $Width 1
    Draw-Bar $f 0 0 $Width $Current $Max 'Green' 'DarkGray'
    Render-Frame $f -ForceFull
}

} catch {
    Write-Host "[engine-scene] CRITICAL ERROR: $_" -ForegroundColor Red
}
