# INSTALLATION SCRIPT FOR:
#
# Linux 3.16.0-4-amd64
# 1 SMP Debian 3.16.7-ckt25-2+deb8u3 (2016-07-02) x86_64 GNU/Linux
# PRETTY_NAME="Debian GNU/Linux 8 (jessie)"
# NAME="Debian GNU/Linux"
# VERSION_ID="8"
# VERSION="8 (jessie)"

# SET LANG VARS

echo 'export LC_ALL="en_US.UTF-8"'   >> ~/.bashrc
echo 'export LANGUAGE="en_US:en"'    >> ~/.bashrc
echo 'export LANG="en_US.UTF-8"'     >> ~/.bashrc
echo 'export LC_CTYPE="en_US.UTF-8"' >> ~/.bashrc

source ~/.bashrc

# ADD USER

adduser rails --home /home/rails --shell /bin/bash --disabled-password --gecos ''
echo "rails:qwerty12345" | chpasswd

echo "set nocompatible" >> ~/.vimrc
echo ":set backspace=indent,eol,start" >> ~/.vimrc

# Folders & Files for user `rails`

# for ssh
mkdir -p /home/rails/.ssh
chown rails:rails /home/rails/.ssh

# for Nginx
mkdir -p /home/rails/www
chown rails:rails /home/rails/www
chmod -R 0755 /home/rails/www

# for gem install
echo 'gem: --no-document' >> /home/rails/.gemrc
chown rails:rails /home/rails/.gemrc
chmod -R 0644 /home/rails/.gemrc

# for vim
echo "set nocompatible" >> /home/rails/.vimrc
echo ":set backspace=indent,eol,start" >> /home/rails/.vimrc
chown rails:rails /home/rails/.vimrc
chmod -R 0644 /home/rails/.vimrc

# CREATE SWAP

dd if=/dev/zero of=/swapfile bs=1024 count=2048k
chmod 0600 /swapfile
mkswap /swapfile
swapon /swapfile

echo "/swapfile none swap sw 0 0" >> /etc/fstab

echo 10 | tee /proc/sys/vm/swappiness
echo vm.swappiness = 10 | tee -a /etc/sysctl.conf

# BASE SOFT
mv /etc/apt/sources.list /etc/apt/sources.list.original
wget http://debian.mirror.vu.lt/debian-sources.list && mv debian-sources.list /etc/apt/sources.list

apt-get clean
apt-get update
apt-get install build-essential autoconf bison checkinstall curl git-core libodbc1 libc6-dev libreadline6 libreadline6-dev libsqlite3-0 libsqlite3-dev libssl-dev libxml2 libxml2-dev libxslt-dev libxslt1-dev libxslt1.1 libyaml-dev openssl sqlite3 zlib1g zlib1g-dev htop -y

# New Relic Monitor

echo 'deb http://apt.newrelic.com/debian/ newrelic non-free' | tee /etc/apt/sources.list.d/newrelic.list
wget -O- https://download.newrelic.com/548C16BF.gpg | apt-key add -
apt-get update
apt-get install newrelic-sysmond

# IMAGE OPTIMIZERS

apt-get install gifsicle jhead jpegoptim libjpeg-progs optipng pngcrush pngquant -y

cd /tmp/

wget http://static.jonof.id.au/dl/kenutils/pngout-20150319-linux.tar.gz
tar -xvf pngout-20150319-linux.tar.gz
cp /tmp/pngout-20150319-linux/x86_64/pngout /usr/bin/pngout

rm -rf ./pngout-20150319*
cd ~

# IMAGE MAGICK

apt-get install imagemagick libmagickwand-dev -y
convert --version

# NODE
# https://github.com/nodesource/distributions

curl -sL https://deb.nodesource.com/setup_6.x | bash -
apt-get install nodejs -y

# REDIS

cd /tmp/

wget http://download.redis.io/releases/redis-3.2.3.tar.gz
tar -zxvf redis-3.2.3.tar.gz
cd /tmp/redis-3.2.3

make
checkinstall --pkgname=redis-server --pkgversion "3.2.3" --default

cd ..
rm -rf ./redis-3.2.3*
cd ~

# NGINX

cd /tmp

wget http://nginx.org/keys/nginx_signing.key
apt-key add nginx_signing.key

echo 'deb http://nginx.org/packages/debian/ jessie nginx'     >> /etc/apt/sources.list
echo 'deb-src http://nginx.org/packages/debian/ jessie nginx' >> /etc/apt/sources.list

apt-get update
apt-get install nginx

rm -rf ./nginx*
cd ~

# RVM REQUIREMENTS

gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3

\curl -sSL https://get.rvm.io | bash
/usr/local/rvm/bin/rvm requirements

(echo 'yes') | (/usr/local/rvm/bin/rvm implode)

# MYSQL

export DEBIAN_FRONTEND=noninteractive

debconf-set-selections <<< 'mysql-server mysql-server/root_password password qwerty12345'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password qwerty12345'

apt-get install mysql-server mysql-common mysql-client libmysqlclient-dev ruby-mysql -y

unset DEBIAN_FRONTEND

mysql -u root -pqwerty12345 -D mysql -r -B -N -e "CREATE USER 'rails'@'localhost' IDENTIFIED BY 'qwerty12345'"
mysql -u root -pqwerty12345 -D mysql -r -B -N -e "CREATE DATABASE rails_app_db CHARACTER SET utf8 COLLATE utf8_general_ci;"
mysql -u root -pqwerty12345 -D mysql -r -B -N -e "GRANT ALL PRIVILEGES ON rails_app_db.* TO 'rails'@'localhost' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0"
mysql -u root -pqwerty12345 -D mysql -r -B -N -e "SHOW GRANTS FOR 'rails'@'localhost'"

# PSQL
# apt-cache pkgnames postgresql

apt-get install postgresql-9.4 postgresql-server-dev-9.4 libpq-dev -y

su -s /bin/bash -l postgres -c "psql -U postgres -c \"CREATE USER rails WITH PASSWORD 'qwerty12345';\""
su -s /bin/bash -l postgres -c "psql -U postgres -c \"ALTER ROLE rails WITH CREATEDB;\""

su -s /bin/bash -l postgres -c "createdb -E UTF8 -O rails rails_app_db"
su -s /bin/bash -l postgres -c "psql -U postgres -c \"GRANT ALL PRIVILEGES ON DATABASE rails_app_db TO rails;\""

# Pyhon / pip / Pygments

apt-get install python-pip -y
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
