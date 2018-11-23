#!/usr/bin/env bash

# List of dependencies to check for
dependencies=(tmux fake-thing something-else i-made_this_up)
# dependencies=(tmux git vim)

# Check for dependencies and abort if not installed
missing_deps=()
for dep in "${dependencies[@]}"; do
  command -v "$dep" >/dev/null 2>&1 || {
    missing_deps+=("$dep")
  }
done

# Simple getopts setup. Replace or expand as needed. This script only expects
# the install_deps variable set to any value to signal to install dependencies.
while getopts ":i" o; do
    case "${o}" in
        i)
            install_deps="1"
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

# Install missing dependencies using apt-get. This may not be appropriate for
# all dependencies so please update this if that is the case!
if [ ! -z $install_deps ]; then
  if [ ${#missing_deps[@]} -ne 0 ]; then
    echo apt-get install -y "${missing_deps[@]}"
    echo Dependencies installed. Please run the script again without the -i option.
  else
    echo No missing dependencies detected. Please run the script again without the -i option.
  fi
  exit 0
fi

if [ ${#missing_deps[@]} -ne 0 ]; then
  printf >&2 "Missing dependencies:\\n"
  printf >&2 "    %s\\n" "${missing_deps[@]}"
  printf >&2 "You can install them using the command:\\n$0 -i\\nAborting.\\n"
  exit 1
fi



