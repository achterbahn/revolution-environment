#!/usr/bin/env bash

# disable standard login message from ubuntu
sudo touch ".hushlogin"

# copy custom profile settings
sudo cp /vagrant/_server/bootstrap/.bashrc /home/vagrant/
sudo cp /vagrant/_server/bootstrap/.profile /home/vagrant/

# copy modx build config files to dev env
sudo cp /vagrant/_server/bootstrap/extra/config/build.config.php /www/_build
sudo cp /vagrant/_server/bootstrap/extra/config/build.properties.php /www/_build

# final autoremove of unused packages to reduce the size of virtualbox image
sudo apt-get -y autoremove
