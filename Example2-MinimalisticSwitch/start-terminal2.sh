#!/bin/bash
SESSION="Ex2-2"
WORKDIR="/home/p4/p4-boilerplate/Example2-MinimalisticSwitch"
COMMAND="ls -al"

../utils/start-tmux.sh "$SESSION" "$WORKDIR" "$COMMAND"
