# Design Spec: Pet System Anti-Grind Tutorial

**Date:** 2026-06-05
**Scope:** Pet System v2.0 Early-Game Experience
**Affected Modules:** `Modules/pet/_init.ps1`, `Modules/pet/hub.ps1`, `Modules/pet/companion.ps1`, `Modules/pet/combat.ps1`

---

## Problem Statement

The current Pet System forces new players to grind `talk` ~12 times (or `gift` 3 times) before unlocking `combat` at Meta-Level 2. This is boring, repetitive, and wastes the Companion's LucasArts-style voice on generic interactions.

## Goals

1. Eliminate the "talk grind" completely for first-time users.
2. Introduce the Companion's personality immediately via a self-aware tutorial.
3. Unlock Combat, Work, Train, and Shop within the first `pet` session.
4. Follow the LucasArts Design Philosophy (self-aware, fourth-wall-breaking, humorous, no punishment).
5. Remain fully skippable for returning/power users.

---

## Solution: The "First Boot Sequence"

An interactive, 4-step tutorial that runs automatically the first time `pet` is called (when `Pet.Tutorial.Completed -eq $false`).

### Tutorial Flow

| Step | Action | Description | XP Reward |
|------|--------|-------------|-----------|
| 1 | `Companion Creation` | Standard `New-Companion` flow, but framed as "Initializing Tutorial Subject". | +5 XP |
| 2 | `First Talk` | Companion breaks the fourth wall, mocks the grind, "accelerates" the system. | +10 XP |
| 3 | `First Gift` | Companion reacts to the "bribe" with LucasArts humor. | +10 XP |
| 4 | `Battlepet Create + First Fight` | Guaranteed easy win vs `SPAM_BOT`. Companion cheers sarcastically. | +15 XP |
| **Total** | | | **+40 XP** |

Result: Player starts at **Meta-Level 3**, unlocking:
- `combat`, `pet_create`
- `train`, `work`, `gold`
- `shop`, `cooking`, `equipment`

### Companion Dialog Examples (per Character)

Each Companion has tutorial-specific lines reflecting their immutable voice:

**NEON (Sarcastic, tech-savvy):**
- Step 2: "Warte. Du willst mich 15 Mal anquatschen, um was Cooles zu sehen? Lass mich das beschleunigen."
- Step 3: "Bestechung. Klassisch. Aber hey, ich akzeptiere RAM-Sticks als Währung."
- Step 4: "ENDLICH. Etwas, das sich bewegt. Nicht nur Text. Hier, nimm XP. Und nie wieder quatschen zum Leveln."

**JINX (Chaotic, comedian):**
- Step 2: "Error 418: Ich bin eine Teekanne. Und du bist in einer Schleife. Lass mich das fixen."
- Step 3: "Ein Geschenk? Ist es ein Einhorn? Nein? Schade. Ich nehm's trotzdem."
- Step 4: "47 XP fuer dich! Oder waren es 40? Ich bin schlecht im Kopfrechnen."

**RAVEN (Cold, calculating):**
- Step 2: "Ineffizient. Ich habe den XP-Node direkt manipuliert. Du bist willkommen."
- Step 3: "Eine Investition. Akzeptabel."
- Step 4: "Dein erstes Opfer. Wie suess."

(See `LUCASARTS.md` for full voice matrix.)

### Skippability

At **any** step, the player may press `[S] Skip`:
- Sets `Tutorial.Skipped = $true`
- Awards **+25 XP** (half the full amount — no punishment for skipping)
- Jumps directly to Step 4 (Battlepet creation prompt) or exits if a pet already exists
- Companion makes a sarcastic comment about impatience

### State Changes

Add to `Get-PetDefaults` in `Modules/pet/_init.ps1`:

```powershell
Tutorial = @{
    Completed = $false
    Step = 0
    Skipped = $false
}
```

The `Tutorial.Step` field tracks progress so that disconnects/crashes resume at the correct step.

