# openstack-kilo-deployment

\# Configure OpenStack parameters and authentication tokens
./configure-openstack.sh

\# Configure the bootserver for hosts listed in boot_hosts
./configure-bootserver.sh

\# Deploy the bootserver services
./deploy-bootserver.sh

\# Deploy base configuration to machines after inital deployment
./deploy-networking.sh

\# Deploy OpenStack kilo minimal against the environment [ minimal | ha | full ]
./deploy-openstack.sh minimal
