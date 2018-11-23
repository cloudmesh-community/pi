#!/usr/bin/env bash
# enable a locale - requires sudo privileges
# usage:
# enable-locale.sh <locale> <encoding>
# Examples:
#   sudo enable-locale.sh en_US.UTF-8 UTF-8

usage() { printf >&2 "Usage: %s <locale> <encoding>\\n%s en_US.UTF-8 UTF-8\\n" "$0" "$0"; exit 1; }

NEW_LOCALE=$1
NEW_ENCODING=$2

if [ -z "$NEW_LOCALE" ] || [ -z "$NEW_ENCODING" ]; then
    usage
fi

if [[ -e /etc/locale.gen && ! -w /etc/locale.gen ]] || [ ! -w /etc ]; then
  echo "This script must be run with root privileges to update /etc/locale.gen." >&2
  printf >&2 "sudo %s\\n" "$(realpath --relative-to="$(pwd)" "$0")"
  exit 1
fi

# perl -pi -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
perl -pi -e "s/#\\s*$NEW_LOCALE\\s*$NEW_ENCODING/$NEW_LOCALE $NEW_ENCODING/g" /etc/locale.gen
locale-gen "$NEW_LOCALE"
update-locale "$NEW_LOCALE"

