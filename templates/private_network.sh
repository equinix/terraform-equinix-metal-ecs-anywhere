#!/bin/bash

VLAN_ID='${vlan_id}'
PRIVATE_IP='${private_ip}'
PRIVATE_NETWORK='${private_network}'
AWS_SUBNET_CIDR='${aws_subnet_cidr}'

# Install the prerequisites for VLANs
sudo apt update -qy
sudo apt install vlan -y
modprobe 8021q
echo "8021q" >> /etc/modules-load.d/networking.conf

# Make sure eth1 has been removed from bond0
eth1=(`ls /sys/class/net/ | egrep 'f1|eth1'`)
echo "remove interface $eth1 from bond0"
echo "-$eth1" > /sys/class/net/bond0/bonding/slaves
sed -i.bak_$(date "+%m%d%y") -r "s/(.*bond-slaves.*) $eth1/\1/" /etc/network/interfaces

sed -i "/^auto $eth1\$*/,\$d" /etc/network/interfaces
cat <<EOT >> /etc/network/interfaces
auto $eth1
iface $eth1 inet static
    pre-up sleep 5
    address $PRIVATE_NETWORK.$PRIVATE_IP
    netmask 255.255.255.0
    up route add -net $AWS_SUBNET_CIDR gw $PRIVATE_NETWORK.254 dev $eth1
EOT

# Restart eth1 interface:
ip addr flush dev $eth1
sudo ifdown $eth1 && sudo ifup $eth1