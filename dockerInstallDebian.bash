#!/bin/bash

#############################################################
# Installation docker sur Debian
# $1 utilisateur

# apt-get install docker.io -y

# ln -sf /usr/bin/docker.io /usr/local/bin/docker
# sed -i '$acomplete -F _docker docker' /etc/bash_completion.d/docker.io

wget -qO- https://get.docker.com/ | sh

#############################################################
# Initialisation de docker

# service docker start
# chkconfig docker on

# groupadd docker
# gpasswd -a $1 docker

usermod -aG docker $1

service docker start

#############################################################
# Maj 1.3
#echo deb http://get.docker.com/ubuntu docker main > /etc/apt/sources.list.d/docker.list
#apt-key adv --keyserver pgp.mit.edu --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
#apt-get update
#apt-get install -y lxc-docker-1.3.3

#############################################################
# Adjust memory and swap accounting

sed -e  "s/GRUB_CMDLINE_LINUX=\"\"/GRUB_CMDLINE_LINUX=\"cgroup_enable=memory swapaccount=1\""  /etc/default/grub
update-grub

read -p "Un reboot du système est nécessaire" ok

