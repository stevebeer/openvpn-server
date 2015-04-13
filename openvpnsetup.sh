#!/bin/bash

# Update packages and install openvpn
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y install openvpn

# Copy the easy-rsa files to a directory inside the new openvpn directory
./rsacopy.sh

# Edit the EASY_RSA variable in the vars file to point to the new easy-rsa directory
cd /etc/openvpn/easy-rsa
sed -i -e 's:"`pwd`":"/etc/openvpn/easy-rsa":' vars

# source the vars file just edited
source ./vars

# Remove any previous keys
./clean-all

# Build the certificate authority
./build-ca

# Build the server
./build-key-server server

# Generate Diffie-Hellman key exchange
./build-dh

# Generate static HMAC key to defend against DDoS
openvpn --genkey --secret keys/ta.key

# Read the local and public IP addresses from the user
echo "Enter your Raspberry Pi's local IP address:"
read LOCALIP
echo "Enter your network's public IP address:"
read PUBLICIP

# Write config file for server using the template .txt file
sed 's/LOCALIP/'$LOCALIP'/' </home/pi/OpenVPN/server.txt >/etc/openvpn/server.conf

# Enable forwarding of internet traffic
sed -i -e 's:#net.ipv4.ip_forward=1:net.ipv4.ip_forward=1:' /etc/sysctl.conf
sudo sysctl -p

# Write script to allow openvpn through firewall on boot using the template .txt file
sed 's/LOCALIP/'$LOCALIP'/' </home/pi/OpenVPN/firewall-openvpn-rules.txt >/etc/firewall-openvpn-rules.sh
sudo chmod 700 /etc/firewall-openvpn-rules.sh
sudo chown root /etc/firewall-openvpn-rules.sh
sed -i '/iface eth0 inet dhcp/a \
	pre-up /etc/firewall-openvpn-rules.sh' /etc/network/interfaces

# Write default file for client .ovpn profiles, to be used by the MakeOVPN script, using template .txt file
sed 's/PUBLICIP/'$PUBLICIP'/' </home/pi/OpenVPN/Default.txt >/etc/openvpn/easy-rsa/keys/Default.txt

echo "Configuration complete. Restart system to apply changes and start VPN server."
