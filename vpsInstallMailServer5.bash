#!/bin/bash

#############################################################
# Source: http://www.tictech.info/post/mail_dovecot
# $1 votresite.com
# $2 admin webmail

#############################################################
# Installation de Roundcube

wget https://downloads.sourceforge.net/project/roundcubemail/roundcubemail/1.1.2/roundcubemail-1.1.2-complete.tar.gz
tar xvf roundcubemail-1.1.2-complete.tar.gz
mv roundcubemail-1.1.2 /var/www/webmail

chown -R www-data:www-data /var/www/webmail/temp /var/www/webmail/logs

sed -e "s/MAILUSER/$1/" ./ressources/add_webmail.conf | sed -e "s/PWD_MAILUSER/$2/"  > /etc/apache2/sites-available/webmail.conf
cp ./ressources/rewrite_ports.conf /etc/apache2/ports.conf

sudo a2enmod ssl
a2ensite webmail
service apache2 reload

read -p "rendez-vous sur https://mail.$1/installer afin de configurer Roundcube" ok
read -p "rendez-vous sur https://mail.$1 pour vérification" ok

rm -rf /var/www/webmail/installer

#############################################################
# Ajout de repertoire dans Dovecot

sed -e "s/\#mail_plugins = \$mail_plugins/mail_plugins = \$mail_plugins autocreate/" /etc/dovecot/conf.d/20-imap.conf > /etc/dovecot/conf.d/20-imap.conf.tmp
cat ./ressources/add_20-imap.conf >> /etc/dovecot/conf.d/20-imap.conf.tmp
mv /etc/dovecot/conf.d/20-imap.conf.tmp /etc/dovecot/conf.d/20-imap.conf

service dovcot restart
