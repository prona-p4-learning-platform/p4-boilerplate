#!/bin/bash
SESSION="Ex4-bash"
WORKDIR="/home/p4/p4environment/"
COMMAND="sudo pkill -f p4runner.py"

../utils/stop-tmux.sh "$SESSION" "$WORKDIR" "$COMMAND"
