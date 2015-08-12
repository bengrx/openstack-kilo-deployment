#!/bin/bash

if [ -z $1 ];then

  echo "Argument 1 must specify a VIP address"
  exit 1
fi

crm configure property stonith-enabled=false
crm configure primitive p_ip_mysql ocf:heartbeat:IPaddr2 params ip="$1" cidr_netmask="24" op monitor interval="30s"
crm configure primitive p_drbd_mysql ocf:linbit:drbd params drbd_resource="mysql" op start timeout="90s" op stop timeout="180s" op promote timeout="180s" op demote timeout="180s" op monitor interval="30s" role="Slave" op monitor interval="29s" role="Master"
crm configure primitive p_fs_mysql ocf:heartbeat:Filesystem params device="/dev/drbd/by-res/mysql" directory="/var/lib/mysql" fstype="xfs" options="relatime" op start timeout="60s" op stop timeout="180s" op monitor interval="60s" timeout="60s"
crm configure primitive p_mysql ocf:heartbeat:mysql params additional_parameters="--bind-address=$1" config="/etc/mysql/my.cnf" pid="/var/run/mysqld/mysqld.pid" socket="/var/run/mysqld/mysqld.sock" log="/var/log/mysql/mysqld.log" op monitor interval="20s" timeout="10s" op start timeout="120s" op stop timeout="120s"
crm configure group g_mysql p_ip_mysql p_fs_mysql p_mysql
crm configure ms ms_drbd_mysql p_drbd_mysql meta notify="true" clone-max="2"
crm configure colocation c_mysql_on_drbd inf: g_mysql ms_drbd_mysql:Master
crm configure order o_drbd_before_mysql inf: ms_drbd_mysql:promote g_mysql:start
crm configure commit
