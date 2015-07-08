#!/bin/bash

###################################
# $1 utilisateur
# $2 port ssh

#############################################################
# Installation de Vim, fail2ban et autres outils
apt-get update -y && apt-get upgrade -y && apt-get install vim fail2ban wget tofrodos curl xauth xfonts-base x11-xserver-utils -y

#############################################################
# Configuration de Vim
sed -e "s/\"syntax on/syntax on/" /usr/share/vim/vimrc | sed -e "s/\"set showcmd/set showcmd/" | sed -e "s/\"set showmatch/set showmatch/" > /usr/share/vim/vimrc.tmp
mv /usr/share/vim/vimrc.tmp /usr/share/vim/vimrc

#############################################################
# Mise à jour du profile
cat ./ressources/add_.bashrc >> ~/.bashrc
sed -e "s/\#force_color_prompt=yes/force_color_prompt=yes/" ~/.bashrc > ~/.bashrc.tmp
sed -e "s/32m/31m/" ~/.bashrc.tmp > ~/.bashrc
rm ~/.bashrc.tmp

#############################################################
# Configuration fail2ban

cat ./ressources/add_jail.conf >> /etc/fail2ban/jail.conf
cp ./ressources/copy_apache-admin.conf /etc/fail2ban/filter.d/apache-admin.conf
cp ./ressources/copy_apache-404.conf /etc/fail2ban/filter.d/apache-404.conf

mkdir /var/log/apache
touch /var/log/apache/error.log

service fail2ban restart

#############################################################
# Ajout de l'utilisateur principal, car on n'autorise plus l’accès au compte root depuis l’extérieur

adduser $1
passwd $1

cat ./ressources/add_.bashrc >> /home/$1/.bashrc
sed -e "s/\#force_color_prompt=yes/force_color_prompt=yes/" /home/$1/.bashrc > /home/$1/.bashrc.tmp
mv /home/$1/.bashrc.tmp /home/$1/.bashrc
chown $1:$1 /home/$1/.bashrc

#############################################################
# Config ssh

sed -e "s/PORT/$2/" ./ressources/add_sshd_config | sed -e "s/USER/$1/" >> /etc/ssh/sshd_config

service ssh restart

