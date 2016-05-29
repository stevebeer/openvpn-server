FROM ubuntu:15.04

RUN apt-get update &&  apt-get upgrade -y 

RUN apt-get install git

RUN cd 
RUN git clone git://github.com/StarshipEngineer/OpenVPN-Setup
    
RUN cd OpenVPN-Setup
RUN chmod +x openvpnsetup.sh 
RUN ./openvpnsetup.sh
    
VOLUME ["/etc/openvpn"]

EXPOSE 1194/udp

WORKDIR /etc/openvpn
    

