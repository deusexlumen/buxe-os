# BUXE_OS — Gold Balance & Mechanics Audit
> Audit Date: 2026-06-08
> Scope: Casino, Pet System, Strategy, Arcade, Adventure
> Method: Static code analysis of all gold-related formulas, payouts, and sinks

---

## Executive Summary

BUXE_OS has **two separate gold economies** that never interact:
1. **Main Bank** (`Bank.Gold`) — used by Casino, Strategy, Arcade, Daily
2. **Pet Economy** (`Pet.Economy.Gold`) — used by Pet System only

**Verdict: Both economies are broken in opposite directions.**

| System | Direction | Severity |
|--------|-----------|----------|
| Casino Roulette | **Massively player-favorable** | 🔴 CRITICAL |
| Casino Wheel of Fortune | **Completely broken-positive** | 🔴 CRITICAL |
| Casino Keno | Extremely punishing | 🟡 Acceptable (by design) |
| Pet System | **Runaway inflation source** | 🔴 CRITICAL |
| Strategy Rogue | Free + positive EV | 🟡 MEDIUM |
| Strategy Tower Defense | Free + massive positive EV | 🟡 MEDIUM |
| Adventure / Arcade | No gold integration | 🟡 MEDIUM |

---

## 1. Casino System — Broken Math

### 1.1 Roulette: The `2×` Payout Bug

**The Problem:** Even-money bets (Red/Black, Even/Odd) pay `2×` the **full bet**.

Standard roulette pays `1:1` — you get your stake back plus an equal amount. Net profit = `1×` bet.

In BUXE_OS, the code does:
```powershell
# casino-roulette.ps1
$win = $bet * 2   # Red/Black, Even/Odd
```

But the **bet is NOT pre-deducted** from the bankroll. The casino-engine only subtracts on loss:
```powershell
# casino-engine.ps1
if ($result.Win -gt 0) { Add-Gold $result.Win }
if ($result.Loss -gt 0) { Spend-Gold $result.Loss }
```

**Result:** A `100 G` bet on Red that wins pays `200 G`. The `100 G` stake is never removed.
- **Net profit: +200 G** (stake + 2× payout)
- **Expected Value on Red/Black: ~+46%** per spin

| Bet Type | Payout | True Probability | EV per 100G |
|----------|--------|-----------------|-------------|
| Red/Black | 2× | 48.65% | **+46 G** |
| Dozen | 3× | 32.43% | **+39 G** |
| Straight | 36× | 2.70% | **-3 G** |
| Column | 3× | 32.43% | **+39 G** |
| Even/Odd | 2× | 48.65% | **+46 G** |
| Corner | 9× | 10.81% | **+16 G** |
| Six-Line | 6× | 16.22% | **+22 G** |

**Fix:** Pre-deduct the bet OR change even-money payouts to `1×` (net profit = stake returned).

---

### 1.2 Wheel of Fortune: Jackpot on Steroids

**The Problem:** The EV calculation is completely wrong.

```powershell
# casino-wheel.ps1 — segment values
$segments = @(2,2,2,2, 3,3,3, 5,5, 10, 50, 0,0, "JACKPOT")
```

The code computes the win as:
```powershell
$win = $bet * $multiplier
```

But again, the **bet is never pre-deducted**. So:
- A `100 G` spin landing on `10×` pays `1000 G`. Net: **+1000 G**.
- A `100 G` spin landing on `50×` pays `5000 G`. Net: **+5000 G**.

**EV Calculation (bet = 100G, jackpot = 500G):**
```
E[Win] = (4/14)×200 + (3/14)×300 + (2/14)×500 + (1/14)×1000 + (1/14)×5000 + (2/14)×0 + (1/14)×500
       = 57 + 64 + 71 + 71 + 357 + 0 + 36
       = 656 G per 100G bet
Net EV = +556 G per spin (+556%)
```

With a higher jackpot, this gets even worse. The JACKPOT segment reads the Slot progressive, which can grow to thousands.

