---
name: flag-audit
description: Audit a code package/directory for LaunchDarkly feature flags that are safe to remove. Uses flagdown's AST-precise scan plus live LD data (7-day evaluation counts, per-environment status, targeting complexity) to find and rank cleanup candidates. Use when asked to find removable, stale, or dead flags, assess flag debt, or identify cleanup candidates in a specific directory or package.
argument-hint: <package-path> (directory to audit; defaults to current dir)
---

# Flag Audit

Find LaunchDarkly flags in a package that are safe to remove, with evidence, and rank
them by removal safety. You are the judgment layer on top of flagdown's data.

## Step 1 — Ensure flagdown is available

Run `flagdown -h` to confirm it's on PATH. If not found, install it:
`go install github.com/launchdarkly/flagdown@latest` (or `cd ~/ld/flagdown && go install .`).

flagdown reads its token/project from `~/.config/flagdown/config`, so you normally don't
pass credentials. If enrichment is skipped (output shows no env data), the config is
missing — tell the user; without LD enrichment you can only report call sites, not
removal safety.

## Step 2 — Scan

```bash
flagdown -dir <package-path> -format json
```

Parse the JSON. Top-level: `{ scan, flags }`. Each entry in `flags[]` has `key`,
`staleState`, `callSites`, `codeRefs`, `temporary`, `creationDate`, `variations`, and
`environments` (per env: `on`, `flagStatus`, `lastEvaluation`, `targeting`,
`evaluations.total7d`).

Note `scan.stats`: if `referencesFound` is 0, the package evaluates no flags — say so and stop.

## Step 3 — Bucket by staleState

flagdown pre-classifies each flag. Map to action:

| staleState | Meaning | Action |
|---|---|---|
| `readyForCodeRemoval` | launched in all checked envs, still has code refs | **Prime candidate** — remove branch, hardcode winning variation |
| `readyToArchive` | inactive everywhere, no code refs | Archive in LD (no code change) |
| `inactive` | all envs inactive (off) but code refs remain | Likely removable — verify it's truly abandoned |
| `launched` | launched everywhere, no code refs found | Archive in LD |
| `active` | at least one env actively serving | **Not** a removal candidate — leave it |
| `unknown` / `archived` | no env data / already archived | Skip |

## Step 4 — Corroborate with evidence (this is where flagdown earns its keep)

Don't trust staleState alone. For each candidate, weigh:

- **Evaluation counts** — `environments[env].evaluations.total7d`. Near-zero across all
  envs is the strongest "nobody uses this" signal, even if status looks active. High
  recent counts mean it's live — downgrade or drop the candidate.
- **Last evaluation** — a recent `lastEvaluation` contradicts "stale." Old/never = safer.
- **Targeting complexity** — `targeting.ruleCount`/`targetCount`/`prerequisiteCount > 0`
  means removal changes behavior for specific cohorts or breaks dependent flags. Flag as
  **needs-care**, don't auto-remove.
- **Temporary vs permanent** — `temporary: false` on an old flag may be intentional
  long-lived config, not debt. Note it; ask before removing.
- **Age** — derive from `creationDate`; old + launched + zero evals = textbook dead flag.

## Step 5 — Report

Present a ranked list, safest removals first. For each candidate give:
- flag key, staleState, age, temporary?
- the call sites (`file:line`) so the user sees exactly what code is affected
- the corroborating signal (e.g. "launched in prod+staging, 0 evals/7d, simple toggle")
- any risk/needs-care notes

End with a short summary: N prime candidates, M needs-care, and what you'd remove first.

## Step 6 — Offer to execute

For flags the user wants to actually remove from code, hand off to the
`launchdarkly:launchdarkly-flag-cleanup` skill (it hardcodes the winning variation and
removes references safely). flagdown finds and ranks; that skill does the surgery.

## Notes

- Scope the scan to the package the user named — flagdown only enriches flags it finds
  in that directory, keeping the audit focused and fast.
- For monorepo wrapper packages (e.g. gonfalon's dogfood-flags), pass
  `-definitions <defs-dir>` and `-wrapper-modules <module>` so wrapper call sites resolve.
- Repeat audits are cache-backed (1h TTL), so re-running after a code edit is cheap.
