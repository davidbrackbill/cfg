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
| `orphanedReference` | referenced in code but **not found in LD** (the flag 404s) | **Prime candidate** — the SDK call always returns the in-code default; remove the reference and hardcode that default. First rule out a wrong-project/renamed/typo'd key. |
| `readyForCodeRemoval` | has code refs AND is fully rolled out — every traffic-bearing env serves one deterministic variation, stably | **Prime candidate** — hardcode that variation, remove the branch |
| `readyToArchive` | inactive everywhere, no code refs | Archive in LD (no code change) |
| `inactive` | all envs inactive (off) but code refs remain | Likely removable — verify it's truly abandoned |
| `launched` | launched everywhere, no code refs found | Archive in LD |
| `active` | still does real work (branches in some relevant env) | **Not** a removal candidate — leave it |
| `unknown` / `archived` | no env data / already archived | Skip |

Note: `readyForCodeRemoval` catches **fully-rolled-out flags that still have high eval
counts** — a flag pinned to one variation everywhere is evaluated constantly but its code
branch is dead. Do not dismiss a high-eval flag as "active"; trust the staleState.

## Step 4 — Corroborate with evidence (this is where flagdown earns its keep)

The classifier gives you the mechanical signal; you add judgment. For each candidate, weigh:

- **Which variation it's rolled out to** — `readyForCodeRemoval` flags carry a
  `recommendedValue` field: the exact value to hardcode. State it explicitly (e.g.
  "hardcode `true`"). It's absent on every other flag, so its presence also confirms
  removability. (Only fall back to deriving it from `targeting` if the field is missing.)
- **Permanent flags are config, not debt** — flagdown already excludes `temporary: false`
  flags from `readyForCodeRemoval` (they're kill switches, numeric limits, access gates the
  owner intends to keep). Do not resurrect them as removal candidates. Only if the user
  *explicitly* asks to review permanent flags should you surface them — and frame it as
  "should this still be permanent?", a deliberate review, never an automated cleanup.
- **Prerequisites / dependents** — `targeting.prerequisiteCount > 0` means this flag gates
  others; removing it can break dependent flags. **needs-care**.
- **Targeting complexity on `active` flags** — rules/targets are why a flag stays `active`;
  that's the tool correctly telling you it still differentiates behavior. Don't override it.
- **Evaluation counts** — note `total7d`, but remember it does **not** indicate removability
  on its own: rolled-out flags have high counts. Use it for context, not as the gate.
- **Age** — derive from `creationDate`; old + fully-rolled-out = textbook dead branch.

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
