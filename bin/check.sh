#!/usr/bin/env bash

command -v tmux >/dev/null 2>&1 || {
  printf >&2 "tmux is required to use this program. You can install tmux using the command:\napt-get install -y tmux\nAborting.\n"; exit 1;
}

