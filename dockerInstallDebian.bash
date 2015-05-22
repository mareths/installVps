#!/bin/bash

#############################################################
# Installation docker sur Debian
# $1 utilisateur

apt-get install docker.io -y

ln -sf /usr/bin/docker.io /usr/local/bin/docker
sed -i '$acomplete -F _docker docker' /etc/bash_completion.d/docker.io

#############################################################
# Initialisation de docker
service docker start
chkconfig docker on

groupadd docker
gpasswd -a $1 docker

#############################################################
# Maj 1.3
#echo deb http://get.docker.com/ubuntu docker main > /etc/apt/sources.list.d/docker.list
#apt-key adv --keyserver pgp.mit.edu --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
#apt-get update
#apt-get install -y lxc-docker-1.3.3