#!/bin/bash

function section () {
   echo " "
   echo "==================================================================="
   echo "                  $@"
   echo "==================================================================="
}

PATH=$PATH:"/c/Program Files/Oracle/VirtualBox/"
vboxmanage list vms
vboxmanage list hdds

# Install Vagrant
# from https://developer.hashicorp.com/vagrant/install?product_intent=vagrant
# Configure Vagrant
# this is for virtualbox
echo vagrant plugin install vagrant-vbguest
# this is perhaps more fro clouds with dynamic IP addrresses?

#Install Virtualbox
# caveat : some employers block this URL :-(
# from https://www.virtualbox.org/wiki/Downloads


section "Install the Base VM image, including Scale''s prerequisites"
#time ./install_basebox.sh


section "Install  a VM with Spectrum Scale"
time ./install_scale.sh


section "Install a client (using the same basebox VM image"
time ./install_client.sh


section "Setup a multicluster mount betweeen the two clusters"
./setup_multicluster.sh


section "Test the Rest API"
time ./test_restapi.sh


# is there anything to intsall - or is it a set of demo restapi calls?
#
# Think too about using the RestAPI to set multicluster - that would be very cool
#

echo " (Do not use) time ./install_restapi.sh"

# future
# some clever restapi stuff etc

echo "*** All Done"
