#!/bin/bash

LOG_FILE=/vagrant/vagrant/build.log

DATABASE_BLOWFISH_SECRET="your-blowfish-secret"
DATABASE_ROOT_PASSWORD="root"

SERVER_ADMIN="your@email.address"
SERVER_DOCUMENT_ROOT=/var/www/html
SERVER_NAME="vagrant-focal64-php7.4"

SYSTEM_LANGUAGE=en_US.UTF-8
SYSTEM_TIMEZONE=CET

CONF_VAGRANT=$(cat <<EOF
<VirtualHost *:80>
  ServerName ${SERVER_NAME}
  ServerAdmin ${SERVER_ADMIN}
  CustomLog \${APACHE_LOG_DIR}/access.log combined
  ErrorLog \${APACHE_LOG_DIR}/error.log
  #APPLICATION
  DocumentRoot ${SERVER_DOCUMENT_ROOT}
  <Directory "${SERVER_DOCUMENT_ROOT}">
    Options Indexes FollowSymLinks MultiViews
    AllowOverride All
    Require all granted
  </Directory>
  #PHPMYADMIN
  Alias /phpmyadmin "/usr/share/phpmyadmin/"
  <Directory "/usr/share/phpmyadmin/">
    Order allow,deny
    Allow from all
    Require all granted
  </Directory>
</VirtualHost>
EOF
)

# setup logfile
# -------------------------------------------------------------------------------------------------------------------- #
# - truncate $LOG_FILE
# > https://computingforgeeks.com/how-to-empty-truncate-log-files-in-linux/
# - write console output in $LOG_FILE by default
# > https://stackoverflow.com/questions/18460186/writing-outputs-to-log-file-and-console/22373735

truncate -s 0 ${LOG_FILE}
exec 3>&1 1>>${LOG_FILE} 2>&1

# setup debian frontend
# -------------------------------------------------------------------------------------------------------------------- #
# - set DEBIAN_FRONTEND to noninteractive
# > https://linuxhint.com/debian_frontend_noninteractive/

export DEBIAN_FRONTEND=noninteractive

# intro
# -------------------------------------------------------------------------------------------------------------------- #

echo -e "install johninamillion/vagrant-focal64-php7.4" 1>&3
echo -e "it might take a while..." 1>&3
echo -e "" 1>&3

echo -e "Installation:" | tee /dev/fd/3

# configure language
# -------------------------------------------------------------------------------------------------------------------- #
# - install language-pack-en-base
# - configure system language by $SYSTEM_LANGUAGE variable
# > https://superuser.com/questions/570952/how-to-change-language-in-a-command-line-software-on-debian
# - configure timezone by $SYSTEM_TIMEZONE variable
# > https://linuxize.com/post/how-to-set-or-change-timezone-on-ubuntu-20-04/

echo -e "\t-install language-pack-en-base" | tee /dev/fd/3
apt-get install -qq -y language-pack-en-base

echo -e "\t-configure system language" | tee /dev/fd/3
export LANG=$SYSTEM_LANGUAGE exif -h
export LC_ALL=$SYSTEM_LANGUAGE exif -h

echo -e "\t-configure timezone" | tee /dev/fd/3
timedatectl set-timezone $SYSTEM_TIMEZONE

# update & upgrade packages
# -------------------------------------------------------------------------------------------------------------------- #
# - update packages
# - upgrade packages

echo -e "\t-update packages" | tee /dev/fd/3
apt-get update -qq

echo -e "\t-upgrade packages" | tee /dev/fd/3
apt-get upgrade -qq -y

# install required software packages
# -------------------------------------------------------------------------------------------------------------------- #
# - install build-essential
# > https://linuxhint.com/install-build-essential-ubuntu/
# - install software-properties-common provides abstraction of the used apt repositories
# > https://askubuntu.com/questions/1000118/what-is-software-properties-common
# - install curl for data transfer
# - install wget for data transfer

echo -e "\t-install software packages" | tee /dev/fd/3

