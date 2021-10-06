#!/bin/bash
SESSION="Ex2-1"
WORKDIR="/home/p4/p4-boilerplate/Example1-Repeater"
COMMAND="make clean"

../utils/stop-tmux.sh "$SESSION" "$WORKDIR" "$COMMAND"
