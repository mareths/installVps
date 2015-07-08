#!/bin/bash

###################################
# $1 utilisateur
# $2 nom du site exposant le service OpenVPN

echo "export OVPN_DATA=\"ovpn-data\"" >> .bashrc

. .bashrc

docker run --name $OVPN_DATA -v /etc/openvpn busybox

docker run --volumes-from $OVPN_DATA --rm kylemanna/openvpn ovpn_genconfig -u udp://vpn.$2

docker run --volumes-from $OVPN_DATA --rm -it kylemanna/openvpn ovpn_initpki
