---
name: mermaid
description: Render a Mermaid diagram. Use when asked to visualize, draw, or render a diagram.
argument-hint: [mermaid source or description]
---

Render a Mermaid diagram by generating a PNG and opening it in Preview.

Steps:
1. If $ARGUMENTS contains a Mermaid diagram, use it directly. Otherwise generate one from the description.
2. Write the diagram source to `/tmp/diagram.mmd`.
3. Run: `PUPPETEER_EXECUTABLE_PATH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" mmdc -i /tmp/diagram.mmd -o /tmp/diagram.png -b transparent --scale 3`
4. Run: `open /tmp/diagram.png`
5. If mmdc fails due to syntax errors, fix them and retry.