echo -e "\t\t-install build-essential" | tee /dev/fd/3
apt-get install -qq -y build-essential

echo -e "\t\t-install software-properties-common" | tee /dev/fd/3
apt-get install -qq -y software-properties-common

echo -e "\t\t-install curl" | tee /dev/fd/3
apt-get install -qq -y curl

echo -e "\t\t-install wget" | tee /dev/fd/3
apt-get install -qq -y wget

# install terminal tools
# -------------------------------------------------------------------------------------------------------------------- #
# - install gpm
# > https://www.nico.schottelius.org/software/gpm/
# - install mc for file managing in terminal
# > https://midnight-commander.org/
# - install htop for task managing in terminal
# > https://htop.dev/
# - install p7zip, -full & -rar
# > https://7-zip.org/7z.html

echo -e "\t-install terminal tools" | tee /dev/fd/3

echo -e "\t\t-install gpm (general purpose mouse interface)" | tee /dev/fd/3
apt-get install -qq -y gpm

echo -e "\t\t-install htop" | tee /dev/fd/3
apt-get install -qq -y htop

echo -e "\t\t-install mc (midnight commander)" | tee /dev/fd/3
apt-get install -qq -y mc

echo -e "\t\t-install p7zip, -full & -rar" | tee /dev/fd/3
apt-get install -qq -y p7zip p7zip-full p7zip-rar

# install apache2
# -------------------------------------------------------------------------------------------------------------------- #

echo -e "\t-install apache2, -doc & -utils" | tee /dev/fd/3
apt-get install -qq -y apache2 apache2-doc apache2-utils

# install mariadb
# -------------------------------------------------------------------------------------------------------------------- #
# > https://stackoverflow.com/questions/61436858/provisioning-mariadb-on-ubuntu-20-04

echo -e "\t-install mariadb" | tee /dev/fd/3

echo -e "\t\t-add repository" | tee /dev/fd/3
apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
add-apt-repository -y 'deb [arch=amd64] http://mariadb.mirror.globo.tech/repo/10.5/ubuntu focal main'
apt-get update -qq

echo -e "\t\t-install mariadb10.5" | tee /dev/fd/3
debconf-set-selections <<< "mariadb-server-10.5 mariadb-server/root_password password $DATABASE_ROOT_PASSWORD"
debconf-set-selections <<< "mariadb-server-10.5 mariadb-server/root_password_again password $DATABASE_ROOT_PASSWORD"
debconf-set-selections <<< "mariadb-server-10.5 mariadb-server/oneway_migration boolean true"
apt-get install -qq -y mariadb-server-10.5 mariadb-client-10.5

