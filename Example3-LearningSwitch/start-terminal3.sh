#!/bin/bash
SESSION="Ex3-3"
WORKDIR="/home/p4/p4-boilerplate/Example3-LearningSwitch"
COMMAND="ls -al"

../utils/start-tmux.sh "$SESSION" "$WORKDIR" "$COMMAND"
