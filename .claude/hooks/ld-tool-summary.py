#!/usr/bin/python3
"""PostToolUse hook: capture expensive/long tool calls into the ld-tools
notes store (`./ld note add --kind tool-summary`) so they become durable and
full-text searchable across sessions.

Design notes:
- Claude Code's PostToolUse payload does NOT include call duration, so
  "long/expensive" is approximated by (a) an always-capture set of inherently
  costly tools and (b) an output-size threshold for everything else.
- This CAPTURES output (head+tail truncated); it does not call an LLM to
  summarize — that would add latency, cost, and recursion risk to every tool
  call. A real summarization pass can run later over these rows.
- The hook must never break the session: all failures are swallowed and it
  always exits 0.
"""
import json
import os
import subprocess
import sys

LD_BIN = "/Users/db/ld/research/main/ld-tools/target/release/ld-tools"

# Tools worth capturing regardless of output size (external / expensive).
ALWAYS = {"Task", "WebFetch", "WebSearch"}
# Tools never worth capturing (cheap, local, high-frequency).
NEVER = {"Read", "Edit", "Write", "Glob", "Grep", "LS", "TodoWrite",
         "NotebookEdit", "BashOutput", "KillShell"}

SIZE_THRESHOLD = 1500   # chars of output before a generic tool is captured
BODY_MAX = 4000         # cap stored body length


def response_text(resp):
    """Best-effort flatten of tool_response into searchable text."""
    if resp is None:
        return ""
    if isinstance(resp, str):
        return resp
    if isinstance(resp, dict):
        # Bash: {stdout, stderr, ...}; others vary.
        for k in ("stdout", "output", "result", "content", "text"):
            if k in resp and isinstance(resp[k], str):
                extra = resp.get("stderr", "")
                return resp[k] + (("\n[stderr]\n" + extra) if extra else "")
        return json.dumps(resp, ensure_ascii=False)[:BODY_MAX * 2]
    return str(resp)


def make_title(tool, tinput):
    if not isinstance(tinput, dict):
        return tool
    if tool == "Bash":
        cmd = (tinput.get("command") or "").strip().splitlines()
        return ("$ " + cmd[0])[:100] if cmd else tool
    if tool in ("WebFetch", "WebSearch"):
        return (tinput.get("url") or tinput.get("query") or tool)[:100]
    if tool == "Task":
        return (tinput.get("description") or tinput.get("subagent_type") or tool)[:100]
    if tool.startswith("mcp__"):
        return tool
    return tool


def truncate(text):
    if len(text) <= BODY_MAX:
        return text
    head = text[: BODY_MAX // 2]
    tail = text[-BODY_MAX // 2:]
    return f"{head}\n\n…[{len(text) - BODY_MAX} chars elided]…\n\n{tail}"


def main():
    raw = sys.stdin.read()
    data = json.loads(raw)

    tool = data.get("tool_name", "")
    tinput = data.get("tool_input", {})
    text = response_text(data.get("tool_response"))
    session = (data.get("session_id") or "")[:8]
    cwd = data.get("cwd") or ""

    if tool in NEVER:
        return
    is_mcp = tool.startswith("mcp__")
    if not (tool in ALWAYS or is_mcp or len(text) >= SIZE_THRESHOLD):
        return
    if not text.strip():
        return

    title = make_title(tool, tinput)
    header = f"tool={tool} cwd={cwd} session={session}"
    body = truncate(f"{header}\n\n{text}")

    tags = [t for t in (tool, os.path.basename(cwd)) if t]

    subprocess.run(
        [LD_BIN, "note", "add",
         "--title", title,
         "--kind", "tool-summary",
         "--source", tool or "hook",
         "--tag", ",".join(tags)],
        input=body, text=True,
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
        timeout=10,
    )


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
    sys.exit(0)
