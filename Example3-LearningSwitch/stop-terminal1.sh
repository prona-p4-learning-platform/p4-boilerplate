#!/bin/bash
SESSION="Ex3-1"
WORKDIR="/home/p4/p4-boilerplate/Example3-LearningSwitch"
COMMAND="sudo killall p4run"

../utils/stop-tmux.sh "$SESSION" "$WORKDIR" "$COMMAND"
