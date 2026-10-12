---
name: nit
description: Review a GitHub PR by editing its code, then use nit to stage the edits as suggestions (and -c comments) in the user's pending review. Use when asked to review a PR with suggestions, suggest changes on a PR, leave inline review comments, or turn local edits into review suggestions. nit never submits the review; the user does.
argument-hint: PR URL or number, and what to look for
---

# Reviewing a PR with nit

nit turns the working tree's diff against a PR's head into GitHub suggestions in
the user's **pending** review. Only the user can see a pending review until they
submit it on GitHub, and nit never submits.

Run it as `nit` if it's on the PATH, or as `python3 <clone>/nit.py`. It needs `git`
and an authenticated `gh`.

## Steps

1. **Get a checkout at the PR head.** Use `gh pr checkout <n>` in the repo, or a
   worktree so the user's checkout isn't disturbed:
   `git fetch origin pull/<n>/head && git worktree add --detach <dir> FETCH_HEAD`.
   A detached checkout needs `--pr <url>` on every nit call.
2. **Review and edit.** Read the PR diff (`gh pr diff <n>`), then fix things
   directly in the files. Each hunk becomes one suggestion, so keep each edit
   small and about one thing. There's no need to commit: nit diffs the working tree,
   and committed edits count too.
3. **Add comments for things that aren't a code edit:**
   `-c 'path:LINE text'` or `-c 'path:START-END text'`. Lines are in the PR head's
   numbering, and `\n` makes a newline. For several comments, pipe one per line
   to `-c -`.
4. **Preview:** run `nit --dry-run`, plus the same `-c` flags. Check its plan:
   - `+` will be added, `=` is already pending, `✓` is already in a submitted review,
     and `-` will be removed (a reverted edit, an outdated copy or a duplicate).
   - `! ... skipped` lines can't become suggestions: they're outside the PR diff,
     or in new, deleted, binary or untracked files. Say what was skipped. Turn
     the important ones into `-c` comments on a nearby line that's in the diff,
     or mention them in your summary.
   - `! ... overlaps` means two suggestions touch the same line, and GitHub's
     batch apply takes only one. Merge or split those edits.
5. **Ask before posting.** Show the user the plan and get a yes, then run
   `nit --yes` with the same `-c` flags.
6. **Hand off:** give the user the `.../pull/<n>/files` link to review and submit.

## Iterating

Rerunning is safe. nit adds what's missing, keeps what's posted (even after the
author's pushes move it), and removes its pending suggestions that you've
reverted in the tree. To drop a suggestion, undo that edit and rerun. `-c`
comments persist without being repeated. Comments without nit's hidden marker,
and submitted reviews, are never touched.

## When nit refuses (exit 2)

- **The tree isn't at or ahead of the PR head, or the head moved:** the author
  pushed. Run `git pull` (or merge the new head) and rerun.
- **The head isn't in this repo:** run `gh pr checkout <n>`, or fetch it.
- **Confirmation required:** pass `--yes`, but only after the user has approved.
- **The review was submitted or deleted mid-run:** rerun.
- **The PR is closed or merged:** stop.

Exit 1 is an error, such as no PR found (pass `--pr`), or a `gh` or `git`
failure. Report it rather than retrying blindly.

## Don't

- Submit, approve or request changes on the review. That's the user's call.
- Edit or delete the user's own comments. nit leaves them alone, and so should you.
- Run `nit --yes` without the user's go-ahead.
