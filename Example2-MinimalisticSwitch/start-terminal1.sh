#!/bin/bash
SESSION="Ex2-1"
WORKDIR="/home/p4/p4-boilerplate/Example2-MinimalisticSwitch"
COMMAND="make clean && make"

../utils/start-tmux.sh "$SESSION" "$WORKDIR" "$COMMAND"
