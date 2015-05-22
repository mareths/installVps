#!/bin/bash

apt-get update

#############################################################
# Apache

apt-get install apache2 -y

#############################################################
# Mysql

apt-get install mysql-server -y
mysql_secure_installation

#############################################################
# PHP

apt-get install php5 php-pear php5-mysql phpmyadmin -y
service apache2 restart

cp ./ressources/info.php /var/www/

#############################################################
# Wordpress Blog

tar -xzvf ./ressources/wordpress-4.1.tar.gz -C /var/www/
mv /var/www/wordpress /var/www/$1

sed -e "s/NOM_DU_SITE/$1/" $1 >> /etc/apache2/sites-available/$1
ln -s /etc/apache2/sites-available/$1 /etc/apache2/sites-enabled/$1

chown -R www-data /var/www
