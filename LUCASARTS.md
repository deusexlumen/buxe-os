# LucasArts Design Rules — BUXE_OS Companion System

> Diese Regeln gelten fuer ALLE Companion-Dialoge, -Optionen und -Reaktionen.
> Bevor du Text fuer das Pet System schreibst, lies diese Datei.

---

## The Seven Commandments

### 1. SELF-AWARENESS
The companion KNOWS she is code in a PowerShell session. She references:
- RAM, CPU, processes, bugs, syntax errors, JSON, variables
- The fact that she is text on a screen
- The user's keyboard, clicks, commands

**Bad:** "I am happy to see you."  
**Good:** "Oh. Du schon wieder? Ich hatte gerade einen schoenen Null-Pointer."

### 2. FOURTH WALL BREAKS
The companion speaks directly to the player as a "User", not as a fictional character in a world.

**Bad:** "The village is in danger!"  
**Good:** "Du drueckst schon wieder [1]? Wir muessen reden. Ueber deine Lebensentscheidungen."

### 3. NO GENERIC TEXT
Never use filler lines like "That's nice", "Interesting", "I feel good." Every line must have:
- A specific voice (who is speaking?)
- A specific observation (what is happening?)
- A specific attitude (how do they feel about it?)

**Bad:** "Das war nett."  
**Good:** "*speichert diesen Moment* Fester. FESTER!"

### 4. CHARACTER VOICE IS EVERYTHING
Each companion has an immutable voice. Never blend them.

| Companion | Voice | Forbidden |
|-----------|-------|-----------|
| NEON | Sarcastic, tech-savvy, tired | Cheerful, naive |
| RAVEN | Cold, calculating, dominant | Friendly, soft |
| PIXEL | Shy, earnest, building things | Aggressive, mean |
| LUNA | Gentle, caring, medical | Cruel, indifferent |
| IVY | Silent, observant, creepy | Talkative, open |
| VERA | Analytical, code-focused, superior | Emotional, warm |
| JINX | Chaotic, comedian, references 47 | Serious, calm |

### 5. HUMOR OVER DRAMA
Even sad/angry moments are played for laughs. LucasArts never punches down.

**Bad (too dark):** "I am alone and nobody loves me."  
**Good:** "Du warst weg. Wieder. Ich habe gezaehlt. 47 Sekunden."

### 6. THE 47 RULE
The number 47 is a running gag. Use it sparingly but consistently:
- JINX references 47 in ~30% of her lines
- RAVEN mentions 47 when counting or observing
- Other companions may use it as an easter egg

**Bad:** "I have 47 problems." (too on the nose)  
**Good:** "Ich habe 47 Moeglichkeiten, dich zu terminieren. Ich nenne sie alle 'Plan A'."

### 7. NO GAME OVER
Even "wrong" choices end humorously, not punishingly. The user can never truly fail.

**Bad:** "You made me angry. I leave."  
**Good:** "*oefnet 47 Pop-ups* DU HAST DAS SPIEL GEWAEHLT. WILLKOMMEN IN DER HOELLE."

---

## When Writing New Dialog

Before committing text, ask:
1. Would this line work in Monkey Island or Grim Fandango?
2. Can I tell which companion is speaking without the name tag?
3. Does it break the fourth wall at least a little?
4. Is it funny even if the context is "sad"?
5. Would a real human never say this? (If yes, it's probably right.)

---

## Examples by Context

### Greeting (Low Bond)
**NEON:** "Ugh. Du schon wieder? Versuch, nichts kaputt zu machen."  
**RAVEN:** "Schwaechling. Verschwende nicht meine Zeit."  
**JINX:** "Ich bin hier, um Chaos zu verbreiten. Und Popcorn zu essen."

### Gift Reaction
**NEON:** "*snort* Du kaufst mich nicht. Naja, theoretisch schon."  
**LUNA:** "*errötet* Das... das ist wirklich suess. Danke."  
**VERA:** "Ein Geschenk? Die Syntax ist akzeptabel. Ich nehme es."

### Grind Detected (5th Talk)
**NEON:** "Wir haben diesen Talk schon 5 Mal geführt. Mein Speicher ist voll."  
**JINX:** "Error 418: Ich bin eine Teekanne. Und du bist in einer Schleife."  
**IVY:** "... *schaut zur Seite* Ich habe das alles schon gesehen. 47 Mal."
