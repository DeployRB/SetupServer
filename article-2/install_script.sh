#!/bin/bash
# INSTALLATION SCRIPT FOR:
#
# Linux 3.16.0-4-amd64
# 1 SMP Debian 3.16.7-ckt25-2+deb8u3 (2016-07-02) x86_64 GNU/Linux
# PRETTY_NAME="Debian GNU/Linux 8 (jessie)"
# NAME="Debian GNU/Linux"
# VERSION_ID="8"
# VERSION="8 (jessie)"

# SET LANG VARS

# BASE SOFT
# wget http://debian.mirror.vu.lt/debian-sources.list && mv debian-sources.list /etc/apt/sources.list

mv /etc/apt/sources.list /etc/apt/sources.list.backup
echo "deb http://httpredir.debian.org/debian/ stable main contrib non-free
deb http://httpredir.debian.org/debian/ stable-updates main contrib non-free
deb http://security.debian.org/ stable/updates main contrib non-free
deb-src http://httpredir.debian.org/debian/ stable main contrib non-free
deb-src http://httpredir.debian.org/debian/ stable-updates main contrib non-free
deb-src http://security.debian.org/ stable/updates main contrib non-free

deb http://httpredir.debian.org/debian jessie-backports main contrib non-free
deb-src http://httpredir.debian.org/debian jessie-backports main contrib non-free
" > /etc/apt/sources.list

apt-get clean
apt-get update && apt-get install -y coreutils

MYPASS=`date +%s%N | sha256sum | head -c 24`

echo "########################################" >> ~/.my_password
echo "Mysql, Postgresql, Rails pass is $MYPASS" >> ~/.my_password
echo "########################################" >> ~/.my_password

echo 'export LANG="en_US.UTF-8"'     >> ~/.bashrc
echo 'export LANGUAGE="en_US:en"'    >> ~/.bashrc
echo 'export LC_ALL="en_US.UTF-8"'   >> ~/.bashrc
echo 'export LC_CTYPE="en_US.UTF-8"' >> ~/.bashrc

source ~/.bashrc

# ADD USER
adduser rails --home /home/rails --shell /bin/bash --disabled-password --gecos ''
echo "rails:$MYPASS" | chpasswd

echo "set nocompatible" >> ~/.vimrc
echo ":set backspace=indent,eol,start" >> ~/.vimrc

# Folders & Files for user `rails`

# for ssh
mkdir -p /home/rails/.ssh
chmod 0700 /home/rails/.ssh

# for Nginx
mkdir -p /home/rails/www
chmod 0755 /home/rails/www

# for gem install
echo 'gem: --no-document' >> /home/rails/.gemrc
chmod 0644 /home/rails/.gemrc

# for vim
echo "set nocompatible" >> /home/rails/.vimrc
echo ":set backspace=indent,eol,start" >> /home/rails/.vimrc
chmod 0644 /home/rails/.vimrc

# Set rails:rails for all in /home/rails/
chown -R rails:rails /home/rails/

# CREATE SWAP
dd if=/dev/zero of=/swapfile bs=1024 count=2048k
chmod 0600 /swapfile
mkswap /swapfile
swapon /swapfile

echo "/swapfile none swap sw 0 0" >> /etc/fstab

echo vm.swappiness=10 | tee -a /etc/sysctl.conf
sysctl --system

# Minimal soft pack
apt-get install -y sudo screen dialog apt-transport-https ca-certificates \
  man-db deborphan aptitude bc bash-completion command-not-found \
  python-software-properties htop nmon iotop dstat vnstat unzip zip unar pigz \
  p7zip-full logrotate wget curl w3m lftp rsync openssh-server telnet nano mc \
  pv less sysstat ncdu ethtool dnsutils mtr-tiny rkhunter ntpdate ntp vim

# Requirements libs
apt-get install -y build-essential autoconf bison checkinstall git-core \
  libodbc1 libc6-dev libreadline6 libreadline6-dev libsqlite3-0 libsqlite3-dev \
  libssl-dev libxml2 libxml2-dev libxslt-dev libxslt1-dev libxslt1.1 \
  libyaml-dev openssl sqlite3 zlib1g zlib1g-dev

# New Relic Monitor
echo 'deb http://apt.newrelic.com/debian/ newrelic non-free' | tee /etc/apt/sources.list.d/newrelic.list
wget -O- https://download.newrelic.com/548C16BF.gpg | apt-key add -
apt-get update
apt-get install -y newrelic-sysmond

# IMAGE OPTIMIZERS
apt-get install -y gifsicle jhead jpegoptim libjpeg-progs optipng pngcrush pngquant

cd /tmp/

