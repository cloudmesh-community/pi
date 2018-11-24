#!/usr/bin/env bash
# Just some bash reference notes

SEMI_SEP=";hi;there;james my buddy"

# Split on semicolon by translating ; to a space
# NOTE: this will also split on any spaces in the original
SEMI_ARRAY=(${SEMI_SEP//;/ })

echo len: ${#SEMI_ARRAY[@]}
echo 0: ${SEMI_ARRAY[0]}
echo 1: ${SEMI_ARRAY[1]}
echo 2: ${SEMI_ARRAY[2]}
echo 3: ${SEMI_ARRAY[3]}
echo 4: ${SEMI_ARRAY[4]}

# Using IFS is better, it doesn't split on internal spaces
IFS=';' read -ra IFS_SPLIT <<< "$SEMI_SEP"

# NOTE: IFS splits before and after a delimiter at the beginning and end
echo IFS_SPLIT len: ${#IFS_SPLIT[@]}
echo 0: ${IFS_SPLIT[0]}
echo 1: ${IFS_SPLIT[1]}
echo 2: ${IFS_SPLIT[2]}
echo 3: ${IFS_SPLIT[3]}

# The next line works but I'm not sure about unset IFS
# because it doesn't restore the previous value
# IFS=';'; IFS_SPLIT=($SEMI_SEP); unset IFS

SPACE_SEP="  this  is a sentence-separated by spaces  .  "
# Splint on spaces
SPACE_ARRAY=($SPACE_SEP)

echo len: ${#SPACE_ARRAY[@]}
echo 0 ${SPACE_ARRAY[0]}
echo 3 ${SPACE_ARRAY[3]}
echo 6 ${SPACE_ARRAY[6]}

for entry in "${SPACE_ARRAY[@]}"; do
  echo "$entry"
done
