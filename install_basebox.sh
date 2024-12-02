#!/bin/bash
#
# I really would have prefered to do this using Ansible playbooks
# but for now lats just script it in bash
#
#mkdir dan && cd dan
echo "*** Checkout the latest copy of StorwageScaleVagrant"
#  use https or ssh ?

# Have the Vagrant scripts been downlaoded yet?
if [ ! -d StorageScaleVagrant ]; then
  git clone https://github.com/IBM/StorageScaleVagrant.git
fi
cd StorageScaleVagrant


# This patch fixes :
#   1. "(Peer certificate cannot be authenticated with given CA certificates) "
#   hmm conider using something inline here, rather than including a patchfile in my git repo?
#patch  -p1 -i ../vagrantfile8.patch
#
# consider too editing the Vagrant file to load a plugin Vagrant file of my wn?



echo "*** Fire up Vagrant to create the base o/s image"
cd virtualbox/prep-box
time vagrant up > install_prepbox.log

ls -lrt
echo "*** Package up this VM into a Vagrent 'box'"
if [ ! -f StorageScale_base.box ]; then
   rm StorageScale_base.box
fi
time vagrant package StorageScale_base --output StorageScale_base.box

# optional step
# time vagrant destroy -f

echo "*** All Done"

