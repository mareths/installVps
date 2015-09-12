#!/bin/bash

#############################################################
# Source: http://www.tictech.info/post/mail_dovecot
# $1 

#############################################################
# Installation de Roundcube

wget https://downloads.sourceforge.net/project/roundcubemail/roundcubemail/1.1.2/roundcubemail-1.1.2-complete.tar.gz
tar xvf roundcubemail-1.1.2-complete.tar.gz
mv roundcubemail-1.1.2 /var/www/webmail

chown -R www-data:www-data /var/www/webmail/temp /var/www/webmail/logs


sudo a2enmod ssl
