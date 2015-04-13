#!/bin/bash

sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y install openvpn

./rsacopy.sh

cd /etc/openvpn/easy-rsa
sed -i -e 's:"`pwd`":"/etc/openvpn/easy-rsa":' vars

source ./vars
./clean-all
./build-ca

./build-key-server server

./build-dh

openvpn --genkey --secret keys/ta.key

echo "Enter your Raspberry Pi's local IP address:"
read LOCALIP
echo "Enter your network's public IP address:"
read PUBLICIP

# write config file for server using the template .txt file
sed 's/LOCALIP/'$LOCALIP'/' </home/pi/OpenVPN/server.txt >/etc/openvpn/server.conf

sed -i -e 's:#net.ipv4.ip_forward=1:net.ipv4.ip_forward=1:' /etc/sysctl.conf
sudo sysctl -p

# write script to allow openvpn through firewall on boot using the template
sed 's/LOCALIP/'$LOCALIP'/' </home/pi/OpenVPN/firewall-openvpn-rules.txt >/etc/firewall-openvpn-rules.sh
sudo chmod 700 /etc/firewall-openvpn-rules.sh
sudo chown root /etc/firewall-openvpn-rules.sh
sed -i '/iface eth0 inet dhcp/a \
	pre-up /etc/firewall-openvpn-rules.sh' /etc/network/interfaces

# write default file for client using template
sed 's/PUBLICIP/'$PUBLICIP'/' </home/pi/OpenVPN/Default.txt >/etc/openvpn/easy-rsa/keys/Default.txt

echo "Done!"
