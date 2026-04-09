#!/usr/bin/env python3
"""
Claude Code Stop Hook
- Plays a notification sound when Claude finishes responding
- Saves chat transcripts to a logs folder

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
import shutil
import subprocess
from pathlib import Path
from datetime import datetime

from focus import focus_terminal


def play_notification():
    """Play a simple notification sound using macOS native afplay."""
    try:
        # Look for a on_stop_boop.wav file in the .claude/hooks/assets directory
        wav_file = Path.home() / ".claude" / "hooks" / "assets" / "on_stop_boop.wav"

        if wav_file.exists():
            # Use macOS native afplay command (non-blocking)
            subprocess.Popen(["afplay", "-v", "3", str(wav_file)],
                           stdout=subprocess.DEVNULL,
                           stderr=subprocess.DEVNULL)
        else:
            print(f"No on_stop_boop.wav found at {wav_file}", file=sys.stderr)
    except Exception as e:
        print(f"Error playing audio: {e}", file=sys.stderr)


def save_transcript(transcript_path: str):
    """Save the chat transcript to the logs folder."""
    try:
        # Create logs directory if it doesn't exist
        logs_dir = Path.home() / ".claude" / "logs"
        logs_dir.mkdir(exist_ok=True)

        # Expand the transcript path
        transcript_path = Path(transcript_path).expanduser()

        if not transcript_path.exists():
            print(f"Transcript not found: {transcript_path}", file=sys.stderr)
            return

        # Create a timestamped filename
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        session_id = transcript_path.parent.name
        log_filename = f"session_{timestamp}_{session_id}.jsonl"

        # Copy the transcript
        destination = logs_dir / log_filename
        shutil.copy2(transcript_path, destination)

        print(f"Transcript saved to: {destination}")

    except Exception as e:
        print(f"Error saving transcript: {e}", file=sys.stderr)


def main():
    """Main hook handler."""
    try:
        # Read the hook input from stdin
        hook_input = json.load(sys.stdin)

        # Check if we're already in a stop hook loop
        if hook_input.get("stop_hook_active"):
            # Don't trigger another iteration to avoid infinite loops
            return

        # Bring the exact iTerm2 tab to focus unless opted out
        if not os.environ.get("CLAUDE_NO_FOCUS"):
            focus_terminal()

        # Play notification sound
        play_notification()

        # Save the transcript
        transcript_path = hook_input.get("transcript_path")
        if transcript_path:
            save_transcript(transcript_path)

    except Exception as e:
        print(f"Hook error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
