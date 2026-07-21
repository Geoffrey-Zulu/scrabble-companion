# Branching Strategy

## Branches

| Branch | Role |
| --- | --- |
| `main` | Production-ready history. Protected. Only via PR from `dev` or hotfix. |
| `dev` | Integration branch for the next release. |
| `feature/<slug>` | Short-lived feature work. Branched from `dev`. |
| `fix/<slug>` | Bug fixes targeting `dev` (or `main` for hotfixes). |
| `hotfix/<slug>` | Urgent production fix from `main`; merge back to `dev`. |
| `release/<x.y.z>` | Optional stabilization branch before tagging. |

## Workflow

```
feature/* ──PR──► dev ──PR──► main (release)
                      ▲
hotfix/* ──PR──► main ┴── merge back
```

1. Branch from latest `dev`.
2. Commit in small, meaningful chunks.
3. Open a PR into `dev`.
4. Require: CI green (format, analyze, test), 1 review when collaborators exist.
5. Squash or merge commit - prefer **squash** for features to keep `dev` readable.
6. When releasing, PR `dev` → `main`, tag `vX.Y.Z`, update CHANGELOG.

## Commit messages

Conventional, imperative mood:

```
feat(timer): add pause-on-background policy
fix(dictionary): skip CSW license comment lines
docs(adr): record Drift decision
chore(ci): add analyze workflow
```

## Naming

- `feature/score-undo`
- `fix/timer-drift`
- `docs/foundation` (this phase)

## Local-only experiment

Use `wip/` prefix and do not open PRs until ready. Delete after merge.
