#!/bin/bash

if [ -z $1 ];then

  echo -e "First argument must specify deployment type [ minimal | ha | full ]"
  exit 2
fi

playbook="$(dirname $0)/ansible/$1-deployment.yml"

if [ ! -f "$playbook" ];then

  echo -e "Playbook \"$playbook\" was not found"
  exit 1

else

  ansible-playbook "$playbook"
  exit 0
fi
