exec >> /root/.build.log 2>&1
date
set -x


function add_interface ()
{
        interface=$1
        network=$2
        host=$3
	mtu=$4
        printf "\nauto $interface\n"
        printf "iface $interface inet static\n"
        printf "\taddress $network.$host\n"
        printf "\tnetwork $network.0\n"
        printf "\tnetmask 255.255.255.0\n"
}

echo "Updating interfaces"

current_ip=`ip a | grep 133 | awk '{ print $2 }' | awk -F'/' '{print $1}'`
network_node=$(echo $current_ip | awk -F. '{ print $4 }')
echo "current_ip = $current_ip"
echo "Network node address = $network_node"


printf "\n\nauto lo\niface lo inet loopback\n" > /etc/network/interfaces
add_interface "p4p1" "10.2.133" $network_node "1500" >> /etc/network/interfaces
printf "\nauto p4p2\niface p4p1 inet manual\n\tup ip link set dev p4p1 up\n\tdown ip link set dev p4p1 down\n" >> /etc/network/interfaces 
add_interface "em1" "10.2.135" $network_node "9000" >> /etc/network/interfaces
add_interface "em2" "10.2.136" $network_node "9000" >> /etc/network/interfaces

