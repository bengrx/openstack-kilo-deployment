LINE_BREAK="+-----------------------------------------------------------------------------+"
BASE_DIR="$(dirname $0)"
CONFIG_FILE="openstack.cfg"
CONFIG_TEMPLATE=".openstack.example"
REGEX_IP="([0-9]{1,3}.){3}[0-9]{1,3}"

function error
{
  if [ ! -z $2 ];then
    printMessage "$1" "r"
    exit $2

  else
    printMessage "Unhandled error: $1" "r"
    exit 1
  fi
}

function setTextColour
{
  if [ ! -z $1 ];then

    if [ "$1" == "g" ];then
      export GREP_COLOR="00;32"

    elif [ "$1" == "r" ];then
      export GREP_COLOR="00;31"

    elif [ "$1" == "y" ];then
      export GREP_COLOR="00;33"

    elif [ "$1" == "b" ];then
      export GREP_COLOR="00;34"

    elif [ "$1" == "bold" ];then
      export GREP_COLOR="00;30"
    fi
  fi
}
function printMessage
{
  if [ ! -z "$1" ];then

    setTextColour $2
    echo -e " $1" | grep ".*" --color=auto
    echo "$LINE_BREAK"
  fi
}
function checkForConfig
{
  printMessage "Checking for configuration file $BASE_DIR/$CONFIG_FILE" "y"

  if [ -f "$BASE_DIR/$CONFIG_FILE" ];then
    printMessage "Found configuration file at: $BASE_DIR/$CONFIG_FILE. Will now vaildate it" "g"

  else
    cp $BASE_DIR/$CONFIG_TEMPLATE $BASE_DIR/$CONFIG_FILE &>/dev/null
    error "Could not find configuration at: $BASE_DIR/$CONFIG_FILE. Generating it" "2"
  fi
}

function validateGroupHasMember
{
  if [ -f $BASE_DIR/$CONFIG_FILE ] && [ ! -z $1 ];then
    members="$(cat $BASE_DIR/$CONFIG_FILE | grep -A1 "\[$1\]" | grep -v "\[$1\]\|^#" | grep -v "\[\|^$" | grep "$IP_REGEX\|^[0-9a-Z]*" | wc -l)"

    if [ $members != "0" ];then
      printMessage "Host group $1 has $members member(s)" "g"
    else
      error "Host group $1 has no members. Please define one" "3"
    fi
  else
    error "Could not find configuration at: $BASE_DIR/$CONFIG_FILE" "2"
  fi
}

function validateConfig
{
  # These roles have to be defined for a functional system
  validateGroupHasMember "openstack-ctl-master-node"
  validateGroupHasMember "openstack-net-master-node"
  validateGroupHasMember "openstack-cpu-node"
  setProperty "deployment_type" read "$(getProperty deployment_type)"
  setProperty "deployment_user" read "$(getProperty deployment_user)"
  deployment="$(cat $BASE_DIR/$CONFIG_FILE | grep deployment_type | grep ha | wc -l | sed 's/0/basic/g' | sed 's/1/ha/g')"
  setProperty "openstack_ctl_master" "$(getFirstMember openstack-ctl-master-node)"
  setProperty "openstack_net_master" "$(getFirstMember openstack-net-master-node)"
  setProperty "ctl_vip" "$(getFirstMember openstack-ctl-master-node)"
  setProperty "net_vip" "$(getFirstMember openstack-net-master-node)"

  if [ $deployment == "ha" ];then

    # These roles have to be defined for a functional HA system
    validateGroupHasMember "openstack-ctl-slave-node"
    validateGroupHasMember "openstack-net-slave-node"
    setProperty "openstack_ctl_slave" "$(getFirstMember openstack-ctl-slave-node)"
    setProperty "openstack_net_slave" "$(getFirstMember openstack-net-slave-node)"
    setProperty "ctl_vip" read "$(getProperty ctl_vip)"
    setProperty "net_vip" read "$(getProperty net_vip)"
    setProperty "ha_mysql_storage_device" read "$(getProperty ha_mysql_storage_device)"
    setProperty "ha_rabbitmq_storage_device" read "$(getProperty ha_rabbitmq_storage_device)"
    setProperty "ha_base_device" read "$(getProperty ha_base_device)"
  fi

  setProperty "openstack_region" read "$(getProperty openstack_region)"
  setProperty "boot_domain" read "$(getProperty boot_domain)"
  setProperty "cinder_storage_device" read "$(getProperty cinder_storage_device)"
  setProperty "net_man_dev" read "$(getProperty net_man_dev)"
  setProperty "net_tun_dev" read "$(getProperty net_tun_dev)"
  setProperty "net_ext_dev" read "$(getProperty net_ext_dev)"
  setProperty "net_stg_dev" read "$(getProperty net_stg_dev)"
  setProperty "external_net_cidr" read "$(getProperty external_net_cidr)"
  setProperty "floating_ip_start" read "$(getProperty floating_ip_start)"
  setProperty "floating_ip_end" read "$(getProperty floating_ip_end)"
  setProperty "external_net_gw" read "$(getProperty external_net_gw)"
  setProperty "tenant_net_cidr" read "$(getProperty tenant_net_cidr)"
  setProperty "tenant_net_gw" read "$(getProperty tenant_net_gw)"
}

