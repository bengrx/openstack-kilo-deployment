#!/bin/bash

if [ -z $4 ];then

  echo -e "Interfaces must be specified: man tun ext stg"
  exit 1
fi

for interface in $(ifconfig -a | grep -Eo "eth[0-3]" | tr '\n' ' ')
do
  if [ "$interface" != "$3" ];then

    echo -e "auto $interface\niface $interface inet dhcp" >/etc/network/interfaces.d/$interface.cfg

  else
    echo -e "auto $interface\niface $interface inet manual\n  up ip link set dev $interface up\n  down ip link set dev $interface down" >/etc/network/interfaces.d/$interface.cfg
  fi
  ifup $interface &>/dev/null
done
exit 0
