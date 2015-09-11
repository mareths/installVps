#!/bin/bash

#############################################################
# Installation docker sur Debian
# $1 utilisateur

wget -qO- https://get.docker.com/ | sh

curl -L https://github.com/docker/compose/releases/download/1.3.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

#############################################################
# Initialisation de docker

usermod -aG docker $1

#############################################################
# Adjust memory and swap accounting

sed -e  "s/GRUB_CMDLINE_LINUX=\"\"/GRUB_CMDLINE_LINUX=\"cgroup_enable=memory swapaccount=1\"/"  /etc/default/grub > /etc/default/grub.tmp
mv /etc/default/grub.tmp /etc/default/grub
update-grub

shutdown -r now
