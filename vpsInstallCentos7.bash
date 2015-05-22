#!/bin/bash

###################################
# $1 utilisateur
# $2 port ssh

#############################################################
# Installation de Vim et fail2ban
yum install -y epel-release

yum update -y && yum upgrade -y && yum install vim fail2ban fail2ban-systemd -y


#############################################################
# Configuration de Vim
sed -e "s/\"syntax on/syntax on/" /usr/share/vim/vimrc | sed -e "s/\"set showcmd/set showcmd/" | sed -e "s/\"set showmatch/set showmatch/" > /usr/share/vim/vimrc.tmp
mv /usr/share/vim/vimrc.tmp /usr/share/vim/vimrc

#############################################################
# Mise à jour du profile
cat ./ressources/add_.bashrc >> ~/.bashrc

#############################################################
# Configuration fail2ban

cat ./ressources/add_jail.conf >> /etc/fail2ban/jail.conf
cp ./ressources/copy_apache-admin.conf /etc/fail2ban/filter.d/apache-admin.conf
cp ./ressources/copy_apache-404.conf /etc/fail2ban/filter.d/apache-404.conf

mkdir /var/log/apache
touch /var/log/apache/error.log

systemctl restart fail2ban.service

#############################################################
# Ajout de l'utilisateur principal, car on n'autorise plus l’accès au compte root depuis l’extérieur

adduser $1
passwd $1

cat ./ressources/add_.bashrc >> /home/$1/.bashrc

#############################################################
# Config ssh

sed -e "s/PORT/$2/" ./ressources/add_sshd_config | sed -e "s/USER/$1/" >> /etc/ssh/sshd_config

/bin/systemctl restart  sshd.service

