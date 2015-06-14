# openstack-kilo-deployment

# Installation From Scratch

\# Bootstrap the deployment server<br>
apt-get update && apt-get install -y git
echo -e "y\n" | ssh-keygen -q -t rsa -N "" -f ~/.ssh/id_rsa && cd ~/
git clone git@github.com:bengrx/openstack-kilo-deployment.git && cd openstack-kilo-deployment

\# Configure OpenStack parameters and authentication tokens<br>
./configure-openstack.sh

\# Configure the bootserver for hosts listed in boot_hosts<br>
./configure-bootserver.sh

\# Deploy the bootserver services<br>
./deploy-bootserver.sh

\# Deploy base configuration to machines after inital deployment<br>
./deploy-base.sh

\# Deploy OpenStack kilo minimal against the environment [ minimal | ha | full ]<br>
./deploy-openstack.sh minimal

# Quick Installation
\# Configure OpenStack parameters and authentication tokens<br>
./configure-openstack.sh

\# Deploy base configuration to machines after inital deployment<br>
./deploy-base.sh

\# Deploy OpenStack kilo minimal against the environment [ minimal | ha | full ]<br>
./deploy-openstack.sh minimal
