#!/bin/bash
LINE_BREAK="----------------------------------------------------------------------------------------------------------------"
BASE_PATH="$(dirname $0)"
OUTPUT_HOSTS="hosts"
SALT_STRING="SWjY1pfQ"

function getValue
{
  echo -e "$LINE_BREAK"; read -p "Please set value for $1 [ $2 ] : " value

  if [ -z $value ];then
    value=$2
  fi

  echo -e "SET: $1 = $value" | grep -E ".*" --colour=auto
  echo -e "$1$3=\t$value">>$OUTPUT_HOSTS

  if [ "$1" == "deployment_user" ];then

    echo -e "[defaults]\nremote_user\t\t=\t$value\nrecord_host_keys\t=\tFalse\nhostfile\t\t=\thosts\ninventory\t\t=\thosts" >"$BASE_PATH/ansible.cfg"
  fi
}

function getUnixPass
{
  unset value
  echo -e "$LINE_BREAK";
  prompt="Please set value for $1 [ $2 ] : "
  while IFS= read -p "$prompt" -r -s -n 1 char
  do
      if [[ $char == $'\0' ]]
      then
          break
      fi
      prompt='*'
      value+="$char"
  done

  if [ -z $value ];then
    value=$2
  fi

  passwordHash="$(openssl passwd -1 -salt "$SALT_STRING" $value)"
  echo -e "\nSET: $1 = $passwordHash" | grep -E ".*" --colour=auto
  echo -e "$1$3=\t$passwordHash">>$OUTPUT_HOSTS
}

function generatePassword
{
    echo -e "$LINE_BREAK"
    echo -e "SET: $1 = $(openssl rand -hex 10)" | grep -E ".*" --color=auto
    echo -e "$1$3=\t$(openssl rand -hex 10)">>$OUTPUT_HOSTS
}

if [ ! -f "$BASE_PATH/boot_hosts" ];then

  echo -e "# MAC Address\t\tHostname\t\tIP Address\naa:aa:aa:aa:aa:aa\topenstack-ctl-01\t192.168.10.50\nbb:bb:bb:bb:bb:bb\topenstack-cpu-01\t192.168.10.100\ncc:cc:cc:cc:cc:cc\topenstack-net-01\t192.168.10.150">"$BASE_PATH/boot_hosts"
fi

if [ ! -f "$BASE_PATH/authorized_keys" ] && [ -f "/home/$(whoami)/.ssh/id_rsa.pub" ];then

  cat "/home/$(whoami)/.ssh/id_rsa.pub" >"$BASE_PATH/authorized_keys"
fi

echo -e "[deployment-node]\n127.0.0.1">$OUTPUT_HOSTS

for role in "openstack-ctl-master" "openstack-cpu" "openstack-net" "openstack-ctl-slave"

do
  echo -e "\n[$role-nodes]">>$OUTPUT_HOSTS

  if [ $role == "openstack-ctl-master" ];then

    ctl_master=$(cat $BASE_PATH/boot_hosts | grep $(echo $role | sed 's/-master//g' ) | awk '{print $3}' | head -n 1)
    echo -e "$ctl_master" >>$OUTPUT_HOSTS

  elif [ $role == "openstack-ctl-slave" ];then

    cat $BASE_PATH/boot_hosts | grep $(echo $role | sed 's/-slave//g' ) | awk '{print $3}' | tail -n +2>>$OUTPUT_HOSTS

  else

    cat $BASE_PATH/boot_hosts | grep $(echo $role) | awk '{print $3}'>>$OUTPUT_HOSTS
  fi
done

# Generate the aggreagte group
echo -e "\n[openstack-all-nodes:children]\nopenstack-ctl-master-nodes\nopenstack-ctl-slave-nodes\nopenstack-cpu-nodes\nopenstack-net-nodes">>$OUTPUT_HOSTS
echo -e "\n[openstack-all-nodes:vars]\nopenstack_ctl_master\t\t=\t$ctl_master">>$OUTPUT_HOSTS
export GREP_COLOR="01;32"
echo -e "$LINE_BREAK"
echo -e "Set General OpenStack Deployment Configuration" | grep -E ".*" --color=auto
export GREP_COLOR="01;33"

