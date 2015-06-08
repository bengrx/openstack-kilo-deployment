#!/bin/bash
LINE_BREAK="----------------------------------------------------------------------------------------------------------------"

echo "$LINE_BREAK"
echo "Bootserver Configuration" | grep -E ".*" --color=auto
sudo ./bootserver-config.sh
echo "Openstack Configuration" | grep -E ".*" --color=auto
./openstack-config.sh
echo "Bootserver Deployment" | grep -E ".*" --color=auto
echo "$LINE_BREAK"
./bootserver-deploy.sh
echo "$LINE_BREAK"
echo "Openstack Setup" | grep -E ".*" --color=auto
./openstack-setup.sh openstack

