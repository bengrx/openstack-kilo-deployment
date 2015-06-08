#!/bin/bash

if [ -z $CEILOMETER_DBPASS ];then

  echo "Ceilometer DB pass was not specified"
  exit 1
fi

mongo --host $1 --eval 'db = db.getSiblingDB("ceilometer");db.addUser({user: "ceilometer",pwd: "$CEILOMETER_DBPASS",roles: [ "readWrite", "dbAdmin" ]})'
