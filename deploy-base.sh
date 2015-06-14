#!/bin/bash


playbook="$(dirname $0)/ansible/network-setup.yml"

if [ ! -f "$playbook" ];then

  echo -e "Playbook \"$playbook\" was not found"
  exit 1

else

  ansible-playbook "$playbook"
  exit 0
fi
