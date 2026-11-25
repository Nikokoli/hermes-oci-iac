#!/usr/bin/env bash
# ensure-gh-path.sh — Make gh discoverable on PATH for non-interactive runners
#
# gh is installed at /home/ubuntu/.hermes/.local/bin/gh, but that directory
# isn't on the default PATH. Non-interactive runners (Telegram factory bridge,
# cron, etc.) cannot find it and report "gh is not installed on this machine".
#
# This script symlinks gh into /usr/local/bin (on PATH) so the factory can
# operate without an interactive login shell.
#
# Usage: sudo ./scripts/ensure-gh-path.sh

set -euo pipefail

GH_LOCAL="/home/ubuntu/.hermes/.local/bin/gh"
GH_PATH="/usr/local/bin/gh"

if [ ! -x "$GH_LOCAL" ]; then
  echo "gh not found at $GH_LOCAL" >&2
  exit 1
fi

if [ -L "$GH_PATH" ] || [ -e "$GH_PATH" ]; then
  echo "$GH_PATH already exists ($(readlink "$GH_PATH" 2>/dev/null || echo "present"))"
else
  sudo ln -sf "$GH_LOCAL" "$GH_PATH"
  echo "Symlinked $GH_LOCAL -> $GH_PATH"
fi

echo "gh is on PATH: $(which gh)"
gh auth status 2>&1 | head -1
