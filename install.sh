#!/bin/bash

dryrun=.true.
#
# Pretty print section titles
#
function section () {
   echo " "
   echo "==================================================================================================="
   echo -e "`date +\%H:%M:%S`  $@"
   echo "==================================================================================================="
}
cat <<EOF
section "2. Install Vagrant from https://developer.hashicorp.com/vagrant/install?product_intent=vagrant"
section "3. Configure Vagrant for virtualbox"
section "4. Install Virtualbox from https://www.virtualbox.org/wiki/Downloads"
section "5. Install the Base VM image, including Scale\'s prerequisites"
section "6. Install  a VM with Spectrum Scale"
section "7. Install a client (using the same basebox VM image"
section "8. Setup a multicluster mount betweeen the two clusters"
section "9. Setup an S3 mount between the two clusters"
section "10. Setup an NFS mount between the two clusters"
section "11. Test the Rest API"
EOF


# next if for Windows not MacOS
PATH=$PATH:"/c/Program Files/Oracle/VirtualBox/"
vboxmanage list vms 
#vboxmanage list hdds| grep -i location 

# This is very useful if you missed seeing the port forwarding at the beginning of the vagrant launch
# virtualbox_m1_1733833761918_7774
# $ vboxmanage showvminfo virtualbox_m1_1733833761918_7774|grep Rule
# NIC 1 Rule(0):   name = ssh, protocol = tcp, host ip = 127.0.0.1, host port = 2200, guest ip = , guest port = 22
# NIC 1 Rule(1):   name = tcp4438, protocol = tcp, host ip = , host port = 4438, guest ip = , guest port = 443

section "2 Install Vagrant from https://developer.hashicorp.com/vagrant/install?product_intent=vagrant"

section "3 Configure Vagrant for virtualbox"
echo vagrant plugin install vagrant-vbguest

# this is perhaps more for clouds with dynamic IP addrresses?

section "4. Install Virtualbox from https://www.virtualbox.org/wiki/Downloads"


section "5. Install the Base VM image, including Scale\'s prerequisites"
if [ ! $dryrun ]; then
time ./install_basebox.sh
fi


section "6. Install  a VM with Spectrum Scale"
# note that we should delete the VM if already exists
if [ ! $dryrun ]; then
time ./install_scale.sh
fi

section "7. Install a client (using the same basebox VM image"
if [ ! $dryrun ]; then
time ./install_client.sh
fi


section "8. Setup a multicluster mount betweeen the two clusters"
if [ ! $dryrun ]; then
./setup_multicluster.sh
fi

section "9. Setup an S3 mount between the two clusters"
if [ ! $dryrun ]; then
./setup_mms3.sh
fi


section "10. Setup an NFS mount between the two clusters"
if [ ! $dryrun ]; then
./setup_nfs.sh
fi

section "11. Test the Rest API"
if [ ! $dryrun ]; then
time ./test_restapi.sh
fi

# is there anything to intsall - or is it a set of demo restapi calls?
#
# Think too about using the RestAPI to set multicluster - that would be very cool
echo " (Do not use) time ./install_restapi.sh"

# future
# some clever restapi stuff etc

section "*** All Done"
