# openstack-kilo-deployment

\# Configure OpenStack parameters and authentication tokens<br>
./configure-openstack.sh

\# Configure the bootserver for hosts listed in boot_hosts<br>
./configure-bootserver.sh

\# Deploy the bootserver services<br>
./deploy-bootserver.sh

\# Deploy base configuration to machines after inital deployment<br>
./deploy-networking.sh

\# Deploy OpenStack kilo minimal against the environment [ minimal | ha | full ]<br>
./deploy-openstack.sh minimal
