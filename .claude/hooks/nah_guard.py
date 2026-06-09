#!/Users/db/.local/share/mise/installs/pipx-nah/0.5.2/nah/bin/python
"""nah guard — thin shim that imports from the installed nah package."""
import sys, json, os, io

# Capture real stdout immediately — before anything can reassign it.
_REAL_STDOUT = sys.stdout
_ASK = '{"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "ask", "permissionDecisionReason": "nah: error, requesting confirmation"}}\n'
_LOG_PATH = os.path.join(os.path.expanduser("~"), ".config", "nah", "hook-errors.log")
_LOG_MAX = 1_000_000  # 1 MB

def _log_error(tool_name, error):
    """Append crash entry to log file. Never raises."""
    try:
        from datetime import datetime
        ts = datetime.now().isoformat(timespec="seconds")
        etype = type(error).__name__
        msg = str(error)[:200]
        line = f"{ts} {tool_name or 'unknown'} {etype}: {msg}\n"
        os.makedirs(os.path.dirname(_LOG_PATH), exist_ok=True)
        try:
            size = os.path.getsize(_LOG_PATH)
        except OSError:
            size = 0
        if size > _LOG_MAX:
            with open(_LOG_PATH, "w") as f:
                f.write(line)
        else:
            with open(_LOG_PATH, "a") as f:
                f.write(line)
    except Exception:
        pass

def _safe_write(data):
    """Write string to real stdout, exit clean on broken pipe."""
    try:
        _REAL_STDOUT.write(data)
        _REAL_STDOUT.flush()
    except BrokenPipeError:
        pass

tool_name = ""
try:
    buf = io.StringIO()
    sys.stdout = buf
    from nah.hook import main
    main()
    sys.stdout = _REAL_STDOUT
    output = buf.getvalue()
    # Non-empty output = active decision (allow, ask, or deny).
    # Empty output = active_allow disabled, falls through to Claude Code's permission system.
    if not output.strip():
        pass  # active_allow disabled — fall through to Claude Code
    else:
        try:
            json.loads(output)
            _safe_write(output)
        except (json.JSONDecodeError, ValueError):
            _log_error(tool_name, ValueError(f"invalid JSON from main: {output[:200]}"))
            _safe_write(_ASK)
except SystemExit as e:
    sys.stdout = _REAL_STDOUT
    os._exit(e.code if e.code is not None else 0)
except BaseException as e:
    sys.stdout = _REAL_STDOUT
    _log_error(tool_name, e)
    _safe_write(_ASK)

# Always exit clean — prevent Python shutdown from flushing/crashing.
os._exit(0)
