#!/bin/bash
SESSION="Ex1-1"
WORKDIR="/home/p4/p4-boilerplate/Example1-Repeater"
COMMAND="make clean && make"

../utils/start-tmux.sh "$SESSION" "$WORKDIR" "$COMMAND"
