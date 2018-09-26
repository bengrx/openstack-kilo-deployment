#!/bin/bash

BASE_DIR="$(dirname $0)"
REMOTE_USER="$(getProperty deployment_user)"

for file in "core-functions.sh"
do
  if [ ! -f "$BASE_DIR/src/$file" ];then echo "Could not find include file $BASE_DIR/src/$file"; exit 1
  else source "$BASE_DIR/src/$file"; fi
done
echo $LINE_BREAK
checkForConfig			# Perform some initial checks oo the config file
validateConfig         	 	# Validate config parameters within config file
setPasswords "validate"		# Set the password tokens in within config file

which ansible &>/dev/null

# Check for ansible installation
printMessage "Checking for a valid ansible installation" "y"

if [ $? != "0" ];then
  error "Ansible binary was not found. Please install it" "2"
else
  printMessage "Found ansible installation" "g"
fi
deployment_type="$(getProperty "deployment_type")"

if [ ! -z $1 ];then
  printMessage "Got host filter: $1" "y"
  host_filter="--limit $1"
else
  host_filter=""
fi

if [ ! -z $2 ];then
  printMessage "Got role filter: $2" "y"
  playbook="ansible/$2"
fi

# Call ansible with different deployment options
if [ "$deployment_type" == "basic" ];then

  if [ -z $playbook ];then playbook="ansible/basic-deployment.yml"; fi
  printMessage "Performing basic installation against target(s)" "y"; sleep 3
  ansible-playbook --extra-vars "remote_user=$REMOTE_USER" -i "$BASE_DIR/$CONFIG_FILE" "$playbook" $host_filter

elif [ "$deployment_type" == "ha" ];then

  if [ -z $playbook ];then playbook="ansible/ha-deployment.yml"; fi
  printMessage "Performing HA installation against target(s)" "y"; sleep 3
  ansible-playbook --extra-vars "remote_user=$REMOTE_USER" -i "$BASE_DIR/$CONFIG_FILE" "$playbook" $host_filter

else
  error "Unsupported deployment type: $deployment_type was specified" "9"
fi
