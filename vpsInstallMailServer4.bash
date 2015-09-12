#!/bin/bash

#############################################################
# Source: http://www.tictech.info/post/mail_dovecot
# $1 mailuser postfix
# $2 password mailuser postfix
# $3 nom du site du type votresite.com

#############################################################
# Mise à jour de la configuration de Dovecot

sed -e "auth_mechanisms = plain/auth_mechanisms = plain login/" /etc/dovecot/conf.d/10-auth.conf \
	| sed -e "s/\!include auth-system.conf.ext/\#\!include auth-system.conf.ext/" \
	| sed -e "s/\#\!include auth-sql.conf.ext/\!include auth-sql.conf.ext/" \
> /etc/dovecot/conf.d/10-auth.conf.tmp
mv /etc/dovecot/conf.d/10-auth.conf.tmp /etc/dovecot/conf.d/10-auth.conf

cp ./ressources/rewrite_auth-sql.conf.ext /etc/dovecot/conf.d/auth-sql.conf.ext

sed -e "s/mail_location = mbox:\~\/mail:INBOX=\/var\/mail\/\%u/mail_location = maildir:\/var\/vmail\/\%d\/\%n\/Maildir/" /etc/dovecot/conf.d/10-mail.conf /etc/dovecot/conf.d/10-mail.conf.tmp
mv /etc/dovecot/conf.d/10-mail.conf.tmp /etc/dovecot/conf.d/10-mail.conf

cp ./ressources/rewrite_dovecot-conf.d-10-master.conf /etc/dovecot/conf.d/10-master.conf

sed -e "s/ssl_cert = <\/etc\/dovecot\/dovecot.pem/ssl_cert = <\/etc\/ssl\/certs\/mailserver.pem/" /etc/dovecot/conf.d/10-ssl.conf | \
	sed -e "s/ssl_key = <\/etc\/dovecot\/private\/dovecot.pem/ssl_key = </etc\/ssl\/private\/mailserver.pem/" > /etc/dovecot/conf.d/10-ssl.conf.tmp
mv /etc/dovecot/conf.d/10-ssl.conf.tmp /etc/dovecot/conf.d/10-ssl.conf

sed -e "s/\#mail_plugins = \$mail_plugins/mail_plugins = \$mail_plugins sieve/" /etc/dovecot/conf.d/15-lda.conf > /etc/dovecot/conf.d/15-lda.conf.tmp
mv /etc/dovecot/conf.d/15-lda.conf.tmp /etc/dovecot/conf.d/15-lda.conf

sed -e "s/MAILUSER/$1/" ./ressources/add_dovecot-sql.conf.ext | sed -e "s/PWD_MAILUSER/$2/"  >> /etc/dovecot/dovecot-sql.conf.ext

chown root:root /etc/dovecot/dovecot-sql.conf.ext
chmod go= /etc/dovecot/dovecot-sql.conf.ext

chgrp vmail /etc/dovecot/dovecot.conf
chmod g+r /etc/dovecot/dovecot.conf

sed -e "s/mydestination = $3, /mydestination = /" /etc/postfix/main.cf /etc/postfix/main.cf.tmp
mv /etc/postfix/main.cf.tmp /etc/postfix/main.cf

service dovecot restart

cat ./ressources/add_postfix-master.cf >> /etc/postfix/master.cf

service postfix restart

postconf -e virtual_transport=dovecot
postconf -e dovecot_destination_recipient_limit=1