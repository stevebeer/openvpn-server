FROM ubuntu:15.04

RUN apt-get update \
    apt-get upgrade -y \
    apt-get install git

RUN cd \
    git clone git://github.com/StarshipEngineer/OpenVPN-Setup
    
RUN cd OpenVPN-Setup
    chmod +x openvpnsetup.sh \
    ./openvpnsetup.sh
    
VOLUME ["/etc/openvpn"]

EXPOSE 1194/udp

WORKDIR /etc/openvpn
    

