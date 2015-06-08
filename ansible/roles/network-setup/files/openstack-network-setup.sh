#!/bin/bash

#NET_MAN_PRE="192.168.10."
#NET_MAN_GW="192.168.10.1"
#NET_MAN_DEV="eth1"
#NET_EXT_DEV="eth3"
#NET_TUN_PRE="192.168.20."
#NET_TUN_DEV="eth2"
#NET_STG_PRE="192.168.30."
#NET_STG_DEV="eth3"
#NET_COMMON_MASK="255.255.255.0"			# Deploment using this script enforces all net use the same mask
OUTPUT_FILE="/tmp/interfaces"

function printMessage
{
  if [ $# -gt 0 ];then

    echo -e "$1" >>$OUTPUT_FILE
  fi
}

if [ $(hostname -s | grep "^openstack-[a-z]*-[0-9]*$" | grep "net\|cpu\|ctl" | wc -l) -eq "0" ];then

  echo "hostname must be in the format openstack-role-index [ ctl cpu net ]"
  exit 1
fi

SHORT_NAME=$(hostname -s | grep "^openstack-[a-z]*-[0-9]*$" | grep "net\|cpu\|ctl" | sed -e 's/^openstack-//g')
NET_COMMON_POST=$(echo $SHORT_NAME | sed 's/[a-z]*-//g')
ROLE_NAME=$(echo $SHORT_NAME | sed 's/-[0-9]*//g')

if [ $NET_COMMON_POST -gt 50 ] || [ $NET_COMMON_POST -lt 1 ];then

  echo "This script supports up to 50 hosts per role"
  exit 1
fi

if [ ! -z $NET_DHCP_DEV ] && [ $(ip addr | grep -E "^[0-9]{1,2}: $NET_DHCP_DEV" | wc -l) -eq "1" ];then

  DHCP_DEV_LINE="# DHCP device\nauto $NET_DHCP_DEV\niface $NET_DHCP_DEV inet dhcp\n"
else

  DHCP_DEV_LINE=""
fi

if [ $ROLE_NAME == "ctl" ];then

  let NET_COMMON_POST=$NET_COMMON_POST+49

elif [ $ROLE_NAME == "cpu" ];then

  let NET_COMMON_POST=$NET_COMMON_POST+99

elif [ $ROLE_NAME == "net" ];then

  let NET_COMMON_POST=$NET_COMMON_POST+149
fi

echo -e "# Generated at $(date) by ansible\n" > $OUTPUT_FILE

printMessage "auto lo\niface lo inet loopback\n\nsource /etc/network/interfaces.d/*.cfg\n\n$DHCP_DEV_LINE"
printMessage "# Management interface\nauto $NET_MAN_DEV\niface $NET_MAN_DEV inet static"
printMessage "  address $NET_MAN_PRE$NET_COMMON_POST\n  netmask $NET_COMMON_MASK\n  gateway $NET_MAN_GW\n"
printMessage "# Storage network\nauto $NET_STG_DEV\niface $NET_STG_DEV inet static"
printMessage "  address $NET_STG_PRE$NET_COMMON_POST\n  netmask $NET_COMMON_MASK\n"

if [ $ROLE_NAME == "net" ] || [ $ROLE_NAME == "cpu" ];then				# Install tunnel network

  printMessage "# Tunnel interface\nauto $NET_TUN_DEV\niface $NET_TUN_DEV inet static"
  printMessage "  address $NET_TUN_PRE$NET_COMMON_POST\n  netmask $NET_COMMON_MASK\n"
fi

if [ $ROLE_NAME == "net" ];then							# Install external network

  printMessage "# External interface\nauto $NET_EXT_DEV\niface $NET_EXT_DEV inet manual"
  printMessage "  up ip link set dev $NET_EXT_DEV up\n  down ip link set dev $NET_EXT_DEV down\n"
fi

cp $OUTPUT_FILE /etc/network/interfaces
echo "Generated network configuration for host $(hostname -s)"
