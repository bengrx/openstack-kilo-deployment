# openstack-kilo-deployment

# When using desktop grade network cards, the following package may be needed.

bcmwl-kernel-source ( Used on network node in my case )

When deploying a HA environment on openstack we need to tell neutron about the special
port we are going to use for HA. Special firewall rules are applied to the port to stop
The neutron IP anti-spoofing mechanisms from preventing the node using the address.
It is also important that the address to be used is outside of the neutron DHCP scope

http://blog.aaronorosen.com/implementing-high-availability-instances-with-neutron-using-vrrp/

# Create the port in neutron

export network=man-net
export secugroup=1dca9dca-72a2-48ec-a8c1-6f23f0bbce3c
export vip=192.168.100.100
export node1=192.168.100.12
export node2=192.168.100.13

neutron port-create --fixed-ip ip_address=$vip --security-group $secgroup $network
neutron port-list | grep "$node1\|$node2" | awk '{print $2}'
for port in $(neutron port-list | grep "$node1\|$node2" | awk '{print $2}' | tr '\n' ' ');do neutron port-update $port --allowed_address_pairs list=true type=dict ip_address=$vip;done
