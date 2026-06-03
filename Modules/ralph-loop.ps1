# BUXE_OS v24.0 -- RALPH LOOP (Kimi CLI Aliase)

try {

function kimir { kimi $args }
function kimia { kimi --max-ralph-iterations 15 $args }
function kimix { kimi --max-ralph-iterations 30 $args }
function kimis { kimi --max-ralph-iterations 50 $args }

} catch {
    Write-Host "[ralph-loop] CRITICAL ERROR: $_" -ForegroundColor Red
}
