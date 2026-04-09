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
import shutil
import subprocess
import sys
from pathlib import Path

from focus import focus_terminal


def _play_wav(wav_path: Path):
    """Play a WAV file using the platform's available audio player."""
    if not wav_path.exists():
        print(f"Audio file not found: {wav_path}", file=sys.stderr)
        return
    for player in ("afplay", "paplay", "aplay"):
        if shutil.which(player):
            args = [player]
            if player == "afplay":
                args += ["-v", "3"]
            args.append(str(wav_path))
            subprocess.Popen(args, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            return


def main():
    """Main hook handler."""
    try:
        # Drain stdin (required by hook protocol)
        json.load(sys.stdin)

        if not os.environ.get("CLAUDE_NO_FOCUS"):
            focus_terminal()

        wav_file = Path.home() / ".claude" / "hooks" / "assets" / "on_input_twitter.wav"
        _play_wav(wav_file)

    except Exception as e:
        print(f"Hook error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
