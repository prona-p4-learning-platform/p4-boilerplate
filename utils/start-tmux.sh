#!/bin/bash
export TERM="xterm-256color"

SESSION=$1
WORKDIR=$2
COMMAND=$3

tmux start-server
{
  # if multiple clients/users are connected to tmux session, make sure that session is only created anre send-keys is only executed once, using shell-based semaphore
  flock -w 10 200
  tmux has-session -t $SESSION 2>/dev/null
  # if session does not exist, create a new independant session group and run initialization command
  if [ $? != 0 ] ; then
    tmux new-session -d -s $SESSION -n $SESSION
    tmux send-keys -t $SESSION "cd $WORKDIR" Enter "$COMMAND" Enter
  fi
  flock -u 200
} 200>/var/lock/.tmux-p4-boilerplate.exclusivelock

tmux attach-session -t $SESSION
