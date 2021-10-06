#!/bin/bash
SESSION=$1
WORKDIR=$2
COMMAND1=$3

echo "Killing tmux session $SESSION"

tmux kill-session -t $SESSION 2>/dev/null
