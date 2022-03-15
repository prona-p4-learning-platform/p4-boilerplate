#!/bin/bash
SESSION="Ex0-2"
WORKDIR="/home/p4/p4-boilerplate/Example0-SDN-Intro"
COMMAND="ls -al"

../utils/start-tmux.sh "$SESSION" "$WORKDIR" "$COMMAND"
