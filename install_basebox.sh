#!/bin/bash
#
# I really would have prefered to do this using Ansible playbooks
# but for now lats just script it in bash
#
#mkdir dan && cd dan
echo "*** Checkout the latest copy of StorwageScaleVagrant"
#  use https or ssh ?
git clone https://github.com/IBM/StorageScaleVagrant.git
cd StorageScaleVagrant


patch  -p1 -i ../vagrantfile8.patch

echo "*** Fire up Vagrant to create the base o/s image"
cd virtualbox/prep-box
time vagrant up > install_prepbox.log

ls -lrt
echo "*** Package up this VM into a Vagrent 'box'"
time vagrant package StorageScale_base --output StorageScale_base.box

# optional step
vagrant destroy -f

echo "*** All Done"