function getFirstMember
{
  if [ ! -f $BASE_DIR/$CONFIG_FILE ];then

    error "Could not find configuration at: $BASE_DIR/$CONFIG_FILE" "2"

  elif [ -z $1 ];then

    error "Property identifier was not specified" "5"

  else
    cat $BASE_DIR/$CONFIG_FILE | grep -A1 "\[$1\]" | grep -v "\[$1\]\|^#" | grep -v "\[\|^$" | grep "$IP_REGEX\|^[0-9a-Z]*" | head -n 1

  fi

}

function setProperty
{
  if [ ! -f $BASE_DIR/$CONFIG_FILE ];then

    error "Could not find configuration at: $BASE_DIR/$CONFIG_FILE" "2"

  elif [ -z $1 ];then

    error "Property identifier not specified" "5"

  elif [ -z $2 ];then

    error "No value was set to variable: $1" "6"

  elif [ $2 == "read" ];then

    printMessage "Please provide value for $1: ($3)" "b"
    read -p " value: " value

    if [ -z $value ] && [ ! -z $3 ];then

      echo -e "$LINE_BREAK\n $3 (default value)" | grep ".*"
      value="$3"

    elif [ -z $value ];then

      value="undefined"
    fi
    echo $LINE_BREAK

  elif [ $2 == "password" ];then

    printMessage "Please provide a password value for $1. Blank => random" "b"
    read -p " $1 : " value

    if [ -z $value ];then

      value="$(openssl rand -hex 10)"
    fi
    echo $LINE_BREAK

  else

    value="$2"
  fi
  property_found="$(cat $BASE_DIR/$CONFIG_FILE | grep $1 | wc -l)"

  if [ "$value" == "undefined" ];then

    error "Property: $1 can't be left undefined" "9"

  elif [ $property_found != "1" ];then

    error "Propery: $1 was not found" "6"

  else

    current_value="$(cat $BASE_DIR/$CONFIG_FILE | grep $1)"
    pre=$(echo -e "$current_value" | sed 's/=.*//g')
    post=$(echo -e "$current_value" | sed 's/.*=//g')
    sed -i "s,$current_value,$pre=\t$value,g" $BASE_DIR/$CONFIG_FILE
    printMessage "Set property: $1 to value: $value" "g"
  fi
}

function setPasswords
{
  if [ ! -f $BASE_DIR/$CONFIG_FILE ];then

    error "Could not find configuration at: $BASE_DIR/$CONFIG_FILE" "2"

  else

    credentials="$(cat $BASE_DIR/$CONFIG_FILE | grep "_pass\|_dbpass\|_token\|_secret" | awk '{print $1}' | tr '\n' ' ')"

    for cred in $credentials
    do
      if [ ! -z $1 ] && [ $1 == "validate" ];then

        if [ "$(getProperty "$cred")" != "default" ];then

          printMessage "Property value has already been set for $cred" "g"

        else
          setProperty "$cred" password
        fi

      else
        setProperty "$cred" password
      fi
    done
  fi
}

function getProperty
{
  if [ -z $1 ];then
    error "Not property name was specified" "7"
  fi
  property_found="$(cat $BASE_DIR/$CONFIG_FILE | grep "$1" | wc -l)"

  if [ $property_found != "1" ];then

    error "Could not find determine value for property: $1" "8"
  fi

   value="$(cat $BASE_DIR/$CONFIG_FILE | grep "$1" | sed 's/.*=\t//g')"

  if [ -z $value ];then

    error "Propeerty: $1 has no value defined"
  fi
  echo "$value"
}
