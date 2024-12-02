#!/bin/bash


PATH=$PATH:"/c/Program Files/Oracle/VirtualBox/"
vboxmanage list vms
vboxmanage list hdds
exit

# Insta;l; Vagrant
# from https://developer.hashicorp.com/vagrant/install?product_intent=vagrant
# Configure Vagrant
# this is for virtualbox
echo vagrant plugin install vagrant-vbguest
# this is perhaps more fro clouds with dynamic IP addrresses?
echo vagrant plugin install vagrant-vbguest

#Install Virtualbox
# caveat : some employers block this URL :-(
# from https://www.virtualbox.org/wiki/Downloads

time ./install_basebox.sh

time ./install_scale.sh


echo " time ./install_restapi.sh"

# future
# some clever restapi stuff etc

echo "*** All Done"
