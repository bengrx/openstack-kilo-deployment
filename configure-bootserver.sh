#!/bin/bash
LINE_BREAK="-------------------------------------------------------------------------------------------"
BASE_PATH="$(dirname $0)"
export GREP_COLOR="1;32"
echo -e "$LINE_BREAK"
echo -e "Configuring dnsmasq.conf DHCP reserved addresses" | grep -E ".*" --color=auto
echo -e "$LINE_BREAK"

if [ ! -f $BASE_PATH/boot_hosts ];then


  export GREP_COLOR="0;31"
  echo -e "Could not find file $BASE_PATH/boot_hosts" | grep ".*" --color=auto
  echo -e "$LINE_BREAK"
  exit 1
fi

if [ ! -f $BASE_PATH/ansible/roles/deployment-bootstrap/templates/dnsmasq.j2 ];then

  export GREP_COLOR="0;31"
  echo -e "Could not find file $BASE_PATH/ansible/roles/deployment-bootstrap/templates/dnsmasq.j2" | grep ".*" --color=auto
  echo -e "$LINE_BREAK"
  exit 2
fi

remove_lines=$(cat $BASE_PATH/ansible/roles/deployment-bootstrap/templates/dnsmasq.j2 | grep "^dhcp-host")

for line in $remove_lines
do
  sed -i "s/$line//g" $BASE_PATH/ansible/roles/deployment-bootstrap/templates/dnsmasq.j2
  export GREP_COLOR="0;33"
  echo -e "DEL_HOST: \"$line\"" | grep -E ".*" --color=auto
  echo -e "$LINE_BREAK"
done

add_lines=$(cat $BASE_PATH/boot_hosts | grep -v "^#" | grep ":" | sed -e 's/\t/,/g' -e 's/^/dhcp-host=/g')

for line in $add_lines
do
  export GREP_COLOR="1;32"
  echo -e "ADD_HOST: \"$line,1h\"" | grep -E ".*" --color=auto
  echo -e "$LINE_BREAK"
  echo -e "$line,1h" | sed 's/,,/,/g'  >>$BASE_PATH/ansible/roles/deployment-bootstrap/templates/dnsmasq.j2
done

cat $BASE_PATH/ansible/roles/deployment-bootstrap/templates/dnsmasq.j2 | grep -v "^$" > $BASE_PATH/ansible/roles/deployment-bootstrap/templates/dnsmasq.j2.new
mv  $BASE_PATH/ansible/roles/deployment-bootstrap/templates/dnsmasq.j2.new  $BASE_PATH/ansible/roles/deployment-bootstrap/templates/dnsmasq.j2

if [ "$EUID" == "0" ];then

  export GREP_COLOR="0;32"
  echo -e "Local /etc/hosts file has been generated" | grep -E ".*" --color=auto
  echo -e "$LINE_BREAK"
  echo -e "127.0.0.1\t localhost\n" >/etc/hosts
  cat $BASE_PATH/boot_hosts | grep -E "([0-9]{1,3}.){3}.[0-9]{1,3}" | awk '{print $3,"\t",$2}' >>/etc/hosts

else

  export GREP_COLOR="0;31"
  echo -e "Local /etc/hosts file was not generated due to non root user" | grep -E ".*" --color=auto
  echo -e "$LINE_BREAK"
fi

cat $BASE_PATH/boot_hosts | grep -E "([0-9]{1,3}.){3}.[0-9]{1,3}" | awk '{print $3,"\t",$2}' >$BASE_PATH/ansible/roles/deployment-bootstrap/templates/hosts.j2

