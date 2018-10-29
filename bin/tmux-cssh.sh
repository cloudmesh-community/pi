#!/usr/bin/env bash

TMUX_COLS=$1
TMUX_SSH_USERID=$2
shift
shift
HOSTS="$@"
# HOST="10.0.0.[101-105]"
# HOST="10.0.0.[101-102,103,105-108]"
HOSTS_BRE=$(echo "$HOSTS" | sed -E 's/\[([[:digit:]]+)-([[:digit:]]+)\]/{\1..\2}/g' |sed -E 's/([[:digit:]]+)-([[:digit:]]+)/{\1..\2}/g' | sed -E 's/\[([^]]+)\]/{\1}/')

TMUX_HOSTS=$(eval echo "$HOSTS_BRE")

echo "$TMUX_HOSTS"

TMUX_SESSION="tmux-cssh"

tmux new-session -s $TMUX_SESSION -d
# tmux new-window -t $TMUX_SESSION
# tmux send-keys -t $TMUX_SESSION 'ls -lh' C-m

col=0
first=1

function do_ssh {
  # tmux send-keys -t $TMUX_SESSION "echo ssh $1@$2" C-m
  tmux send-keys -t $TMUX_SESSION "ssh $1@$2" C-m
}

# echo Before the first one: "$TMUX_HOSTS"
for HOST in $TMUX_HOSTS ; do
  if [ "$first" -eq 1 ]
  then
    first=0
    # echo Create the new window
    # echo $col "$HOST"
    do_ssh "$TMUX_SSH_USERID" "$HOST"
  else
    if [ "$col" -lt "$TMUX_COLS" ]
    then
      # echo Split the horizontal
      # echo $col "$HOST"
      tmux split-window -h -t $TMUX_SESSION
      do_ssh "$TMUX_SSH_USERID" "$HOST"
    else
      # echo Split the vertical
      col=0
      # echo $col "$HOST"
      tmux select-pane -t 1.1
      tmux split-window -vf -t $TMUX_SESSION
      do_ssh "$TMUX_SSH_USERID" "$HOST"
    fi
  fi
  ((col++))
done

tmux send-keys -t $TMUX_SESSION "echo leader : setw synchronize-panes to toggle synchronization" C-m
tmux setw synchronize-panes
tmux attach -t $TMUX_SESSION
