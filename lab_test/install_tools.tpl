#!/bin/bash

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install apache2 php make -y
apt-get install php7.4-pgsql php7.4-xml php7.4-mbstring php7.4-curl php7.4-zip php7.4-gd php7.4-intl php7.4-xmlrpc php7.4-soap php-redis tcl tk gcc -y
#sudo systemctl restart apache2




Test install of redis-cli without tk and tcl



#sudo apt-get install -y tcl tk
#sudo apt-get install php-redis

git clone -b MOODLE_39_STABLE git://git.moodle.org/moodle.git

chown www-data. -R moodle/
cp -ar moodle /var/www/html/

git clone https://github.com/aws/efs-utils
apt-get install binutils -y
cd efs-utils/
./build-deb.sh
apt-get  install ./build/amazon-efs-utils*deb -y
cd /var/www/ ; mkdir moodledata
sudo mount -t efs -o tls ${efs_mount}:/ moodledata
chown www-data. -R /var/www/
wget http://download.redis.io/redis-stable.tar.gz
tar xvzf redis-stable.tar.gz
cd redis-stable
make distclean
make
sudo systemctl restart apache2
echo "* * * * *    /usr/bin/php /path/to/moodle/admin/cli/cron.php >/dev/null" | crontab -
#cp -ar /home/ubuntu/moodle/ /var/www/html/ ; chown www-data. -R moodle/