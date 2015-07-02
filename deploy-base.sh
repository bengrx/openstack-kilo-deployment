#!/bin/bash

if [ -z "$(which ansible)" ];then

  sudo apt-get install python-dev python-pip -y 2>/dev/null && sudo pip install ansible 2>/dev/null
fi

playbook="$(dirname $0)/ansible/base-deployment.yml"

if [ ! -f "$playbook" ];then

  echo -e "Playbook \"$playbook\" was not found"
  exit 1

else

  ansible-playbook "$playbook"
  exit 0
fi
