#!/bin/bash

for role in "mon" "osd"
do
  playbook="$(dirname $0)/ansible/ceph-$role.yml"

  if [ ! -f "$playbook" ];then

    echo -e "Playbook \"$playbook\" was not found"
    exit 1

  else

    ansible-playbook "$playbook"
    exit 0
  fi
done
