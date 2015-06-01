#!/bin/bash

#############################################
# Installation de git, serveur mail, openVpn
# $1 utilisateur
# $2 email

echo "Répondre non à la configuration auto des repertoires pour Courrier"
read ok

apt-get update -y && apt-get upgrade -y && apt-get install git-core \
        postfix-mysql \
        openvpn \
        courier-base courier-authdaemon courier-authlib-mysql courier-imap courier-pop \
        courier-pop-ssl courier-imap-ssl libsasl2-2 libsasl2-modules libsasl2-modules-sql sasl2-bin libpam-mysql openssl \
        amavisd-new spamassassin clamav clamav-daemon zoo unzip bzip2 libnet-ph-perl libnet-snpp-perl libnet-telnet-perl nomarch lzop pax -y

#############################################################
# Postfix

read -p "Creer un user postfix avec sa table dans mysql" ok
read -p "executer le script sql createDomain.sql" ok
read -p "executer le script sql insertDomain.sql" ok
read -p "executer le script sql insertCompte.sql" ok

cp ./ressources/copy_mysql-virtual_domaines.cf /etc/postfix/mysql-virtual_domaines.cf
cp ./ressources/copy_mysql-virtual_comptes.cf /etc/postfix/mysql-virtual_comptes.cf
cp ./ressources/copy_mysql-virtual_aliases.cf /etc/postfix/mysql-virtual_aliases.cf
cp ./ressources/copy_mysql-virtual_aliases_comptes.cf /etc/postfix/mysql-virtual_aliases_comptes.cf
cp ./ressources/copy_mysql-virtual_quotas.cf /etc/postfix/mysql-virtual_quotas.cf

chmod u=rw,g=r,o= /etc/postfix/mysql-virtual_*.cf
chgrp postfix /etc/postfix/mysql-virtual_*.cf

groupadd -g 5000 vmail
useradd -g vmail -u 5000 vmail -d /var/spool/vmail/ -m

# $1 de type mail.votresite.com et $2 l'@ IP du serveur
sed -e "s/NOM_HOTE/$1/" ./ressources/copy_main.cf | sed -e "s/IP_EXTERNE/$2/"  > /etc/postfix/main.cf

sed -e "s/authmodulelist=\"authpam\"/authmodulelist=\"authmysql\"/" /etc/courier/authdaemonrc > /etc/courier/authdaemonrc.tmp
mv /etc/courier/authdaemonrc.tmp /etc/courier/authdaemonrc

# $3 est le mot de passe du user postfix
sed -e "s/MYSQL_USERNAME          admin/MYSQL_USERNAME          postfix/" /etc/courier/authmysqlrc | \
    sed -e "s/MYSQL_PASSWORD          admin/MYSQL_PASSWORD          $3/" | \
    sed -e "s/MYSQL_DATABASE          mysql/MYSQL_DATABASE          postfix/" | \
    sed -e "s/MYSQL_USER_TABLE        passwd/MYSQL_USER_TABLE        comptes/" | \
    sed -e "s/MYSQL_CRYPT_PWFIELD     crypt/MYSQL_CRYPT_PWFIELD     password/" | \
    sed -e "s/MYSQL_UID_FIELD         uid/MYSQL_UID_FIELD         5000/" | \
    sed -e "s/MYSQL_GID_FIELD         gid/MYSQL_GID_FIELD         5000/" | \
    sed -e "s/MYSQL_LOGIN_FIELD       id/MYSQL_LOGIN_FIELD       email/" | \
    sed -e "s/MYSQL_HOME_FIELD        home/MYSQL_HOME_FIELD        \"\/var\/spool\/vmail\/\"/" | \
    sed -e "s/\# MYSQL_MAILDIR_FIELD   maildir/MYSQL_MAILDIR_FIELD   CONCAT(SUBSTRING_INDEX(email,\'\@\',-1),\'\/\',SUBSTRING_INDEX(email,\'\@\',1),\'\/\'\)/" | \
    sed -e "s/MYSQL_NAME_FIELD        name/\# MYSQL_NAME_FIELD        name/" >> /etc/courier/authmysqlrc.tmp
mv /etc/courier/authmysqlrc.tmp /etc/courier/authmysqlrc

read -p "Pour Common Name, mettre le nom du serveur du style mail.votredomain.com" ok

cd /etc/postfix
openssl req -new -outform PEM -out smtpd.cert -newkey rsa:2048 -nodes -keyout smtpd.key -keyform PEM -days 365 -x509

chmod o= /etc/postfix/smtpd.key

