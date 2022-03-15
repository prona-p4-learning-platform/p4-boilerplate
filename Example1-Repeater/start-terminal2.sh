#!/bin/bash
SESSION="Ex1-2"
WORKDIR="/home/p4/p4-boilerplate/Example1-Repeater"
COMMAND="ls -al"

../utils/start-tmux.sh "$SESSION" "$WORKDIR" "$COMMAND"