**Fix:** Pre-deduct the bet. The payout should be net profit, not total return.

---

### 1.3 Keno: Actually Balanced (by Accident)

Keno has ~20-30% RTP with a 70-80% house edge. This is **intentionally punishing** and standard for lottery-style games. No fix needed.

---

### 1.4 Slots: Hard to Calculate but Reasonable

With ~85-95% estimated RTP, free spins, bonus games, and a progressive jackpot, Slots is in a reasonable range. The `1/10000` jackpot chance and player-seeded progressive create a fair long-term expectation.

---

### 1.5 Blackjack, Craps, Baccarat, Hi-Lo: Correct Math

These games use standard rules and payouts. RTP estimates:
- Blackjack: ~99.5% (player skill dependent)
- Craps Pass Line: ~98.6%
- Baccarat Banker: ~98.9%
- Hi-Lo: ~90-95% (strategy dependent)

All reasonable. No fixes needed.

---

## 2. Pet System — Closed-Loop Inflation

### 2.1 The Core Problem: No Sinks

The Pet System has **500 G starting gold** and the following daily income:

| Source | Daily Amount |
|--------|-------------|
| Work (Netrunner avg) | ~57 G |
| 3 Daily Quests (avg) | ~105 G |
| Glitch (20% × 100G avg) | ~20 G |
| Layer 47 bonus | ~20+ G |
| **Daily Subtotal** | **~202 G** |

**Daily sinks (repeatable):**
- Cooking: 15-50 G per buff (lasts 1 fight)
- Architect Mood: 47 G (1×/day)
- Shop: One-time purchases (60-150 G per item)

After buying all 6 shop items (~900 G total), the only recurring sink is **cooking at 15-50 G/day** against **~200 G/day income**.

**Result:** Pet gold grows indefinitely with no cap or drain.

---

### 2.2 Unlimited Combat Income

Combat has **no entry fee**:
- Normal win: 5-15 G
- Boss win (every 5th): 30-40 G
- PvP win: 15-80 G (scales with rank)
- Rival win: 20-40 G (20% spawn rate)

A player can fight indefinitely. With an average of ~10 G per win, 20 fights = +200 G. Zero cost.

---

### 2.3 The Pet/Main Bank Wall

**There is zero transfer between Pet Economy and Main Bank.**
- Casino quests reward Pet Gold (not Main Bank Gold)
- Adventure's +3 G random event goes to Pet Economy
- Work/Quest/Combat income stays in Pet Economy

This means:
1. Pet gold inflation is **isolated** — it doesn't break the casino
2. But the Pet System itself becomes **meaningless** — infinite gold with nothing to spend it on

---

## 3. Strategy System — Free Money

### 3.1 Rogue Dungeon

- **Entry:** Free
- **Combat reward:** `Floor × 10 + 20` G per floor
- **Treasure:** 10-50 G per room
- **Boss:** `Floor × 50` G
- **Clear (20 floors):** `500 × insightMod` G (up to 650 G)

A full run earns ~500-1000 G with zero risk to bankroll.

---

### 3.2 Tower Defense

- **Entry:** Free
- **Internal economy:** Starts with 200 G, earns `Wave × 20 + 10` per wave
- **Victory payout:** `Floor((internalGold + 100) × insightMod)`

With optimal play, internal gold can reach ~1400 G. Payout: up to **~1950 G**.

---

### 3.3 Poker

Poker is the **only strategy game with real risk** — you can lose your buy-in on fold. But the `insightMod` (up to 1.30×) gives skilled players a persistent edge.

---

## 4. Adventure / Arcade — Ghost Economies

### 4.1 Adventure

- **Entry:** Free
- **Main bank reward:** 0 G
- **Pet Economy:** Rare 2% event gives +3 G to Pet Economy

Adventure is a **complete ghost** in the gold economy. It doesn't interact with any currency.

---

### 4.2 Arcade

