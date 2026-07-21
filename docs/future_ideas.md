# Future Ideas

Ideas **out of scope for v1**, captured so they do not get lost. Prioritize only
after the core timer / dictionary / scorekeeper are production-quality.

## Product

- Rack / anagram helper (given tiles, list valid plays) — privacy-preserving, offline
- Board overlay camera assist (read tiles via ML) — high complexity
- Team / paired scoring modes
- Club night mode: multiple simultaneous boards
- Tournament clock styles (chess-like sudden death)
- Shareable game recap image / PDF
- iCloud / Google Drive optional backup of history
- Widgets: glanceable timer / last winner
- Wear OS / watch complication for timer
- iPad optimized two-pane layout
- Localization of UI strings (lexicons remain English)

## Dictionary

- Enable older lists (TWL06, OSPD5) for casual tables
- School / family-friendly filtered lists
- Phrase / challenge log with timestamps
- Definition provenance badge (NWL vs OSPD enrichment)
- DAWG/FST compression for smaller binaries (inspired by twl06)

## Social / meta (careful — offline-first first)

- Pass-and-play only enhancements
- Optional anonymous high-score board (requires backend — defer)

## Engineering

- Extract `scrabble_lexicon` as a pure Dart package
- Flavor builds: `naOnly` without CSW for stricter licensing distribution
- Codemagic / GitHub Actions full store pipelines
- Screenshot automation from goldens for store listing
- Semantic versioning automation (Clara / conventional commits)

## Design

- Landscape timer “table mode” (huge digits, low reach)
- Custom accent color (still constrained palette)
- Optional wood / felt texture backgrounds (subtle, not skeuomorphic overload)
