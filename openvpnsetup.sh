#!/bin/bash

if (whiptail --title "Setup OpenVPN" --yesno "You are about to configure your \
Raspberry Pi as a VPN server running OpenVPN. Are you sure you want to \
continue?" 8 78) then
 whiptail --title "Setup OpenVPN" --infobox "OpenVPN will be installed and \
 configured." 8 78
else
 whiptail --title "Setup OpenVPN" --msgbox "Cancelled" 8 78
fi

# Update packages and install openvpn
echo "Updating, Upgrading, and Installing..."
apt-get update
apt-get -y upgrade
apt-get -y install openvpn

# Read the local and public IP addresses from the user
LOCALIP=$(whiptail --inputbox "What is your Raspberry Pi's local IP address?" \
8 78 --title "OpenVPN Setup" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
 whiptail --title "OpenVPN Setup" --infobox "Local IP: $LOCALIP" 8 78
else
 whiptail --title "OpenVPN Setup" --infobox "Cancelled" 8 78
 exit
fi

PUBLICIP=$(whiptail --inputbox "What is the public IP address of network the \
Raspberry Pi is on?" 8 78 --title "OpenVPN Setup" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
 whiptail --title "OpenVPN Setup" --infobox "PUBLIC IP: $PUBLICIP" 8 78
else
 whiptail --title "OpenVPN Setup" --infobox "Cancelled" 8 78
 exit
fi

# Ask user for desired level of encryption
ENCRYPT=$(whiptail --inputbox "1024 or 2048 bit encryption? 2048 is more secure \
but will take much longer to set up. Enter your choice, 1024 or 2048:" 8 78 \
--title "OpenVPN Setup" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
 whiptail --title "OpenVPN Setup" --infobox "Encryption level: $PUBLICIP" 8 78
else
 whiptail --title "OpenVPN Setup" --infobox "Cancelled" 8 78
 exit
fi

# Copy the easy-rsa files to a directory inside the new openvpn directory
cp -r /usr/share/doc/openvpn/examples/easy-rsa/2.0 /etc/openvpn/easy-rsa

# Edit the EASY_RSA variable in the vars file to point to the new easy-rsa directory,
# And change from default 1024 encryption if desired
cd /etc/openvpn/easy-rsa
sed -i 's:"`pwd`":"/etc/openvpn/easy-rsa":' vars
if [ $ENCRYPT = 2048 ]; then
 sed -i 's:KEY_SIZE=1024:KEY_SIZE=2048:' vars
fi

# source the vars file just edited
source ./vars

# Remove any previous keys
./clean-all

# Build the certificate authority
./build-ca < /home/pi/OpenVPN-Setup/ca_info.txt

# Build the server
./build-key-server server

# Generate Diffie-Hellman key exchange
./build-dh

# Generate static HMAC key to defend against DDoS
openvpn --genkey --secret keys/ta.key

# Write config file for server using the template .txt file
sed 's/LOCALIP/'$LOCALIP'/' </home/pi/OpenVPN-Setup/server_config.txt >/etc/openvpn/server.conf
if [ $ENCRYPT = 2048 ]; then
 sed -i 's:dh1024:dh2048:' /etc/openvpn/server.conf
fi

# Enable forwarding of internet traffic
sed -i 's:#net.ipv4.ip_forward=1:net.ipv4.ip_forward=1:' /etc/sysctl.conf
sudo sysctl -p

# Write script to allow openvpn through firewall on boot using the template .txt file
sed 's/LOCALIP/'$LOCALIP'/' </home/pi/OpenVPN-Setup/firewall-openvpn-rules.txt >/etc/firewall-openvpn-rules.sh
sudo chmod 700 /etc/firewall-openvpn-rules.sh
sudo chown root /etc/firewall-openvpn-rules.sh
sed -i '/gateway/a \
	pre-up /etc/firewall-openvpn-rules.sh' /etc/network/interfaces

# Write default file for client .ovpn profiles, to be used by the MakeOVPN script, using template .txt file
sed 's/PUBLICIP/'$PUBLICIP'/' </home/pi/OpenVPN-Setup/Default.txt >/etc/openvpn/easy-rsa/keys/Default.txt

# Make directory under home directory for .ovpn profiles
mkdir /home/pi/ovpns
chmod 777 -R /home/pi/ovpns

whiptail --title "OpenVPN Setup" --msgbox "Configuration complete. Restart \
system to apply changes and start VPN server." 8 78
