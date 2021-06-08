# vagrant-focal64-php7.4

---

## Table of Contents
- [Environment](#environment)
    - [Installed Packages](#installed-packages)
- [System Requirements](#system-requirements)
    - [Install Requirements](#install-requirements)
        - [macOS](#macos)
        - [Windows](#windows)
        - [Ubuntu](#ubuntu-via-terminal)
        - [Other Linux Distributions](#other-linux-distributions)
- [Usage](#usage)
    - [Installation](#installation)
    - [Deinstallation](#deinstallation)
    - [Access via SSH](#access-via-ssh)
- [Troubleshooting](#troubleshooting)

---

## Environment
- [**Ubuntu** *20.04 (Focal Fossa) 64-Bit*](https://releases.ubuntu.com/20.04/)
### Installed Packages
#### AMP Stack
- [**Apache**](https://httpd.apache.org/) *2.4.**
- [**MariaDB**](https://mariadb.org/) *10.5.**
- [**PHP** *7.4*](https://www.php.net/releases/7_4_0.php)
- [**phpmyadmin**](https://www.phpmyadmin.net/) *5.1.0**
#### Developer Tools
- [**Composer**](https://getcomposer.org/) *2.0.13 or Higher*
- [**GIT**](https://git-scm.com/) *2.25.1 or Higher*
- [**NodeJS**](https://nodejs.org/en/) *14.16.1 or Higher*
- [**NPM**](https://www.npmjs.com/) *7.12.1 or Higher*
- [**NPX**](https://www.npmjs.com/package/npx) *10.2.2 or Higher*
- [**Yarn**](https://www.npmjs.com/package/yarn)  *1.22.10 or Higher*
#### Terminal Tools
- [**Midnight Commander**](https://midnight-commander.org/)
- [**HTOP**](https://htop.dev/)
- [**7ZIP**](https://www.7-zip.org/)
#### PHP Libaries
- [**cli**](https://www.php.net/manual/en/features.commandline.php)
- **common**
- [**curl**](https://www.php.net/manual/en/book.curl.php)
- [**gd**](https://www.php.net/manual/en/book.image.php)
- [**gettext**](https://www.php.net/manual/en/book.gettext.php)
- [**json**](https://www.php.net/manual/en/book.json.php)
- [**mbstring**](https://www.php.net/manual/en/book.mbstring.php)
- [**mysqli**](https://www.php.net/manual/en/book.mysqli.php)
- [**xml**](https://www.php.net/manual/en/book.xml.php)
- [**xmlrpc**](https://www.php.net/manual/en/book.xmlrpc.php)
- [**zip**](https://www.php.net/manual/en/book.zip.php)

---

## System Requirements
- [**VirtualBox**](https://www.virtualbox.org/) 5.2.* or Higher (tested with 5.2.42 on Ubuntu 18.04)
- [**Vagrant**](https://www.vagrantup.com/) 2.2.* or Higher (tested with 2.2.16 on Ubuntu 18.04)

### Install Requirements
#### macOS
- To install Vagrant, click the [Download](https://releases.hashicorp.com/vagrant/2.2.16/vagrant_2.2.16_x86_64.dmg) link and follow the instructions.  
- To install VirtualBox, click the [Download](https://download.virtualbox.org/virtualbox/6.1.22/VirtualBox-6.1.22-144080-OSX.dmg) link and follow the [instructions](https://www.virtualbox.org/manual/UserManual.html#installation-mac).
#### macOS (via Terminal)
```bash
# install virtualbox
$ brew install --cask virtualbox
# install vagrant
$ brew tap hashicorp/tap
$ brew install hashicorp/tap/vagrant
```
#### Windows
- To install Vagrant, click the Download link for the [32bit](https://releases.hashicorp.com/vagrant/2.2.16/vagrant_2.2.16_i686.msi) or [64bit](https://releases.hashicorp.com/vagrant/2.2.16/vagrant_2.2.16_x86_64.msi) version and follow the instructions.
- To install Virtualbox, click the [Download](https://download.virtualbox.org/virtualbox/6.1.22/VirtualBox-6.1.22-144080-Win.exe) link and follow the [instructions](https://www.virtualbox.org/manual/UserManual.html#installation_windows).
#### Ubuntu (via Terminal)
```bash
$ sudo apt-get update
# install virtualbox
$ sudo apt-get install virtualbox virtualbox-dkms virtualbox-qt
# install vagrant
$ curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
$ sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
$ sudo apt-get update && sudo apt-get install vagrant
```
#### Other Linux Distributions
To install Virtualbox, choose a [package](https://www.virtualbox.org/wiki/Linux_Downloads) and follow the [instructions](https://www.virtualbox.org/manual/UserManual.html#install-linux-host).

---

## Usage
### Vagrant
#### Installation
```bash
# you@local: ./vagrant-focal64-php7.4
$ vagrant up
```

#### Deinstallation
```bash
# you@local: ./vagrant-focal64-php7.4
$ vagrant destroy
```

#### Access via SSH
```bash
# you@local: ./vagrant-focal64-php7.4
$ vagrant ssh
```

#### Read Log
```bash
# you@local: ./vagrant-focal64-php7.4
$ less vagrant/build.log
```

#### Synced Folder/Files
*It's recommended to work with an automatic deployment instead of working in the synced folder directly!*

All files in the `./sync/html/` folder are synced to `/var/www/html/` on the vagrant.

Instructions for automaticly deployment:
- [Jetbrains - IntelliJ IDEA](https://www.jetbrains.com/help/idea/tutorial-deployment-in-product.html)
- [Jetbrains- PHP Storm](https://www.jetbrains.com/help/phpstorm/deployment-in-PhpStorm.html)
- [Jetbrains - WEB Storm](https://www.jetbrains.com/help/webstorm/settings-deployment.html#preferences-of-the-selected-deployment-configuration)

### Apache

#### Create Site Configuration

```bash
# create example.conf file
# vagrant@ubuntu-focal: ./
$ cd /etc/apache2/sites-available/
$ touch example.conf
# edit example.conf file
$ sudo nano example.conf
```

**example.conf**
```
<VirtualHost *:80>
  DocumentRoot /your/directory/path
  <Directory /your/directory/path>
    Options Indexes FollowSymLinks MultiViews
    AllowOverride All
    Require all granted
  </Directory>
</VirtualHost>
```

#### Enable Site
```bash
# vagrant@ubuntu-focal: ./
$ a2ensite example.conf
```

#### Disable Site
```bash
# vagrant@ubuntu-focal: ./
$ a2dissite example.conf
```

### MySQL
|Host| Port | Username | Password | 
| --- | --- | --- | --- | 
| localhost | 3306 | `root` | `root` |

#### Work with PHPMYADMIN in your Browser
Just enter `localhost:8080/phpmyadmin` in your Browser and start.

#### Enter MYSQL via Terminal
```bash
# vagrant@ubuntu-focal: ./
$ mysql -u root -proot
```

---

## Troubleshooting
### Vagrant
#### Permissions denied @ rb_sysopen
```bash
# you@local: ./vagrant-focal64-php7.4
$ sudo chmod -R 0755 ../vagrant-focal64-php7.4
```
