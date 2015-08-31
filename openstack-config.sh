#!/bin/bash
BASE_DIR="$(dirname $0)"

for file in "core-functions.sh"
do
  if [ ! -f "$BASE_DIR/src/$file" ];then echo "Could not find include file $BASE_DIR/src/$file"; exit 1
  else source "$BASE_DIR/src/$file"; fi
done
echo $LINE_BREAK

checkForConfig			# Perform some initial checks oo the config file
validateConfig			# Validate config parameters within config file
setPasswords			# Set the password tokens in within config file
