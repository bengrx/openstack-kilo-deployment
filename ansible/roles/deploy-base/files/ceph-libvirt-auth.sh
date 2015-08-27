cat > /etc/ceph/secret.xml <<EOF
<secret ephemeral='no' private='no'>
  <uuid>032c0d55-2a67-46af-aff6-ee82328da731</uuid>
  <usage type='ceph'>
    <name>client.cinder secret</name>
  </usage>
</secret>
EOF
virsh secret-define --file /etc/ceph/secret.xml
virsh secret-set-value --secret 032c0d55-2a67-46af-aff6-ee82328da731 --base64 $(cat /etc/ceph/client.cinder.key)

