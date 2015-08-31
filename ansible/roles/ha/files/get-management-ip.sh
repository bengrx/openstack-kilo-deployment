#!/bin/bash
IP_REGEX="([0-9]{1,3}.){3}[0-9]{1,3}"

if [ -z $1 ];then

  echo "First argument must specify an interface"
  exit 1

elif [ "$(ifconfig $1 &>/dev/null && echo $?)" != 0 ];then

  echo "First argument did not specify a valid interface"
  exit 2

else

  echo "$(ifconfig $1 | grep -Eo "inet addr:$IP_REGEX" | grep -Eo "([0-9]{1,3}.){3}")0"
fi
