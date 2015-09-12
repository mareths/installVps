#!/bin/bash

#############################################################
# Source: http://www.tictech.info/post/mail_preparation

#############################################################
# Installation de Vim, fail2ban et autres outils
read -p "Lors de l'installation de postfix, répondre \"Site Internet\", \
	puis pour domaineName mettre le nom du site internet \"votresite.com\"" ok

apt-get update -y && apt-get upgrade -y && apt-get install mailutils \
	apache2 php5 mysql-server phpmyadmin \ #lamp
	postfix postfix-mysql libsasl2-modules sasl2-bin postfixadmin \ #postix
	dovecot-mysql dovecot-pop3d dovecot-imapd dovecot-managesieved \ #dovecot
		-y

#############################################################
# Suppression de exim4 si il est présent
apt-get purge 'exim4*'

#############################################################
# Configuration
sed -e "s/START=no/START=yes/" /etc/default/saslauthd > /etc/default/saslauthd.tmp
mv /etc/default/saslauthd.tmp /etc/default/saslauthd

service saslauthd start

read -p "Via phpmyadmin, ajouter pour la bdd postfixadmin un utilisateur mailuser, \
	avec son mot de passe, en localhost, et seulement les droits select" ok

#############################################################
# Ajout de l'utilisateur Vmail
groupadd -g 5000 vmail
useradd -g vmail -u 5000 vmail -d /var/vmail -m

#############################################################
# Ajout de certificats
read -p "Organization name: son nom, Common name : votresite.com" ok

openssl req -new -x509 -days 3650 -nodes -newkey rsa:4096 -out /etc/ssl/certs/mailserver.pem -keyout /etc/ssl/private/mailserver.pem