---
name: nit
description: Review a GitHub PR by editing its code, then use nit to stage the edits as suggestions (and -c comments) in the user's pending review. Use when asked to review a PR with suggestions, suggest changes on a PR, leave inline review comments, or turn local edits into review suggestions. nit never submits the review; the user does.
argument-hint: PR URL or number, and what to look for
---

# Reviewing a PR with nit

nit turns the working tree's diff against the PR head into suggestions, plus `-c`
comments, in the user's pending review. Run it as `nit`; it needs `git` and `gh`.

1. **Check out the PR head.** Use `gh pr checkout <n>`, or a detached worktree
   (`git fetch origin pull/<n>/head && git worktree add --detach <dir> FETCH_HEAD`)
   and pass `--pr <url>` on every call.
2. **Suggest by editing.** Read `gh pr diff <n>` and fix things in the files. Each
   hunk becomes one suggestion, so keep each edit small and about one thing, and
   inside the PR's diff.
3. **Explain each suggestion with a `-c` on its exact lines**, never with a code
   comment inside the suggested code: `-c 'path:LINE why'`. nit posts it as a reply
   in the suggestion's thread.
4. **Comment on everything else** with `-c 'path:LINE text'` or `path:START-END`.
   Lines are in the PR head's numbering, `\n` is a newline, and `-c -` reads one per
   line from stdin. Keep the list in a file and pass it on every run.
   - To reword a comment, rerun with new text on the same lines.
   - `-c 'path:LINE'` with no text deletes it.
   - **Style:** one point per comment, in a sentence or two, under 300 characters
     (nit refuses longer; pass `--max-chars` only when the user asks). Say what you see, then ask: "`X` doesn't filter on `term`.
     Should we add it?" Use backticks for code. Don't restate the PR description,
     cite sources, or explain how you found it; the author can ask.
   - **Check each one against the PR body.** Drop what it already answers or
     accepts as a known limitation, unless you disagree; then say why.
5. **Preview** with `nit --dry-run` and the same `-c` flags. `+` adds, `~` rewrites,
   `-` removes, `=` is already pending. Report any `! skipped` lines, and turn the
   important ones into comments on a nearby line in the diff.
6. **Post and open.** A pending review is visible only to the user, so post it with
   `nit --yes` and the same flags without asking, then open the review for them:
   `${BROWSER:-open} <pr-url>/files`. Summarize what you staged, then recommend
   **Pass** (approve, comments are optional) or **Block** (request changes), with
   a one-line reason. The user decides and submits.

Reruns are safe: reverting an edit removes its suggestion. If nit refuses (exit 2)
because the head moved, update the tree and rerun. Never submit the review; that's
the user's call. Never touch the user's own comments.
