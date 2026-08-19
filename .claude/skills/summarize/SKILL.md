---
name: summarize
description: Summarize the current session to compact.md with context, motivation, approaches, resources, results, acceptance criteria, current state, and next steps
argument-hint: additional details for prompt
---

## Instructions

Summarize the current session to a markdown file with the following structure:

1. **Context** — What was the user working on? What's the background/setup?
2. **Motivation** — Why did they want to do this? What problem are they solving?
3. **Approaches Tried** — What different strategies or solutions were attempted?
4. **Resources Used** — What tools, files, commands, or external resources were used?
5. **Tool Call Results Summaries** — What were the key outputs/findings from tools called?
6. **Acceptance Criteria** — What does success look like? What were the user's requirements?
7. **Current State** — What's the status now? What works, what doesn't?
8. **Next Steps** — What remains to be done, if anything?

Write the summary to `compact.md` in the current working directory.

Use additional details from the extra prompt information in the argument.

Keep the summary concise but comprehensive—aim for ~500-1000 words. Use bullet points where they improve clarity. Include specific file paths, function names, and command examples where relevant.

After writing the file, confirm the location where it was saved.

Finally, once done writing the file, write in the chat a prompt for the next session.