wget http://static.jonof.id.au/dl/kenutils/pngout-20150319-linux.tar.gz
tar -xvf pngout-20150319-linux.tar.gz
cp /tmp/pngout-20150319-linux/x86_64/pngout /usr/local/bin/pngout

rm -rf ./pngout-20150319*
cd ~

# IMAGE MAGICK

apt-get install -y imagemagick libmagickwand-dev
convert --version

# NODE
# https://github.com/nodesource/distributions

curl -sL https://deb.nodesource.com/setup_6.x | bash -
apt-get install -y nodejs

# REDIS

# cd /tmp/

# wget http://download.redis.io/releases/redis-3.2.3.tar.gz
# tar -zxvf redis-3.2.3.tar.gz
# cd /tmp/redis-3.2.3

# make
# checkinstall --pkgname=redis-server --pkgversion "3.2.3" --default

# cd ..
# rm -rf ./redis-3.2.3*
# cd ~

apt-get install -y redis-server

# NGINX

curl http://nginx.org/keys/nginx_signing.key | apt-key add -

echo 'deb http://nginx.org/packages/debian/ jessie nginx'     >> /etc/apt/sources.list.d/nginx.list
echo 'deb-src http://nginx.org/packages/debian/ jessie nginx' >> /etc/apt/sources.list.d/nginx.list

apt-get update
apt-get install -y nginx

# RVM REQUIREMENTS

gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3

\curl -sSL https://get.rvm.io | bash
/usr/local/rvm/bin/rvm requirements

(echo 'yes') | (/usr/local/rvm/bin/rvm implode)

# MYSQL

export DEBIAN_FRONTEND=noninteractive

debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYPASS"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYPASS"

apt-get install -y mysql-server mysql-common mysql-client libmysqlclient-dev ruby-mysql

unset DEBIAN_FRONTEND

echo "[client]
user=root
password=$MYPASS
" >> ~/.my.cnf

chmod 600 ~/.my.cnf

mysql -D mysql -r -B -N -e "CREATE USER 'rails'@'localhost' IDENTIFIED BY '$MYPASS'"
mysql -D mysql -r -B -N -e "CREATE DATABASE rails_app_db CHARACTER SET utf8 COLLATE utf8_general_ci;"
mysql -D mysql -r -B -N -e "GRANT ALL PRIVILEGES ON rails_app_db.* TO 'rails'@'localhost' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0"
mysql -D mysql -r -B -N -e "SHOW GRANTS FOR 'rails'@'localhost'"

# PSQL
# apt-cache pkgnames postgresql

apt-get install -y postgresql libpq-dev

su -s /bin/bash -l postgres -c "psql -U postgres -c \"CREATE USER rails WITH PASSWORD '$MYPASS';\""
su -s /bin/bash -l postgres -c "psql -U postgres -c \"ALTER ROLE rails WITH CREATEDB;\""

su -s /bin/bash -l postgres -c "createdb -E UTF8 -O rails rails_app_db"
su -s /bin/bash -l postgres -c "psql -U postgres -c \"GRANT ALL PRIVILEGES ON DATABASE rails_app_db TO rails;\""

# Pyhon / pip / Pygments

apt-get install -y python-pip
pip install --upgrade Pygments

# pip list | grep Pygments
# which pygmentize

# SPHINX SEARCH

cd /tmp

wget http://sphinxsearch.com/files/sphinxsearch_2.2.11-release-1~jessie_amd64.deb
dpkg -i sphinxsearch_2.2.11-release-1~jessie_amd64.deb
rm -rf ./sphinxsearch*
cd ~

### RAILS USER ###

su -s /bin/bash -l rails -c "echo 'export LC_ALL=\"en_US.UTF-8\"'   >> ~/.bashrc"
su -s /bin/bash -l rails -c "echo 'export LANGUAGE=\"en_US:en\"'    >> ~/.bashrc"
su -s /bin/bash -l rails -c "echo 'export LANG=\"en_US.UTF-8\"'     >> ~/.bashrc"
su -s /bin/bash -l rails -c "echo 'export LC_CTYPE=\"en_US.UTF-8\"' >> ~/.bashrc"
su -s /bin/bash -l rails -c "source ~/.bashrc"

su -s /bin/bash -l rails -c "\curl -sSL https://get.rvm.io | bash"
su -s /bin/bash -l rails -c "source ~/.bash_profile"
su -s /bin/bash -l rails -c "which rvm"
su -s /bin/bash -l rails -c "rvm install ruby-2.2.4"
su -s /bin/bash -l rails -c "(rvm use ruby-2.2.4) && (rvm gemset use rails_app --create)"
su -s /bin/bash -l rails -c "rvm ruby-2.2.4@rails_app do gem install bundler"

echo ""
echo "########################################"
echo "cat ~/.my_password"
echo "########################################"
echo ""

cat ~/.my_password
