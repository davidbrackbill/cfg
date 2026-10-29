---
name: prune
description: Remove git worktrees of this bare repo that are merged, have no changes, or are stale (directory deleted), and delete local branches whose upstream is gone once their commits are merged. Never forces, never deletes remote branches, and keeps anything with local-only work. Use when asked to prune, clean up, or close worktrees or branches.
argument-hint: "[--dry-run]"
---

# prune

Clean up the worktrees of the bare repo (for example `~/ld/mcp/mcp.git`). Keep anything that holds work nobody else has.

## Scope

- Work only on worktrees under the bare repo's directory, such as `~/ld/mcp/*`.
- Skip the bare repo itself, the `main` worktree, and the worktree you are running in.
- Skip tool-managed trees (`~/.gentbench/*`, `~/.claudefoo/*`) and scratchpad trees under `/private/tmp/claude-*`. Other sessions own those. Mention them in the report but do not touch them.

## Steps

1. **Find the bare repo.** Run `git rev-parse --git-common-dir` from any worktree. Run the rest from that bare dir.
2. **Fetch.** `git fetch --prune --quiet origin`. Merge status needs current remote refs.
3. **Inventory** each in-scope worktree: `git worktree list --porcelain`, then per worktree:
   - Dirty: `git -C <wt> status --porcelain` is non-empty (untracked files count).
   - Commits not on origin: `git -C <wt> rev-list --count @{u}..HEAD`. If there is no upstream, treat every commit not in `origin/main` as unpushed.
   - Branch: `git -C <wt> rev-parse --abbrev-ref HEAD`. Detached HEADs need extra care; see below.
   - PR state: `gh pr list -R <owner/repo> --head <branch> --state all --json state,number,headRefOid`.
4. **Classify** each worktree:
   - **Stale**: the directory is gone, or `git worktree list` shows it `prunable`. Action: `git worktree prune`. This only clears metadata.
   - **Merged**: a merged PR exists for the branch and the local HEAD is an ancestor of that PR's `headRefOid` (`git merge-base --is-ancestor HEAD <oid>`). Also merged if HEAD is already an ancestor of `origin/main`. Clean trees only. Action: remove.
   - **No changes**: clean tree, and zero commits unpushed (the upstream contains HEAD). Action: remove. The branch and remote keep the commits.
   - **Keep**: anything dirty, anything with unpushed commits, a merged PR whose local HEAD has commits beyond the merged head, or a detached HEAD with commits no ref contains. Record the reason.
5. **Dry run first** if `--dry-run` was passed or the set is large. Print the plan and stop.
6. **Remove.** `git worktree remove <path>` for each merged or no-changes tree. Never add `--force`. If git refuses, keep the tree and report git's message.
7. **Prune** stale entries: `git worktree prune --verbose`.
8. **Branches with a gone upstream.** `git for-each-ref --format='%(refname:short)|%(upstream:track)' refs/heads`, keep rows whose track is `[gone]`. For each branch:
   - Skip it if any worktree has it checked out (`git worktree list --porcelain`). Git refuses those anyway.
   - Delete it only if its tip is an ancestor of `origin/main`, or an ancestor of the `headRefOid` of a merged PR for that branch name. Squash merges fail a plain `git branch -d`, so use `git branch -D` only after this check passes.
   - Otherwise keep it, and list its unique commits in the report.
   - Record each deleted tip SHA in the report so it can be restored with `git branch <name> <sha>`.
9. **Report** in prose: what was removed and why, what was kept and why, and what was skipped as out of scope. Give the final `git worktree list` for the bare repo.

## Rules

- Delete local branches only under step 8. Never delete remote branches.
- Never use `--force` on removal or discard edits.
- A worktree with an open PR is not automatically kept. Remove it only if it is clean and fully pushed. Say so in the report, since the branch can be checked out again.
- If a removal would leave work only in the reflog (a detached HEAD with commits no ref contains), keep it and ask.
- Ignored build output (`bin/`, `.venv/`, caches, `test-reports/`) is removed with the tree. Check `git -C <wt> status --ignored --porcelain` first and keep any tree holding a `.env` or other local config.
