# UI Guidelines — Scrabble Companion

Source of truth: Claude Design handoff  
`scrabble-companion-prototype/project/Scrabble Companion.dc.html`  
(Claude Design MCP was unavailable; local HTML is authoritative.)

These guidelines translate the prototype into Flutter. Prefer matching the
**design system** over pixel-copying incidental HTML structure.

---

## Brand & composition

- Warm, calm, tabletop-adjacent — not neon gaming, not purple SaaS.
- First viewport of Home: greeting + three feature cards + primary CTA.
  Avoid dashboard clutter (no stat strips in the hero).
- Accent terracotta `#D97757` is the only loud color; use it for primary
  actions and emphasis, not decoration everywhere.

---

## Color tokens

Implement as `ThemeExtension` / `AppColors`.

### Light

| Token | Hex | Role |
| --- | --- | --- |
| desk | `#E7E4DB` | Outer prototype frame only (app uses `bg`) |
| bg | `#FAF9F5` | Scaffold background |
| card | `#FFFFFF` | Surfaces |
| ink | `#141413` | Primary text |
| muted | `#8C8A80` | Secondary text |
| faint | `#B0AEA5` | Labels, hints, inactive icons |
| line | `#E8E6DC` | Borders / dividers |
| accent | `#D97757` | Primary CTA, links, leader |
| accentSoft | `#F5E4DB` | Selected chips, avatar bg |
| valid | `#4F8A6D` | Valid word |
| validSoft | `#E6EFE9` | Valid badge bg |
| invalid | `#B4534B` | Invalid / destructive |
| invalidSoft | `#F3E4E2` | Destructive soft buttons |
| field | `#F1EFE8` | Inputs, secondary buttons |

### Dark

| Token | Hex |
| --- | --- |
| desk | `#0E0D0B` |
| bg | `#181713` |
| card | `#221F1B` |
| ink | `#F4F2EB` |
| muted | `#918E84` |
| faint | `#605D55` |
| line | `#2E2B26` |
| accent | `#E28A6C` |
| accentSoft | `#3A2A22` |
| valid | `#7BB093` |
| validSoft | `#22302A` |
| invalid | `#D07E74` |
| invalidSoft | `#332320` |
| field | `#2A2723` |

Primary button label on accent: **white** in both themes.

---

## Typography

Prototype uses SF Pro. Flutter mapping:

| Role | Size | Weight | Notes |
| --- | --- | --- | --- |
| Greeting | 34 | 600 | letter-spacing -0.02em |
| Screen title | 28 | 600 | Dictionary / Settings |
| Timer digits | 74 | 300 | tabular figures |
| Home timer | 46 | 300 | tabular |
| Score large | 40 / 34 | 600 | tabular |
| Keypad value | 60 | 300 | tabular |
| Body | 16–17 | 400–500 | |
| Caption / section | 12 | 600 | uppercase, tracking ~0.08em |
| Nav label | 10.5 | 600 | |

Text scale setting: multipliers **0.9 / 1.0 / 1.15** (Small / Default / Large).

Avoid Inter / Roboto / Arial as intentional brand fonts. Prefer platform
defaults or a licensed expressive sans that stays quiet.

---

## Spacing & radii

| Token | Value |
| --- | --- |
| page X padding | 26 |
| card padding | 22 |
| card gap | 16 |
| section top | 34 |
| nav height | 84 |
| radius card | 20 |
| radius result | 22 |
| radius settings group | 16 |
| radius pill button | 22–28 |
| radius search | 24–27 |
| radius sheet | 26 top |

---

## Elevation & borders

Default surfaces use **1px `line` border**, not heavy Material shadows.
Accent CTAs may use soft colored shadow:

`0 10px 24px -12px accent` (Home CTA)  
`0 14px 30px -14px accent` (Timer play)

---

## Motion

| Token | Duration | Curve |
| --- | --- | --- |
| fadeIn | 250–300 ms | ease |
| fadeUp | 280 ms | ease |
| sheetUp | 300 ms | Cubic(0.2, 0.8, 0.2, 1) |
| pop | 400 ms | same cubic |
| tileIn | 600 ms | same cubic |
| ring stroke | 1 s linear | timer |
| toggle knob | 200 ms | ease |

**Reduced motion:** replace fall/pop with opacity; keep functional feedback.

---

## Components

### Cards (`ScCard`)

White/dark card, 20 radius, 1px line, 22 padding. Hover/press may tint border
to accent (use `InkWell`/`Material` carefully — avoid Material ink splash that
fights the look; prefer subtle scale 0.98).

### Primary button

Height 52–56, pill radius, accent fill, white label, weight 600.

### Secondary / field button

`field` fill, ink label, no border.

### Search field

Height 48–54, pill, `field` fill, leading search icon, uppercase input.

### Bottom nav

4 destinations: Home, Timer, Dictionary, Settings. Active = ink/accent; inactive = muted/faint. Top border `line`.

### Bottom sheet

Scrim `rgba(0,0,0,.35)`, card surface, top radius 26, grabber 38×5.

### Toast

Ink background, bg-colored text, pill, above nav (~104 from bottom).

### Valid / invalid badges

Pill with soft bg + saturated text + 7px status dot.

---

## Screens inventory

1. Splash — accent tile “S/1” + brand fade  
2. Home — greeting, timer card, dictionary card, score card, CTA, recent  
3. Timer — ring, controls, duration chips, optional players  
4. Dictionary — search, suggestions, result, recent, empty  
5. Settings — gameplay, appearance, about, developer, reset  
6. Score overlay — grid, history, end game  
7. Add score sheet — keypad + optional word  
8. Winner — confetti + stats  
9. New game sheet — 2–6 name rows  

---

## Iconography

Stroke icons ~1.8 width, round caps/joins, 20–25px in chrome.
Do not mix filled Material icons casually; match prototype SVGs in
`core/icons` as `CustomPainter` or vector assets.

---

## Interaction patterns

- Swipe left on recent game → reveal delete (84px), confirm via full swipe/tap
- Dictionary input: A–Z only, uppercase
- Keypad: max 3 digits; strip leading zeros
- Timer player chip tap → select + reset remaining
- Long-running timer: warn threshold changes ring to accent

---

## Do / Don’t

**Do** use warm neutrals and one accent.  
**Do** keep tabular numbers for anything timed or scored.  
**Don’t** introduce purple gradients, glassmorphism, or emoji ornamentation.  
**Don’t** wrap every block in a Material card with elevation 8.  
**Don’t** put the score keeper in the bottom tab bar.