# Get basic deployment vars
getValue net_man_dev eth0 "\t\t\t"
getValue net_tun_dev eth1 "\t\t\t"
getValue net_ext_dev eth2 "\t\t\t"
getValue net_stg_dev eth3 "\t\t\t"
getValue openstack_region home "\t\t"
getValue default_email_address bengreco@linux.com "\t\t"
getValue default_ntp_server 0.uk.pool.ntp.org "\t\t"
getValue cinder_storage_device sdb "\t\t"
export GREP_COLOR="01;32"
echo -e "$LINE_BREAK"
echo -e "Seting Up OpenStack Authentication Tokens" | grep -E ".*" --color=auto
export GREP_COLOR="01;33"

#Generate passwords
generatePassword rabbit_pass rabbitpass "\t\t\t"
generatePassword keystone_admin_token 35f3beeab9b29c2be91d "\t\t"
generatePassword keystone_admin_pass keystoneadmin "\t\t"
generatePassword keystone_demo_pass keystonedemo "\t\t"
generatePassword keystone_dbpass keystonedbpass "\t\t\t"
generatePassword glance_dbpass glancedbpass "\t\t\t"
generatePassword nova_dbpass novadbpass "\t\t\t"
generatePassword neutron_dbpass neutrondbpass "\t\t\t"
generatePassword dash_dbpass dashpass "\t\t\t"
generatePassword heat_dbpass heatdbpass "\t\t\t"
generatePassword swift_dbpass swiftdbpass "\t\t\t"
generatePassword cinder_dbpass cinderdbpass "\t\t\t"
generatePassword ceilometer_dbpass ceilometerdbpass "\t\t"
generatePassword neutron_metadata_secret neutronsecret "\t\t"
generatePassword telemetry_secret 83aba578d99a8422f9a8 "\t\t"
generatePassword glance_pass glancepass "\t\t\t"
generatePassword nova_pass novapass "\t\t\t"
generatePassword neutron_pass neutronpass "\t\t\t"
generatePassword cinder_pass cinderpass "\t\t\t"
generatePassword heat_pass heatpass "\t\t\t"
generatePassword heat_domain_pass heatdomainpass "\t\t"
generatePassword swift_pass swiftpass "\t\t\t"
generatePassword ceilometer_pass ceilometerpass "\t\t\t"
export GREP_COLOR="01;32"
echo -e "$LINE_BREAK"
echo -e "Set Deployment Environment Configuration" | grep -E ".*" --color=auto
echo -e "\n[deployment-node:vars]">>$BASE_PATH/$OUTPUT_HOSTS
export GREP_COLOR="01;33"

# Get deployment host vars
getValue deployment_user openstack "\t\t\t"
getUnixPass deployment_user_pass openstack "\t\t"
getValue public_interface wlan0 "\t\t"
getValue boot_interface eth0 "\t\t\t"
getValue boot_domain home "\t\t\t"
getValue boot_interface_address 192.168.10.1 "\t\t"
getValue boot_dhcp_range_begin 192.168.10.10 "\t\t"
getValue boot_dhcp_range_end 192.168.10.40 "\t\t"
getValue boot_mask 255.255.255.0 "\t\t\t"
getValue boot_dhcp_lease_time_hours 24 "\t"
echo -e "remote_netboot_image_path\t=\thttp://archive.ubuntu.com/ubuntu/dists/trusty-updates/main/installer-amd64/current/images/utopic-netboot/netboot.tar.gz">>$BASE_PATH/$OUTPUT_HOSTS
echo -e "$LINE_BREAK"
export GREP_COLOR="01;32"
echo -e "Configuring SSH" | grep ".*" --color=auto
echo -e "$LINE_BREAK"

if [ ! -f ~/.ssh/id_rsa ];then

  echo -e  'y\n'|ssh-keygen -q -t rsa -N "" -f ~/.ssh/id_rsa 2>&1>/dev/null
fi

if [ -f "$BASE_PATH/authorized_keys" ];then

  cp "$BASE_PATH/authorized_keys" "$BASE_PATH/ansible/roles/deployment-bootstrap/templates/authorized_keys.j2" 2>&1>/dev/null
fi

cat ~/.ssh/id_rsa.pub>~/.ssh/authorized_keys
echo -e "Host *\n  StrictHostKeyChecking no\n  UserKnownHostsFile /dev/null\n  LogLevel ERROR">~/.ssh/config
echo -e "Configuration complete" | grep ".*" --color=auto
echo -e "$LINE_BREAK"
touch $BASE_PATH/*.sh
exit 0
