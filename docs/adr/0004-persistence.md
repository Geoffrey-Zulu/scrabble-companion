# ADR-0004 - Persistence: Drift (SQLite)

- **Status:** Accepted
- **Date:** 2026-07-21

## Context

Persist settings, multi-player games, turns, favorites, lookups, and stats.
Data is relational. Product lifespan is years.

Options researched (2026):

| Store | Pros | Cons |
| --- | --- | --- |
| **Drift** | Type-safe SQL, migrations, reactive queries, active maintainer | Codegen |
| Hive / Hive CE | Simple KV | Weak relations; CE maintenance posture |
| Isar / forks | Fast objects | Upstream stalled; fork risk for new apps |
| sqflite raw | Control | More boilerplate, fewer guards |

Industry maintenance-first guidance in 2026 favors Drift for offline business
data.

## Decision

Use **Drift ^2.34.x** as the system of record.  
`shared_preferences` only for tiny bootstrap flags if ever needed.

## Consequences

- Clear migrations for schema evolution.
- Excellent repository testing via in-memory SQLite.
- Slightly more setup than Hive - acceptable trade for longevity.
