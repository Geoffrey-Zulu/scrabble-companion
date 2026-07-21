# Claude Design Import - Scrabble Companion

**Design URL:** https://claude.ai/design/p/40bd3430-ca21-4f78-b84c-0a617d1c4603?file=Scrabble+Companion.dc.html  
**MCP endpoint:** `https://api.anthropic.com/v1/design/mcp` - **not available** in this Cursor environment (no Claude Design MCP server registered).  
**Fallback source of truth:** `scrabble-companion-prototype/project/Scrabble Companion.dc.html`

This document is the engineering translation of that prototype: tokens, screens,
motion, and reusable components. Implement Flutter against **this file +**
[`docs/ui_guidelines.md`](../docs/ui_guidelines.md), not against ad-hoc screenshots.

---

## Product framing

Casual-premium Scrabble night companion. Warm paper neutrals, terracotta accent,
large tabular numerals, soft cards with hairline borders. Feels like a physical
scorepad upgraded - not a fantasy RPG, not a purple SaaS template.

Author / developer card in Settings: **Geoffrey Zulu** (WhatsApp + email CTAs).

---

## Design tokens (from `:root` / `[data-theme="dark"]`)

### Color

See UI guidelines for full tables. Key brand accent: **`#D97757`** (light) /
`#E28A6C` (dark).

### Typography scale (observed)

| Token | Size | Weight | Tracking |
| --- | --- | --- | --- |
| kicker | 13 | 600 | 0.06em |
| greeting | 34 | 600 | -0.02em |
| titleLg | 28 | 600 | -0.02em |
| titleMd | 22 | 600 | -0.01em |
| timerHero | 74 | 300 | -0.04em |
| timerHome | 46 | 300 | -0.03em |
| scoreHero | 40 | 600 | -0.02em |
| keypadValue | 60 | 300 | -0.03em |
| body | 16–17 | 500–600 | ~0 |
| meta | 13–14 | 400 | - |
| overline | 12 | 600 | 0.08em uppercase |
| nav | 10.5 | 600 | - |

Font stack in prototype: SF Pro Text / Display. Flutter: platform text theme with
tabular figures enabled for numeric roles.

### Spacing (page)

- Horizontal page padding: **26**
- Card internal padding: **22**
- Card vertical gap: **16**
- Bottom content padding under scroll: **120** (clears nav)
- Nav bar height: **84**

### Radii

| Element | Radius |
| --- | --- |
| Cards | 20 |
| Result card | 22 |
| Settings groups | 16 |
| Search field | 24–27 |
| Pill CTAs | 22–28 |
| Timer primary | 46 |
| Timer secondary | 32 |
| Avatar / initial | 11–14 |
| Sheet top | 26 |
| Device frame (prototype only) | 44–56 |

### Motion

```
tileIn   0.6s  cubic-bezier(.2,.8,.2,1)   splash tile
fadeName 1.0s  ease                       splash wordmark
fadeIn   0.25–0.3s ease                   screen enter
fadeUp   0.28s ease                       result / toast
pop      0.4s  cubic-bezier(.2,.8,.2,1)   winner
fall     variable ease-in                 confetti tiles
sheetUp  0.3s  cubic-bezier(.2,.8,.2,1)   sheets
```

Ring stroke uses **1s linear** dashoffset transitions while counting.

---

## Navigation IA

Bottom tabs (4):

1. **Home**
2. **Timer**
3. **Dictionary**
4. **Settings**

Overlays (not tabs):

- Score Keeper fullscreen
- Add Score sheet
- Winner fullscreen
- New Game sheet
- Toast
- Splash

---

## Screen-by-screen

### Splash

- Centered accent tile 96×96, radius 22, letter **S**, subscript **1**
- Brand label under tile fades in
- Auto-dismiss ~1150 ms

### Home

