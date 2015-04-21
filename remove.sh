#!/bin/bash

# Remove openvpn
apt-get -y remove openvpn

# Remove openvpn-related directories
rm -r /etc/openvpn /home/pi/ovpns

# Remove firewall script and reference to it in interfaces
sed -i '/firewall-openvpn-rules.sh/d' /etc/network/interfaces
rm /etc/firewall-openvpn-rules.sh

# Disable IPv4 forwarding
sed -i 's:net.ipv4.ip_forward=1:#net.ipv4.ip_forward=1:' /etc/sysctl.conf
sysctl -p
