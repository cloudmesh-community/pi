#!/usr/bin/env bash
# Tmux cluster ssh implementation
# usage:
# tmux-cssh.sh -c <num-columns> -u <ssh-userid> <hostlist>
# Examples:
#   tmux-cssh.sh -c 2 -u pi 10.0.0.[101-105]
#   tmux-cssh.sh -c 2 -u pi 10.0.0.[101-102] blue0[1-3] blue[20-25]

# NOTE in bash v3 (current on OS X) leading zeros are squashed in brace
# expansion so that
# tmux-cssh.sh blue[08-11]
# uses hosts "blue8 blue9 blue10 blue11"
# Current workaround is to specify the ones with leading zeros separately
# tmux-cssh.sh blue0[8-9] blue[10-11]
# will uses hosts "blue08 blue09 blue10 blue11"

TMUX_COLS=2
TMUX_SSH_USERID=

usage() { echo "Usage: $0 [-c <num-cols>] [-u <userid>] 10.0.0.[101-105]" 1>&2; exit 1; }

while getopts ":c:u:i" o; do
    case "${o}" in
        c)
            TMUX_COLS=${OPTARG}
            ;;
        i)
            INSTALL_DEPS=1
            ;;
        u)
            TMUX_SSH_USERID=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

# Check for missing dependencies

DEPENDENCIES=(tmux)

# Check for dependencies and abort if not installed
MISSING_DEPS=()
for dep in "${DEPENDENCIES[@]}"; do
  command -v "$dep" >/dev/null 2>&1 || {
    MISSING_DEPS+=("$dep")
  }
done

# Install missing dependencies using apt-get. This may not be appropriate for
# all dependencies so please update this if that is the case!
if [ ! -z $INSTALL_DEPS ]; then
  if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
    apt-get install -y "${MISSING_DEPS[@]}"
    APT_RETVAL=$?
    if [ $APT_RETVAL -eq 0 ]; then
      echo Dependencies installed. Please run the script again without the -i option.
    else
      echo Dependencies failed installation. Please see the output. May need to run the script using sudo.
    fi
  else
    echo No missing dependencies detected. Please run the script again without the -i option.
  fi
  exit 0
fi

if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
  printf >&2 "Missing dependencies:\\n"
  printf >&2 "    %s\\n" "${MISSING_DEPS[@]}"
  printf >&2 "You can install them using the command:\\n"
  printf >&2 "sudo %s/%s -i\\n" "$(dirname "$0")" "$0"
  printf >&2 "Aborting.\\n"
  exit 1
fi

HOSTS="$@"

if [ -z "${HOSTS}" ]; then
    usage
fi

# HOST="10.0.0.[101-105]"
# HOST="10.0.0.[101-102,103,105-108]"
HOSTS_BRE=$(echo "$HOSTS" | sed -E 's/\[([[:digit:]]+)-([[:digit:]]+)\]/{\1..\2}/g' |sed -E 's/([[:digit:]]+)-([[:digit:]]+)/{\1..\2}/g' | sed -E 's/\[([^]]+)\]/{\1}/')
# echo "HOSTS_BRE: $HOSTS_BRE"

TMUX_HOSTS=$(eval echo "$HOSTS_BRE")
echo Connecting to hosts: "$TMUX_HOSTS"

TMUX_SESSION="tmux-cssh"

tmux new-session -s $TMUX_SESSION -d
TMUX_RETVAL=$?

if [ $TMUX_RETVAL -ne 0 ]; then
  echo Error: tmux returned failure.
  echo If tmux returns a failure of invalid LC_ALL, LC_CTYPE or LANG please setup a valid UTF-8 locale \(such as en_US.utf8\) by running raspi-config or the provided enable-locale.sh script and trying again.
  exit 1
fi

col=0
first=1

function do_ssh {
  # tmux send-keys -t $TMUX_SESSION "echo ssh $1@$2" C-m
  if [ -z "$2" ]; then
    tmux send-keys -t $TMUX_SESSION "ssh $1" C-m
  else
    tmux send-keys -t $TMUX_SESSION "ssh $1@$2" C-m
  fi
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

tmux send-keys -t $TMUX_SESSION "echo default leader for tmux is Ctrl-B" C-m
tmux send-keys -t $TMUX_SESSION "echo leader : setw synchronize-panes to toggle synchronization" C-m
tmux setw synchronize-panes
tmux attach -t $TMUX_SESSION