Only **Hangman** (in `arcade-legacy.ps1`) touches main bank gold:
- Easy: 0 G cost, 0 G reward
- Normal: 10 G cost, 20 G reward (+10 G profit)
- Hard: 25 G cost, 75 G reward (+50 G profit)

All other arcade games (Snake, Tetris, 2048, etc.) have **zero gold interaction**.

---

## 5. Cross-System Analysis

### 5.1 Gold Flow Map

```
Daily Command ──► Main Bank (+100 to +400 G)
                    │
    ┌───────────────┼───────────────┐
    │               │               │
 Casino        Strategy        Hangman
 (broken +EV)  (free +EV)      (small +EV)
    │               │               │
    └───────────────┴───────────────┘
                    │
               Main Bank
                    │
                    ▼ (NO TRANSFER)
              Pet Economy
                    │
    ┌───────────────┼───────────────┐
    │               │               │
 Combat         Work/Quests      Shop
 (free +EV)     (daily +EV)      (one-time)
    │               │               │
    └───────────────┴───────────────┘
                    │
              Pet Economy (infinite growth)
```

---

### 5.2 The Bust Exploit

When Main Bank hits 0 G, `Confirm-Bust` gives **+100 G**.

A player could:
1. Go all-in on a casino game
2. Lose → get 100 G bailout
3. Repeat

This is a **slow but guaranteed gold source** (~100 G per loss cycle).

---

## 6. Recommendations

### 🔴 CRITICAL — Fix Immediately

| # | Issue | Fix |
|---|-------|-----|
| 1 | **Roulette `2×` payout bug** | Pre-deduct bet OR change even-money to `1×` net profit |
| 2 | **Wheel of Fortune broken EV** | Pre-deduct bet OR reduce multipliers by 1 (e.g. `2×` → `1×`, `50×` → `49×`) |
| 3 | **Pet Economy infinite growth** | Add recurring sinks OR transfer tax to Main Bank |

### 🟡 MEDIUM — Balance Soon

| # | Issue | Fix |
|---|-------|-----|
| 4 | **Rogue free +EV** | Add entry fee (e.g. 50 G) or reduce rewards by 30% |
| 5 | **TD free +EV** | Add entry fee (e.g. 100 G) or cap victory payout |
| 6 | **Pet combat no entry fee** | Add 5-10 G per fight OR scale with level |
| 7 | **Netrunner Mission too high** | Reduce to 40-80 G (from 80-150 G) |
| 8 | **Adventure no gold** | Add small rewards (10-50 G for major milestones) |

### 🟢 LOW — Polish

| # | Issue | Fix |
|---|-------|-----|
| 9 | **Bust bailout exploit** | Add cooldown (e.g. 1× per hour) or reduce to 50 G |
| 10 | **Arcade ghost economies** | Add micro-rewards (5-10 G for high scores) |
| 11 | **Pet/Main Bank transfer** | Add `pet transfer` command with 50% tax |
| 12 | **Equipment permanent** | Add durability (breaks after N fights) |

---

## Appendix: Exact Formulas

### Roulette EV (Red/Black, bet = B)
```
P(win) = 18/37 ≈ 0.4865
P(lose) = 19/37 ≈ 0.5135
Win amount = 2B (bug: should be B)
EV = (0.4865 × 2B) - (0.5135 × B) = +0.4595B
```

### Wheel of Fortune EV (bet = B, jackpot = J)
```
E = (4/14)×2B + (3/14)×3B + (2/14)×5B + (1/14)×10B + (1/14)×50B + (1/14)×J
E = 6.21B + J/14
Net = 5.21B + J/14
```

### Pet Daily Income
```
Work avg = (30 + 55 + 57.5) / 3 ≈ 47.5 G
Quests avg = 3 × 35 ≈ 105 G
Glitch avg = 0.20 × 100 ≈ 20 G
Layer 47 = ~20 G
Total = ~192.5 G/day
```

### Pet Daily Sinks (after initial purchases)
```
Cooking max = 50 G
Architect = 47 G
Total = 97 G/day
Net = +95.5 G/day
```

---

*End of Audit*
