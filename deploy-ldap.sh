#!/bin/bash
EXPECTED_ARGUMENTS="url user password suffix use_dumb_member allow_subtree_delete"
CONFIG_FILE="$(dirname $0)/ldap_keystone"

if [ ! -f $CONFIG_FILE ];then

  echo -e "Config file was not found at $CONFIG_FILE. Generating sample config at $CONFIG_FILE"
  echo -e "url = ldap://localhost\nuser = dc=Manager,dc=example,dc=org\npassword = samplepassword\nsuffix = dc=example,dc=org\nuse_dumb_member = False\nallow_subtree_delete = False" >$CONFIG_FILE

  exit 1
fi

for argument in $EXPECTED_ARGUMENTS
do
  if [ "$(cat $CONFIG_FILE | grep "$argument *=" | wc -l)" == 0 ];then

    echo -e "Argument \"$argument\" was not found in $CONFIG_FILE"
    exit 2
  fi
done
