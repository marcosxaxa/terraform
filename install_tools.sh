#!/bin/bash

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install apache2 php -y
apt-get install php7.4-pgsql php7.4-xml php7.4-mbstring php7.4-curl php7.4-zip php7.4-gd php7.4-intl php7.4-xmlrpc php7.4-soap -y
#sudo systemctl restart apache2

git clone -b MOODLE_39_STABLE git://git.moodle.org/moodle.git

chown www-data. -R moodle/
cp -ar moodle /var/www/html/

git clone https://github.com/aws/efs-utils
apt-get -y install binutils
cd efs-utils/
./build-deb.sh
apt-get -y install ./build/amazon-efs-utils*deb
cd /var/www/ ; mkdir moodledata
sudo mount -t efs -o tls fs-4a9c41c8:/ moodledata
chown www-data. -R /var/www/
sudo systemctl restart apache2
#cp -ar /home/ubuntu/moodle/ /var/www/html/ ; chown www-data. -R moodle/