#!/usr/bin/env bash

# List of dependencies to check for
DEPENDENCIES=(tmux fake-thing something-else i-made_this_up)
# DEPENDENCIES=(tmux git vim)

# Check for dependencies and abort if not installed
MISSING_DEPS=()
for dep in "${DEPENDENCIES[@]}"; do
  command -v "$dep" >/dev/null 2>&1 || {
    MISSING_DEPS+=("$dep")
  }
done

# Simple getopts setup. Replace or expand as needed. This script only expects
# the INSTALL_DEPS variable set to any value to signal to install dependencies.
while getopts ":i" o; do
    case "${o}" in
        i)
            INSTALL_DEPS="1"
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

# Install missing dependencies using apt-get. This may not be appropriate for
# all dependencies so please update this if that is the case!
if [ ! -z $INSTALL_DEPS ]; then
  if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
    echo apt-get install -y "${MISSING_DEPS[@]}"
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
  printf >&2 "You can install them using the command:\\n%s -i\\nAborting.\\n" "$0"
  exit 1
fi



