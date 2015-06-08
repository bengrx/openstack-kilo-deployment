#!/bin/bash
LINE_BREAK="----------------------------------------------------------------------------------------------------------------"

function printMessage
{
if [ ! -z $2 ];then

  export GREP_COLOR="$2"
  echo -e "$1" | grep ".*" --color=auto
  echo "$LINE_BREAK"

elif [ ! -z $1 ];then

  echo -e "$1\n$LINE_BREAK"
fi
}
echo "$LINE_BREAK"

if [ -z $1 ];then

  printMessage "First argument must specify the username to use" "0;31"
  exit 1
fi

if [ ! -f $(dirname $0)/boot_hosts ];then

  printMessage "$(dirname $0)/boot_hosts was not found" "0;31"
  exit 1
fi

hosts=$(cat $(dirname $0)/boot_hosts | grep -E "([0-9]{1,3}.){3}[0-9]{1,3}" | awk '{print $2}')

for host in $hosts
do
  ping_status="$(ping $host -c 1 -q | grep "1 rec" | wc -l)"
  ssh_status="$(nmap $host -p 22 | grep "22/tcp open" | wc -l)"

  if [ "$ssh_status" == "1" ];then

    ssh-keyscan $host 2>&1>/dev/null
    ssh-copy-id $1@$host 2>&1>/dev/null
  fi
  ssh_command_status="$(ssh $1@$host 'pwd' | grep "/$1" | wc -l)"

  echo -e "$LINE_BREAK"
  printMessage "$host" "0;32"
  printMessage "ICMP Test\t:\t[ $ping_status ]" "0;33"
  printMessage "SSH Port Test\t:\t[ $ssh_status ]" "0;33"
  printMessage "SSH as $1\t:\t[ $ssh_command_status ]" "0;33"
  sudo_detected="$(ssh $1@$host 'sudo ifconfig' | grep -E "([0-9]{1,3}.){3}[0-9]{1,3}" | wc -l)"

  if [ "$sudo_detected" == "0" ];then

    echo -e "$LINE_BREAK"
    printMessage "Please add the user \"$1\" to the sudoers file via visudo;" "0;32"
    printMessage "$1 ALL=(ALL) NOPASSWD:ALL" "0;31"
    ssh $1@$host
  else
    printMessage "Sudo Test\t:\t[ 1 ]" "0;33"
  fi
done

read -p "Would you like to continue and deploy networking configuration? [Y / n]: " deploy_network
echo -e "$LINE_BREAK"

if [ "$deploy_network" == "Y" ] || [ "$deploy_network" == "y" ];then

  printMessage "Attempting to deploy network using ./openstack-network.sh" "0;32"

  if [ -f $(dirname $0)/openstack-network.sh ];then

    ./openstack-network.sh

  else
    printMessage "./openstack-network.sh was not found" "0;31"
  fi

else

  printMessage "Not attempting to deploy network using ./openstack-network.sh" "0;31"
fi

read -p "Would you like to continue and deploy openstack? [Y / n]: " deploy_openstack
echo -e "$LINE_BREAK"


if [ "$deploy_openstack" == "Y" ] || [ "$deploy_openstack" == "y" ];then

  printMessage "Attempting to deploy openstack using ./openstack-deploy.sh" "0;32"

  if [ -f $(dirname $0)/openstack-deploy.sh ];then

    ./openstack-deploy.sh

  else
    printMessage "./openstack-deploy.sh was not found" "0;31"
  fi

else

  printMessage "Not attempting to deploy openstack using ./openstack-deploy.sh" "0;31"
fi
exit 0
