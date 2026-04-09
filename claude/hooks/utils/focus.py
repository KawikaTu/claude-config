"""Shared focus utility for Claude Code hooks.

Detects the terminal app and brings it to focus:
- macOS iTerm2: finds the exact session by tty, selects that tab/window
- macOS Terminal.app / VS Code: activates the app (app-level focus)
- Linux X11: uses wmctrl if available (app-level focus)
- Wayland / unsupported: no-op
"""

import os
import platform
import shutil
import subprocess
import sys

IS_MACOS = platform.system() == "Darwin"
IS_LINUX = platform.system() == "Linux"


_ITERM2_FOCUS_SCRIPT = """\
on run argv
    set targetTTY to item 1 of argv
    tell application "iTerm2"
        repeat with w in windows
            repeat with t in tabs of w
                repeat with s in sessions of t
                    if tty of s is targetTTY then
                        select t
                        set index of w to 1
                        activate
                        return
                    end if
                end repeat
            end repeat
        end repeat
    end tell
end run
"""


def _get_tty() -> str | None:
    """Get the controlling tty for this process tree."""
    try:
        result = subprocess.run(
            ["ps", "-o", "tty=", "-p", str(os.getppid())],
            capture_output=True, text=True,
        )
        tty_short = result.stdout.strip()
        if tty_short and tty_short != "??":
            return f"/dev/{tty_short}"
    except Exception:
        pass

    try:
        fd = os.open("/dev/tty", os.O_RDONLY | os.O_NOCTTY)
        tty = os.ttyname(fd)
        os.close(fd)
        return tty
    except Exception:
        return None


def _detect_terminal() -> str:
    """Detect the terminal app via TERM_PROGRAM env var."""
    term = os.environ.get("TERM_PROGRAM", "").lower()
    if "iterm" in term:
        return "iterm2"
    elif "vscode" in term:
        return "vscode"
    elif "apple_terminal" in term:
        return "terminal"
    return "terminal"


def _activate_app_macos(app_name: str):
    """App-level activation via AppleScript (macOS)."""
    try:
        subprocess.Popen(
            ["osascript", "-e", f'tell application "{app_name}" to activate'],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    except Exception as e:
        print(f"focus: error activating {app_name}: {e}", file=sys.stderr)


def _activate_app_linux(app_name: str):
    """App-level activation via wmctrl (Linux X11). No-op if wmctrl is absent."""
    if not shutil.which("wmctrl"):
        return
    try:
        subprocess.Popen(
            ["wmctrl", "-a", app_name],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    except Exception as e:
        print(f"focus: error activating {app_name}: {e}", file=sys.stderr)


def focus_terminal():
    """Bring the terminal to focus. Uses tty-level targeting for iTerm2,
    app-level activation for other terminals. On Linux, uses wmctrl if
    available; otherwise silently skips."""
    if IS_MACOS:
        terminal = _detect_terminal()

        if terminal == "iterm2":
            tty = _get_tty()
            if tty:
                try:
                    subprocess.Popen(
                        ["osascript", "-e", _ITERM2_FOCUS_SCRIPT, tty],
                        stdout=subprocess.DEVNULL,
                        stderr=subprocess.DEVNULL,
                    )
                    return
                except Exception as e:
                    print(f"focus: iTerm2 AppleScript error: {e}", file=sys.stderr)
            _activate_app_macos("iTerm2")
        elif terminal == "vscode":
            _activate_app_macos("Visual Studio Code")
        else:
            _activate_app_macos("Terminal")

    elif IS_LINUX:
        terminal = _detect_terminal()
        if terminal == "vscode":
            _activate_app_linux("Visual Studio Code")
        else:
            # Try common Linux terminal emulator names
            _activate_app_linux(os.environ.get("TERM_PROGRAM", "Terminal"))
