#!/bin/bash
LINE_BREAK="-------------------------------------------------------------------------------------------"
BASE_PATH="$(dirname $0)"

echo "$LINE_BREAK"
read -p "Are you sure you want to reset the all local configuration paramters? [Y/n]?: " input 
echo -e "$LINE_BREAK"

if [ "$input" == "y" ] || [ "$input" == "Y" ];then

  echo -e "Resetting OpenStack configuration"
  BASE_PATH="$BASE_PATH"
  rm -f "$BASE_PATH/hosts" 2>&1
  echo " " >"$BASE_PATH/authorized_keys" 2>&1>/dev/null
  rm -f "$BASE_PATH/ansible.cfg" 2>&1>/dev/null

else

  echo -e "Not resetting OpenStack configuration"
fi

echo -e "$LINE_BREAK"
touch $BASE_PATH/*.sh

