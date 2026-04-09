#!/usr/bin/env python3
"""
Claude Code Permission Request Hook
- Plays a notification sound when Claude requests permission

NOTE: This script is invoked via `uv run --no-project` in settings.json.
The --no-project flag prevents uv from inheriting a pyproject.toml from
whatever working directory Claude Code happens to be in, which would
cause dependency resolution errors for unrelated projects.

Currently this script only uses stdlib + local focus.py. If you add a
third-party dependency in the future, either:
  1. Add inline script metadata (PEP 723) at the top of this file:
       # /// script
       # requires-python = ">=3.10"
       # dependencies = ["some-package"]
       # ///
  2. Or give ~/.claude/hooks/utils/ its own pyproject.toml and remove
     --no-project from settings.json.
"""

import json
import os
import sys
import subprocess
from pathlib import Path

from focus import focus_terminal


def play_notification():
    """Play a notification sound using macOS native afplay."""
    try:
        # Look for the on_input_twitter.wav file in the .claude/hooks/assets directory
        wav_file = Path.home() / ".claude" / "hooks" / "assets" / "on_input_twitter.wav"

        if wav_file.exists():
            # Use macOS native afplay command (non-blocking)
            subprocess.Popen(["afplay", "-v", "3", str(wav_file)],
                           stdout=subprocess.DEVNULL,
                           stderr=subprocess.DEVNULL)
        else:
            print(f"No on_input_twitter.wav found at {wav_file}", file=sys.stderr)
    except Exception as e:
        print(f"Error playing audio: {e}", file=sys.stderr)


def main():
    """Main hook handler."""
    try:
        # Read the hook input from stdin
        hook_input = json.load(sys.stdin)

        # Bring the exact iTerm2 tab to focus unless opted out
        if not os.environ.get("CLAUDE_NO_FOCUS"):
            focus_terminal()

        # Play notification sound
        play_notification()

    except Exception as e:
        print(f"Hook error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
