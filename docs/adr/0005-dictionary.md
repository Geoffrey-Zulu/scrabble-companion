# ADR-0005 — Dictionary: NWL2023 + CSW21 offline

- **Status:** Accepted
- **Date:** 2026-07-21

## Context

Word checking is the most important engineering decision. Requirements:

- English only
- Offline definitions preferred
- Tournament-credible validity
- Optional NA vs British

Investigated [scrabblewords/scrabblewords](https://github.com/scrabblewords/scrabblewords):

- `words/North-American/NWL2023.txt` — ~196k lines, **definitions embedded**
- `words/British/CSW21.txt` — ~279k lines, **definitions embedded**, Collins notice
- Format: `WORD definition [pos …]`

Also restored `ospd-defs.txt` (~45k) from the classic UW source (local file had
been empty). Format: `WORD pos inflections definition`.

Alternatives: kamilmielnik lists (words only), twl06 DAWG (no defs, older list).

Online APIs rejected for v1.

## Decision

1. **Ship both** NWL2023 (default) and CSW21; user switches in Settings.
2. Use embedded definitions from those files as primary.
3. Use `ospd-defs.txt` as **enrichment** when primary text is a cross-reference only.
4. Ignore non-English folders entirely.
5. Include `assets/dictionaries/NOTICE` covering licenses; evaluate a `naOnly`
   flavor if store/legal review requires dropping CSW.

## Consequences

- True offline definitions without WordNet packaging complexity.
- Larger binary — mitigate with compression / single active lexicon in memory.
- Legal diligence required for CSW redistribution.
- Parser must handle `{lemma=pos}`, `<lemma=pos>`, multi-sense `/` splits, and `#` comments.
