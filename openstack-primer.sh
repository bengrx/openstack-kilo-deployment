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

if [ ! -z $2 ];then
  printMessage "Got host filter: $2" "y"
  host_filter="--limit $2"
else
  host_filter=""
fi

if [ ! -z $1 ];then
  printMessage "Got role filter: $1" "y"
  playbook="$1"
fi

# Call ansible with different deployment options

if [ -z $playbook ];then

  printMessage "Server preparation play \"$playbook\" was not found in $BASE_DIR/primer/" "r"
  printMessage "Found the following possible target plays:" "b"
  ls -lrt $BASE_DIR/primer/*.yml | awk '{print " ",$9}' | sed 's/.*\///g' | sort | grep ".*" --color=auto
  echo $LINE_BREAK
  error "Please select one of the targets next time" "10"
fi

printMessage "Performing preparation profile $playbook against target(s)" "y"
sleep 3
ansible-playbook --extra-vars "remote_user=$REMOTE_USER" -i "$BASE_DIR/$CONFIG_FILE" "primer/$playbook" $host_filter