- Kicker “SCRABBLE COMPANION” / faint overline + time-based greeting
- **Timer card** - large remaining label + Start/Pause pill
- **Dictionary card** - faux search field “Check a word…”
- **Score Keeper card** - resume subtitle/score or empty prompt
- **Start New Game** full-width accent CTA
- **Recent Games** - swipe-to-delete rows; empty dashed icon state

### Timer

- Title “Turn Timer”
- Player chips when game active; else standalone hint
- 300×300 ring (r=135, stroke 10), circumference ≈ 848.2
- Digits + status (“Running”, etc.)
- Controls: Reset (64) · Play/Pause (92) · Switch player (64, if players)
- Duration chips: 0:30 / 1:00 / 2:00 / 3:00

### Dictionary (Word Checker)

- Search field, clear button when non-empty
- Suggestions: exact “Check ↵” + up to 5 prefix matches
- Result card: valid/invalid badge, favorite + share, word, points · POS, definition, optional example & origin
- Recent list with validity dots; empty illustration with “Q/10” tile

### Settings

Sections: Gameplay · Appearance · About · Developer · Reset

Gameplay:

- Warning at: 5s / 10s / 20s / 30s
- Timer sound toggle (prototype boolean) → **extend in app to Off / A / B + volume**
- Haptics toggle

Appearance:

- Theme: Light / Dark / System segmented
- Text size: three “A” buttons

About: Version, Privacy, Feedback  
Developer: GZ card with WhatsApp / Email  
Reset all settings

### Score Keeper

- Back to Home · Round label · Undo
- Player grid (responsive columns by count), leader crown + accent border
- Round history list
- End Game button
- Sheet: player name, large value, optional word, 3×4 keypad, Add Score
- Winner: confetti letters, stats grid, Done / New Game

### New Game

- 2–6 players (min 2)
- Indexed avatar + name field + remove
- Dashed Add player
- Start Game CTA

---

## Component inventory → Flutter

| Prototype | Flutter widget |
| --- | --- |
| Feature card | `ScCard` |
| Accent CTA | `ScPrimaryButton` |
| Field / secondary | `ScSecondaryButton` |
| Circular icon btn | `ScIconButton` |
| Search pill | `ScSearchField` |
| Theme / chip segments | `ScSegmentedControl` |
| Settings switch | `ScToggle` |
| Bottom nav | `ScBottomNav` |
| Sheet chrome | `ScBottomSheet` |
| Toast | `ScToast` |
| Initial avatar | `ScAvatarInitial` |
| Valid/invalid chip | `ScStatusBadge` |
| Timer ring | `ScTimerRing` |
| Keypad | `ScKeypad` |

---

## Interaction rules to preserve

- Inputs strip to `A–Z` and uppercase for words
- Keypad max length 3; strip leading zeros
- Recent games cap 12; lookups recent cap 6
- Favorites are a set of words
- Swipe delete reveal width **84**
- First-run swipe hint once (local flag)

---

## Sound & haptics (product vs prototype)

Prototype synthesizes a WebAudio chime. Production app must use repo files:

| Setting | Asset |
| --- | --- |
| Off | - |
| Sound A | `sound1.mp3` |
| Sound B | `sound2.mp3` |

Volume control recommended. Haptics remain a boolean master switch.

---

## Accessibility notes from design

- Large tap targets on primary controls (44–92 px)
- Text size setting already in UI - wire to `textScaler`
- Ensure badge colors are not the sole validity signal (include text “Valid” / “Invalid”)
- Confetti must honor reduce-motion

---

## Implementation fidelity checklist

- [ ] Tokens match tables above in light + dark
- [ ] Home card stack order and CTAs match
- [ ] Timer ring math uses full circumference progress
- [ ] Dictionary states: empty / suggest / result valid / result invalid
- [ ] Score sheet + winner motion present (or reduced)
- [ ] Settings includes dictionary locale + sound A/B (extensions beyond prototype)
- [ ] No purple / glass / emoji drift
