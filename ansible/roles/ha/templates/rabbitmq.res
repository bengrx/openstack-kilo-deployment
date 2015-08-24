resource rabbitmq {
  device    minor 1;
  disk      "/dev/{{ rabbitmq_storage_device }}";
  meta-disk internal;
  on {{ hostname_master.stdout }} {
    address ipv4 {{ openstack_ctl_master }}:7701;
  }
  on {{ hostname_slave.stdout }} {
    address ipv4 {{ openstack_ctl_slave }}:7701;
  }
}
