---
name: zoxide
description: Show your most-visited directories ranked by frequency
argument-hint: optional filter string (e.g. "ld" to show only ld/* directories)
---

## Show directory frequency from zoxide

Run `zoxide query --list` to get all directories ranked by visit frequency. If an argument is provided, filter to directories matching that pattern.

### Steps

1. Run: `zoxide query --list`
2. If the user provided an argument, filter the output to lines containing that string
3. Display the results with a brief explanation that these are ranked by visit frequency (most-visited first)
