#!/usr/bin/env bash
# enable a locale - requires sudo privileges
# usage:
# enable-locale.sh <locale> <encoding>
# Examples:
#   sudo enable-locale.sh en_US.UTF-8 UTF-8

usage() { echo "Usage: $0 <locale>\n$0 en_US.UTF-8 UTF-8" 1>&2; exit 1; }

NEW_LOCALE=$1
NEW_ENCODING=$2

if [ -z "$NEW_LOCALE" ] || [ -z "$NEW_ENCODING" ]; then
    usage
fi

# perl -pi -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
perl -pi -e "s/#\\s*$NEW_LOCALE\\s*$NEW_ENCODING/$NEW_LOCALE $NEW_ENCODING/g" /etc/locale.gen
local-gen "$NEW_LOCALE"
update-locale "$NEW_LOCALE"

