#!/bin/bash

#############################################################
# Source: http://www.tictech.info/post/mail_postfix
# $1 mailuser postfix
# $2 password mailuser postfix

#############################################################
# Mise à jour de la configuration de Postfix

sed -e "s/MAILUSER/$1/" ./ressources/copy_mysql-virtual-mailbox-domains.cf | sed -e "s/PWD_MAILUSER/$2/"  > /etc/postfix/mysql-virtual-mailbox-domains.cf
sed -e "s/MAILUSER/$1/" ./ressources/copy_mysql-virtual-mailbox-maps.cf | sed -e "s/PWD_MAILUSER/$2/"  > /etc/postfix/mysql-virtual-mailbox-maps.cf
sed -e "s/MAILUSER/$1/" ./ressources/copy_mysql-virtual-alias-maps.cf | sed -e "s/PWD_MAILUSER/$2/"  > /etc/postfix/mysql-virtual-alias-maps.cf

postconf -e virtual_mailbox_domains=mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf
postconf -e virtual_mailbox_maps=mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf
postconf -e virtual_alias_maps=mysql:/etc/postfix/mysql-virtual-alias-maps.cf

chgrp postfix /etc/postfix/mysql-*.cf
chmod u=rw,g=r,o= /etc/postfix/mysql-*.cf

#############################################################
# Activation du port 587

sed -e "s/\#submission/submission/" /etc/postfix/master.cf > /etc/postfix/master.cf.tmp
mv /etc/postfix/master.cf.tmp /etc/postfix/master.cf

#############################################################
# Activation du SASL

cat ./ressources/add_postfix-main.cf >> /etc/postfix/main.cf
