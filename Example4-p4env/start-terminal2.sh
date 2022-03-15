#!/bin/bash
SESSION="Ex4-bash2"
WORKDIR="/home/p4/p4environment/"
COMMAND="ls -al"

../utils/start-tmux.sh "$SESSION" "$WORKDIR" "$COMMAND"
