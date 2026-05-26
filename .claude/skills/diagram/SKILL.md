---
name: diagram
description: Create ASCII diagrams with smooth corner box-drawing glyphs for system topologies, data flows, and architecture
argument-hint: what you want to diagram
---

# ASCII Diagram Generator

Create clean ASCII diagrams using smooth corner glyphs (╭ ╮ ╰ ╯) for visualizing:
- Network topologies with named edges
- System architectures and data flow
- Mesh/service connections
- Infrastructure and component relationships

## Key Principles

**Alignment is everything** — box dividers (┬ ┴) must align vertically with connecting lines below/above. Use T-junctions (├ ┤ ┼) where lines meet.

## Box Characters

```
Top:    ╭─────────┬─────────╮
        │ Column1 │ Column2 │
Bottom: ╰─────────┴─────────╯

Connectors:
├ = left T-junction    ┤ = right T-junction
┬ = top T-junction     ┴ = bottom T-junction
┼ = cross              │ = vertical line
─ = horizontal line
```

## Patterns

### Simple Box
```
╭──────────────╮
│   Content    │
╰──────────────╯
```

### Multi-Column Box
```
╭──────────┬──────────┬──────────╮
│ Column1  │ Column2  │ Column3  │
╰──────────┴──────────┴──────────╯
```

### Vertical Connection
```
╭──────────╮
│   Node   │
╰──────────╯
     │
     │ label
     ▼
╭──────────╮
│   Node   │
╰──────────╯
```

### Horizontal Connection with Junction
```
╭──────────╮         ╭──────────╮
│  Node A  │         │  Node B  │
╰──────────╯         ╰──────────╯
     │                    │
     └────────┬───────────┘
              │ connection label
              ▼
```

### T-Junction from Box Column
```
╭──────────┬──────────╮
│ Column1  │ Column2  │
╰──────────┴──────────╯
           │
           │ label
           ▼
```

**Critical**: The vertical line must drop from the exact position of the ┬/┴ divider.

## Instructions

When user asks to create a diagram:

1. **Understand the structure** — identify nodes/components and their connections

2. **Sketch the layout** — plan positions to minimize crossing lines and keep alignment clean

3. **Build boxes first** — create all boxes with proper column dividers (┬/┴) at aligned positions

4. **Add connections** — draw lines (│ ─) that anchor to box dividers and use proper junctions (├ ┤ ┼)

5. **Add labels** — place connection labels next to lines with clear direction indicators (▲ ▼ ◄ ►)

6. **Verify alignment** — ensure every vertical line aligns perfectly with box dividers above/below it

## Tips

- Use monospace font viewing (always true in code blocks)
- Keep node names short so boxes stay compact
- Use arrows (▼ ▲ ◄ ►) to show data flow direction
- Labels go on the connection lines, not floating
- Blank lines between diagram sections
- For complex diagrams, break into multiple smaller ones

## Example: Network Topology

```
╭──────────────┬────────────────┬────────────────╮
│    Client    │  LoadBalancer  │   API Server   │
╰──────────────┴────────────────┴────────────────╯
               │                │
               │ 50ms latency   │ 5ms / 1Gbps
               │                │
               ├────────────────┤
               │                │
               ▼                ▼
         ╭──────────────────────────╮
         │      Database            │
         │   (2ms / 10Gbps)         │
         ╰──────────────────────────╯
```

## Example: Mesh Topology

```
    ╭──────────────╮
    │  Service-A   │
    │ (Port 8001)  │
    ╰──────────────╯
         │      │
    20ms │      │ 20ms
         │      ▼
    ╭────────────────────────╮
    │  Service-B             │
    │  (Port 8002)           │
    ╰────────────────────────╯
         │                   │
    30ms │                   │ 15ms
         │                   ▼
         │            ╭──────────────╮
         │            │  Service-C   │
         │            │ (Port 8003)  │
         │            ╰──────────────╯
         │                   │
         └───────┬───────────┘
                 │ 10ms
                 ▼
          ╭────────────────╮
          │    Database    │
          │  (10Gbps link) │
          ╰────────────────╯
```