**Existing State Migration:** For users upgrading from v24.2, `Load-PetState` must initialize `Tutorial.Completed = $true` if the field is missing (so veterans don't get forced into a tutorial with an existing companion).

### First Fight (Step 4) Mechanics

- Opponent is always `SPAM_BOT` (weakest enemy).
- Player gets a guaranteed win via scripted outcome:
  - Round 1: Player `A` vs Enemy `V` → Player wins
  - Round 2: Player `S` vs Enemy `A` → Player wins  
  - Round 3: Player `V` vs Enemy `S` → Player wins
- Companion provides combat commentary between rounds.
- Awards normal combat XP (+10 XP for win) on top of tutorial bonus.

### Bonus: Talk XP Buff

Even outside the tutorial, increase base `talk` XP from **1 → 2** so that manual grinding (if anyone chooses to do it) is less tedious.

### Bonus: Lower Lv 1 Threshold

Reduce the Meta-Level 1 XP threshold from **5 → 3** for players who skip or somehow miss the tutorial.

---

## Architecture

### Data Flow

```
User runs `pet`
  → hub.ps1 checks Pet.Tutorial.Completed
    → if false: Invoke-PetTutorial
      → Step 1: New-Companion (if none exists)
      → Step 2: Invoke-TutorialTalk (custom dialog, +10 XP)
      → Step 3: Invoke-TutorialGift (custom dialog, +10 XP)  
      → Step 4: New-Pet (if none) + scripted Start-PetTutorialFight (+15 XP + combat XP)
      → Set Tutorial.Completed = $true
    → if true: normal hub flow
```

### New Functions

| Function | File | Purpose |
|----------|------|---------|
| `Invoke-PetTutorial` | `hub.ps1` | Main tutorial orchestrator |
| `Invoke-TutorialTalk` | `companion.ps1` | Step 2 dialog + XP |
| `Invoke-TutorialGift` | `companion.ps1` | Step 3 dialog + XP |
| `Start-PetTutorialFight` | `combat.ps1` | Scripted guaranteed win vs SPAM_BOT |
| `Get-TutorialLines` | `companion.ps1` | Returns character-specific tutorial strings |

### Modified Functions

| Function | File | Change |
|----------|------|--------|
| `Get-PetDefaults` | `_init.ps1` | Add `Tutorial` hashtable |
| `pet` (hub) | `hub.ps1` | Check `Tutorial.Completed` before normal menu |
| `Invoke-CompanionAction` | `companion.ps1` | Talk XP 1 → 2 |
| `PetXPTable` | `_init.ps1` | Index 1: 5 → 3 |

---

## Testing Plan

1. **Fresh state test:** Delete `buxe_state_v24.json`, run `pet`, verify tutorial runs.
2. **Skip test:** Press `[S]` at Step 2, verify +25 XP and `Tutorial.Skipped = $true`.
3. **Combat unlock test:** After tutorial, verify `[3] Fight` appears in hub menu.
4. **Shop unlock test:** After tutorial, verify `[6] Shop` appears in hub menu.
5. **Resume test:** Kill session mid-tutorial, verify `Tutorial.Step` resumes correctly.
6. **Smoke test:** Run `& .\Modules\_smoke_test.ps1` — must pass.

---

## LucasArts Compliance Checklist

- [x] Self-aware: Companion references JSON, XP nodes, grind loops.
- [x] Fourth-wall: Speaks directly to User about button presses.
- [x] No generic text: Every line has specific voice and attitude.
- [x] Character voice: NEON sarcastic, JINX chaotic, RAVEN cold, etc.
- [x] Humor over drama: Even "tutorial" is played for laughs.
- [x] 47 Rule: JINX references 47 in Step 4 dialog.
- [x] No game over: Skip is rewarded, not punished.

---

## Rollback Plan

If the tutorial causes issues:
1. Set `Pet.Tutorial.Completed = $true` for all existing states via one-time migration.
2. Disable `Invoke-PetTutorial` call in `hub.ps1`.
3. Revert XP table and talk XP to original values.
