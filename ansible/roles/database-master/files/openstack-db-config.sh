#!/bin/bash

OS_DBS="keystone glance nova neutron cinder heat"

if [ -z $1 ];then

  echo -e "Argument 1 must specify an openstack database [$OS_DBS]"
  exit 1

elif [ -z $2 ];then

  echo -e "Argument 2 must specify an openstack database password"
  exit 1

elif [ $(echo $OS_DBS | grep -w $1 | wc -l) == "1" ];then

  echo -e "Creating \"$1\" database"
  mysql -e "CREATE DATABASE IF NOT EXISTS $1";
  mysql -e "GRANT ALL PRIVILEGES ON $1.* TO '$1'@'%' IDENTIFIED BY '$2'";
  mysql -e "GRANT ALL PRIVILEGES ON $1.* TO '$1'@'localhost' IDENTIFIED BY '$2'";

else
  echo -e "Openstack database name \"$1\" is not valid"
  exit 1
fi
