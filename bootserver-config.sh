#!/bin/bash
export GREP_COLOR="1;32"
LINE_BREAK="----------------------------------------------------------------------------------------------------------------"
echo -e "$LINE_BREAK"
echo -e "Configuring dnsmasq.conf DHCP reserved addresses" | grep -E ".*" --color=auto
echo -e "$LINE_BREAK"

if [ ! -f $(dirname $0)/boot_hosts ];then

  echo -e "Could not find file $(dirname $0)/boot_hosts"
  echo -e "n$LINE_BREAK"
  exit 1
fi

if [ ! -f $(dirname $0)/ansible/roles/deployment-bootstrap/templates/dnsmasq.j2 ];then

  echo -e "Could not find file $(dirname $0)/ansible/roles/deployment-bootstrap/templates/dnsmasq.j2"
  echo -e "n$LINE_BREAK"
  exit 2
fi


remove_lines=$(cat $(dirname $0)/ansible/roles/deployment-bootstrap/templates/dnsmasq.j2 | grep "^dhcp-host")

for line in $remove_lines
do
  sed -i "s/$line//g" $(dirname $0)/ansible/roles/deployment-bootstrap/templates/dnsmasq.j2
  export GREP_COLOR="0;33"
  echo -e "DEL_HOST: \"$line\"" | grep -E ".*" --color=auto
  echo -e "$LINE_BREAK"
done

add_lines=$(cat $(dirname $0)/boot_hosts | grep -v "^#" | grep ":" | sed -e 's/\t/,/g' -e 's/^/dhcp-host=/g')

for line in $add_lines
do
  export GREP_COLOR="1;32"
  echo -e "ADD_HOST: \"$line\"" | grep -E ".*" --color=auto
  echo -e "$LINE_BREAK"
  echo -e "$line,infinate" | sed 's/,,/,/g'  >>$(dirname $0)/ansible/roles/deployment-bootstrap/templates/dnsmasq.j2
done

cat $(dirname $0)/ansible/roles/deployment-bootstrap/templates/dnsmasq.j2 | grep -v "^$" > $(dirname $0)/ansible/roles/deployment-bootstrap/templates/dnsmasq.j2.new
mv  $(dirname $0)/ansible/roles/deployment-bootstrap/templates/dnsmasq.j2.new  $(dirname $0)/ansible/roles/deployment-bootstrap/templates/dnsmasq.j2

if [ "$EUID" == "0" ];then

  export GREP_COLOR="0;32"
  echo -e "Local /etc/hosts file has been generated" | grep -E ".*" --color=auto
  echo -e "$LINE_BREAK"
  echo -e "127.0.0.1\t localhost\n" >/etc/hosts
  cat $(dirname $0)/boot_hosts | grep -E "([0-9]{1,3}.){3}.[0-9]{1,3}" | awk '{print $3,"\t",$2}' >>/etc/hosts

else

  export GREP_COLOR="0;31"
  echo -e "Local /etc/hosts file was not generated due to non root user" | grep -E ".*" --color=auto
  echo -e "$LINE_BREAK"
fi