mkdir -p /var/spool/postfix/var/run/saslauthd

sed -e "START=no/START=yes/" /etc/default/saslauthd | \
    sed -e "s/OPTIONS=\"-c -m \/var\/run\/saslauthd\"/OPTIONS=\"-c -m \/var\/spool\/postfix\/var\/run\/saslauthd -r\"/" >> /etc/default/saslauthd.tmp
mv /etc/default/saslauthd.tmp /etc/default/saslauthd

sed -e "s/motdepassedb/$3/" ./ressources/copy_smtp > /etc/pam.d/smtp

sed -e "s/motdepassedb/$3/" ./ressources/copy_smtpd.conf > /etc/postfix/sasl/smtpd.conf

adduser postfix sasl

cd /etc/courier
rm -f /etc/courier/imapd.pem
rm -f /etc/courier/pop3d.pem

sed -e "s/CN=localhost/CN=$1/" /etc/courier/imapd.cnf > /etc/courier/imapd.cnf.tmp
mv /etc/courier/imapd.cnf.tmp /etc/courier/imapd.cnf

sed -e "s/CN=localhost/CN=$1/" /etc/courier/pop3d.cnf > /etc/courier/pop3d.cnf.tmp
mv /etc/courier/pop3d.cnf.tmp /etc/courier/pop3d.cnf

mkimapdcert 
mkpop3dcert

sed -e "s/#@/@/" /etc/amavis/conf.d/15-content_filter_mode | sed -e "s/#   /   /" > /etc/amavis/conf.d/15-content_filter_mode.tmp
mv /etc/amavis/conf.d/15-content_filter_mode.tmp /etc/amavis/conf.d/15-content_filter_mode

sed -e "s/#--/\$pax=\'pax\';\\n#--/" /etc/amavis/conf.d/50-user > /etc/amavis/conf.d/50-user.tmp
mv /etc/amavis/conf.d/50-user.tmp /etc/amavis/conf.d/50-user

adduser clamav amavis

cat add_master.cf >> /etc/postfix/master.cf

hostname > /etc/mailname

/etc/init.d/postfix restart
/etc/init.d/saslauthd restart
/etc/init.d/courier-authdaemon restart
/etc/init.d/courier-imap restart
/etc/init.d/courier-imap-ssl restart
/etc/init.d/courier-pop restart
/etc/init.d/courier-pop-ssl restart 
/etc/init.d/amavis restart
/etc/init.d/clamav-daemon restart
/etc/init.d/clamav-freshclam restart

mkdir ~/roundcube
cd ~/roundcube
read -p "Une pause aura lieu lors du lancement du get, appuyer sur entrée pour finir le wget" ok
wget http://downloads.sourceforge.net/project/roundcubemail/roundcubemail/0.9.5/roundcubemail-0.9.5.tar.gz?r=http%3A%2F%2Froundcube.net%2Fdownload%2F&ts=1395443522&use_mirror=optimate
mv roundcubemail*.gz* roundcubemail-0.9.5.tar.gz
tar -xvf roundcubemail*.gz*
mv roundcubemail-0.9.5 /var/www/roundcube

cd -
cp ./ressources/roundcube /etc/apache2/sites-available/roundcube
a2ensite roundcube
service apache2 reload
a2enmod expires headers

read -p "Creer un user roundcube avec sa table dans mysql" ok
read -p "Executer mysql.inital.sql dans le repertoire d'installation de Roundcube" ok

chown www-data:www-data /var/www/roundcube/temp
chown www-data:www-data /var/www/roundcube/logs

service apache2 restart

#############################################################
# VPN

mkdir ~/openVpn
cd ~/openVpn
wget http://swupdate.openvpn.org/as/openvpn-as-2.0.12-Debian7.amd_64.deb
dpkg -i *.deb

read -p "Veuillez noter les 2 url Admin et CLient" ok

passwd openvpn

# $4 : user VPN
adduser $4

read -p "Se connecter sur l'url admin et ajouter le user VPN créé" ok
read -p "Telecharger le client en utilisant l'url client" ok

#############################################################
# Git
adduser git

su $1

git config --global user.name $1
git config --global user.email $2

cat ./ressources/add_.gitconfig >> .gitconfig

ssh-keygen -t rsa -b 4096 -C $2

eval $(ssh-agent -s)
ssh-add ~/.ssh/id_rsa

read -p "Test de la connection avec github" ok
ssh -T git@github.com

read -p "Attention après le git init, ne pas oublier de faire un git remote set-url origin git@github.com:USER/REPO.git" ok
