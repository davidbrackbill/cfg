---
name: handoff
description: Hand a running piece of work over to another agent in a herdr tab. Writes a full-context handoff file, starts the worker (Sonnet 5.5 by default) in a new tab, points it at the file with what to do next, and optionally closes the current session. Use when asked to hand off, hand over, pass the work to another worker, or continue in a fresh agent.
argument-hint: "<topic> [model] [--close]"
---

# Handoff

Pass the current work to another agent so the user can keep operating it. The handoff file carries all the context; the worker's first prompt only points at it.

Arguments: `<topic>` names the work (used in the file name), `[model]` defaults to `claude-sonnet-5-5`, and `--close` (or the user saying "then close yourself") closes this session at the very end. If the topic is missing, take it from the work in progress.

## 1. Find the next number and write the handoff file

Write `~/ld/__ci/handoff-<topic>-<n>.md`, where `<n>` is one more than the highest existing `handoff-<topic>*.md` (`fd 'handoff-<topic>' ~/ld/__ci`). Do not overwrite an earlier handoff; link to it instead. Put durable artifacts (data, scripts, the latest copy of anything published) under `~/ld/__ci/<topic>/` and name them in the file, because the scratchpad can vanish.

Write for a reader who has none of this conversation. Start with when it was written and the worker's role, then these sections, in this order:

1. **User style and hard rules.** Taken from the user's own words and CLAUDE.md: tone, pronouns (they/them for people), what must never happen without an explicit OK (pushing, commenting, editing PRs, posting, updating artifacts), what to report in chat before touching anything, formatting and commit conventions, tools to prefer. Include rules learned this session, such as actions an auto-mode classifier denied.
2. **What happened since the last handoff.** Facts only: branch names with SHAs, PR numbers and what is pushed versus local, artifact URLs with how to edit them safely, measured numbers with their caveats, what is verified and what is not, what was deleted.
3. **What is running and where.** Hosts, sessions, job names, progress counts, and the exact command that checks each one. Say whether each job is finished.
4. **Your steps, in order.** A numbered list, each step concrete enough to run: commands, files, expected values, and when to stop and report. Say which steps need the user's OK before they act.
5. **Open questions waiting on the user.** Do not act on these until answered.
6. **Tools that worked.** Commands and gotchas the worker would otherwise rediscover.

Be honest about gaps: say what was not re-verified, which numbers are estimates, and which comments or docs are now stale. Never include secrets or the user's personal details beyond what the work needs.

If a cron job or other session-only schedule belongs to the work, either cancel it (CronDelete) and move its job into the steps, or say that it will not survive this session.

## 2. Start the worker in a herdr tab

Only when running inside herdr (`test "${HERDR_ENV:-}" = 1`). If not, give the user the file path and the `claude --model <model>` command to run themselves.

```bash
herdr tab create --workspace "$HERDR_WORKSPACE_ID" --cwd "$PWD" --label "<topic>-worker" --no-focus
herdr pane run <pane-id> "claude --model <model>"
herdr agent wait <pane-id> --until idle --timeout 60000
herdr agent prompt <pane-id> "You are the '<topic>' worker (handoff <n>). Read ~/ld/__ci/handoff-<topic>-<n>.md in full, then <any other file it names>. Confirm in a few lines what is running and what you will do next, then carry on with the steps in the handoff. Report results in chat before touching any artifact, and don't push or post anything without the user's OK."
```

Read `pane_id` from the JSON that `tab create` returns. Use the cwd the work needs. If the prompt lands as a pasted block without submitting, send `herdr agent send-keys <pane-id> Enter`. Confirm the worker reads the file (`herdr agent read <pane-id> --source recent-unwrapped --lines 40`) before leaving it. Focus the tab (`herdr tab focus <tab-id>`) when the user says they will operate it.

Never answer the worker's permission prompts for the user.

## 3. Close out

Tell the user in a few lines: the handoff file path, the tab label, what the worker will do first, and anything left running or unfinished. Then, only if asked to close, close this session's own pane as the last action (`herdr pane close "$HERDR_PANE_ID"` once `herdr pane` confirms the syntax) after the summary is written, because the summary will not be seen afterwards.
