#!/bin/bash


for host in $(cat /etc/hosts | grep -v "127.0.0" | grep -E "([0-9]{1,3}.){3}.[0-9]{1,3}" | awk '{print $2}' | tr '\n' ' ' )
do

  ping_status="$(ping $host -c 1 -q | grep "1 received" | wc -l)"

  if [ "$ping_status" == "0" ];then

    echo "Ping to $host failed"
    exit 1
  fi
done

exit 0