echo -e "\t\t-config root access" | tee /dev/fd/3
mysql -u root -p{$DATABASE_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY '$DATABASE_ROOT_PASSWORD' WITH GRANT OPTION;"
mysql -u root -p{$DATABASE_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$DATABASE_ROOT_PASSWORD' WITH GRANT OPTION;"
mysql -u root -p{$DATABASE_ROOT_PASSWORD} -e "FLUSH PRIVILEGES;"
service mysql restart

# install php7.4
# -------------------------------------------------------------------------------------------------------------------- #

echo -e "\t-install php" | tee /dev/fd/3

echo -e "\t\t-add repository" | tee /dev/fd/3
apt-key adv --recv-keys --keyserver 'hkp://keyserver.ubuntu.com:80' '0xF1656F24C74CD1D8'
add-apt-repository -y ppa:ondrej/php
apt-get update -qq

echo -e "\t\t-install php7.4, -cli, -common, -curl, -gd, -gettext, -json, -mbstring, -mysqli, -xml, xmlrpc & -zip" | tee /dev/fd/3
apt-get install -qq -y php7.4 php7.4-cli php7.4-common php7.4-curl php7.4-gd php7.4-gettext php7.4-json php7.4-mbstring php7.4-mysqli php7.4-xml php7.4-xmlrpc php7.4-zip

echo -e "\t\t-install libapache2-mod-php7.4" | tee /dev/fd/3
apt-get install -qq -y libapache2-mod-php7.4

# install phpmyadmin
# -------------------------------------------------------------------------------------------------------------------- #

echo -e "\t-install phpmyadmin 5.1.0" | tee /dev/fd/3

echo -e "\t\t-download phpmyadmin 5.1.0" | tee /dev/fd/3
cd /usr/share
mkdir /usr/share/phpmyadmin
wget https://files.phpmyadmin.net/phpMyAdmin/5.1.0/phpMyAdmin-5.1.0-all-languages.zip
7z x phpMyAdmin-5.1.0-all-languages.zip
mv /usr/share/phpMyAdmin-5.1.0-all-languages/* /usr/share/phpmyadmin
rm phpMyAdmin-5.1.0-all-languages.zip
rm -rf phpMyAdmin-5.1.0-all-languages

echo -e "\t\t-configure phpmyadmin" | tee /dev/fd/3

chmod -R 0755 ./phpmyadmin
mv /usr/share/phpmyadmin/config.sample.inc.php /usr/share/phpmyadmin/config.inc.php
sed -i "s|cfg\['blowfish_secret'\] = ''|cfg\['blowfish_secret'\] = '${DATABASE_BLOWFISH_SECRET}'|" /usr/share/phpmyadmin/config.inc.php

# configure apache
# -------------------------------------------------------------------------------------------------------------------- #

echo -e "\t-configure apache" | tee /dev/fd/3

echo -e "\t\t-enable mod rewrite" | tee /dev/fd/3
sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf
a2enmod rewrite

echo -e "\t\t-enable mbstring" | tee /dev/fd/3
phpenmod mbstring

echo -e "\t\t-enable mysqli" | tee /dev/fd/3
phpendmod mysqli

# configure virtual host
# -------------------------------------------------------------------------------------------------------------------- #

echo -e "\t-configure virtual host" | tee /dev/fd/3

echo -e "\t\t-create and enable vagrant.conf" | tee /dev/fd/3
echo "${CONF_VAGRANT}" >> /etc/apache2/sites-available/vagrant.conf
a2ensite vagrant.conf

echo -e "\t\t-disable and remove 000-default.conf" | tee /dev/fd/3
a2dissite /etc/apache2/sites-available/000-default.conf
rm /etc/apache2/sites-available/000-default.conf

echo -e "\t\t-restart apache2" | tee /dev/fd/3
service apache2 restart

# update & upgrade packages again
# -------------------------------------------------------------------------------------------------------------------- #
# - update packages
# - upgrade packages

echo -e "\t-update packages" | tee /dev/fd/3
apt-get update -qq

echo -e "\t-upgrade packages" | tee /dev/fd/3
apt-get upgrade -qq -y

# install developer tools
# -------------------------------------------------------------------------------------------------------------------- #
# - install composer
# > https://www.digitalocean.com/community/tutorials/how-to-install-and-use-composer-on-ubuntu-18-04
# - install git
# - install nodejs
# - install npm
# - install npx
# > https://www.npmjs.com/package/npx
# - install yarn
# > https://www.npmjs.com/package/yarn

echo -e "\t-install developer tools" | tee /dev/fd/3

echo -e "\t\t-install composer" | tee /dev/fd/3
curl -sS https://getcomposer.org/installer -o composer-setup.php
php composer-setup.php --install-dir=/usr/local/bin --filename=composer
rm composer-setup.php

echo -e "\t\t-install git" | tee /dev/fd/3
apt-get install -qq -y git

echo -e "\t\t-install nodejs" | tee /dev/fd/3
curl -sL https://deb.nodesource.com/setup_14.x | bash -
apt-get install -qq -y nodejs

echo -e "\t\t-install npm" | tee /dev/fd/3
apt-get install -qq -y npm
npm i -g npm

echo -e "\t\t-install npx" | tee /dev/fd/3
npm i -g npx

echo -e "\t\t-install yarn" | tee /dev/fd/3
npm i -g yarn
