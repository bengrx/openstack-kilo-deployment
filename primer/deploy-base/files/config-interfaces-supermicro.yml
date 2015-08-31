#!/bin/bash
for interface in $(ifconfig -a | grep -Eo "eth[0-3]" | tr '\n' ' ')
do
  if [ "$interface" != "eth3" ];then

    echo -e "auto $interface\niface $interface inet dhcp" >/etc/network/interfaces.d/$interface.cfg
  else
    echo -e "auto $interface\niface $interface inet manual\n  up ip link set dev $interface up\n  down ip link set dev $interface down" >/etc/network/interfaces.d/$interface.cfg
  fi
  ifup $interface 2>/dev/null
done

