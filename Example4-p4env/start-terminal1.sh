#!/bin/bash
SESSION="Ex4-bash"
WORKDIR="/home/p4/p4environment/"
COMMAND="sudo python p4runner.py"

../utils/start-tmux.sh "$SESSION" "$WORKDIR" "$COMMAND"
