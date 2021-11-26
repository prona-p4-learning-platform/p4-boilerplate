#!/bin/bash
SESSION="Ex0-1"
WORKDIR="stop-terminal1.sh"
COMMAND="sudo mn -c"

../utils/stop-tmux.sh "$SESSION" "$WORKDIR" "$COMMAND"
