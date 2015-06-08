unset OS_TENANT_NAME
unset OS_USERNAME
unset OS_PASSWORD
unset OS_REGION_NAME
unset OS_AUTH_URL

export OS_SERVICE_ENDPOINT=http://{{ openstack_ctl_master }}:35357/v2.0
export OS_SERVICE_TOKEN={{ keystone_admin_token }}
