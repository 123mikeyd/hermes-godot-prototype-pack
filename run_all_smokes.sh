#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
GODOT="${GODOT:-$HOME/bin/godot45}"
mkdir -p proof_logs
"$GODOT" --headless --path . --script res://tools/smoke_all.gd 2>&1 | tee proof_logs/smoke_all.stdout.log
echo "All smoke checks passed. Open the project in Godot 4.5 to play visually."
