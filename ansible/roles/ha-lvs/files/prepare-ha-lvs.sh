#!/bin/bash
target_device="vdb"
vg_name="drbd"
mysql_capacity="5G"
rabbit_capacity="4G"

vgcreate "$vg_name" "/dev/$target_device" &>/dev/null
lvcreate "$vg_name" -n mysql -L"$mysql_capacity" &>/dev/null
lvcreate "$vg_name" -n rabbit -L"$rabbit_capacity" &>/dev/null
