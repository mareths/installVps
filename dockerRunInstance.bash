#!/bin/bash

###################################
# $1 utilisateur

docker run --volumes-from $OVPN_DATA -d -p 1194:1194/udp --cap-add=NET_ADMIN kylemanna/openvpn
docker run -d --name myjenkins -p 8080:8080 -v /home/$1/jenkins:/var/jenkins_home jenkins

