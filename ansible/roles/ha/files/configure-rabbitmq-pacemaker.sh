#!/bin/bash

if [ -z $1 ];then

  echo "Argument 1 must specify a VIP address"
  exit 1
fi

crm configure primitive p_ip_rabbitmq ocf:heartbeat:IPaddr2 \
  params ip="$1" cidr_netmask="24" \
    op monitor interval="10s"
crm configure primitive p_drbd_rabbitmq ocf:linbit:drbd \
  params drbd_resource="rabbitmq" \
    op start timeout="90s" \
    op stop timeout="180s" \
    op promote timeout="180s" \
    op demote timeout="180s" \
    op monitor interval="30s" role="Slave" \
    op monitor interval="29s" role="Master"
crm configure primitive p_fs_rabbitmq ocf:heartbeat:Filesystem \
  params device="/dev/drbd/by-res/rabbitmq/0" \
  directory="/var/lib/rabbitmq" \
  fstype="xfs" options="relatime" \
    op start timeout="60s" \
    op stop timeout="180s" \
    op monitor interval="60s" timeout="60s"
crm configure primitive p_rabbitmq ocf:rabbitmq:rabbitmq-server \
  params nodename="rabbit@localhost" \
  mnesia_base="/var/lib/rabbitmq" \
    op monitor interval="20s" timeout="10s"
crm configure group g_rabbitmq p_ip_rabbitmq p_fs_rabbitmq p_rabbitmq
crm configure ms ms_drbd_rabbitmq p_drbd_rabbitmq \
  meta notify="true" master-max="1" clone-max="2"
crm configure colocation c_rabbitmq_on_drbd inf: g_rabbitmq ms_drbd_rabbitmq:Master
crm configure order o_drbd_before_rabbitmq inf: ms_drbd_rabbitmq:promote g_rabbitmq:start
crm configure commit
exit 0
