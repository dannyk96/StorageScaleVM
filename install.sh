#!/bin/bash
#
# Run this script to do *everything*
# However you will probably prefer to run sectino by section.
# It particular the basebox creation only needs to be done once
# Also you wil probabyl want to only run a subset of the demos (which can be done in any order)
#
# Dan Kidger  19-12-2024
#
dry_run=""
dry_run="yes"  # comment this out if you want to run everything
if [ "$dry_run" == yes ] ; then
    cmd=echo
else
    cmd=''
fi

    cmd=echo
#set -v
#set -n


#
# Pretty print section titles
#
function section () {
   echo " "
   echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
   echo -e "`date +\%H:%M:%S`  $@"
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


section "1. add VirtualBox to the PATH and show currently running VMs"

# next if for Windows not MacOS
PATH=$PATH:"/c/Program Files/Oracle/VirtualBox/"
#vboxmanage list vms 
vboxmanage list vms --long --sorted |grep  Name
#vboxmanage list vms --sorted |awk '{ printf "%-60s %6s\n", $1, $2 }'

#vboxmanage list hdds| grep -i location 

# This is very useful if you missed seeing the port forwarding at the beginning of the vagrant launch
# virtualbox_m1_1733833761918_7774
# $ vboxmanage showvminfo virtualbox_m1_1733833761918_7774|grep Rule
# NIC 1 Rule(0):   name = ssh, protocol = tcp, host ip = 127.0.0.1, host port = 2200, guest ip = , guest port = 22
# NIC 1 Rule(1):   name = tcp4438, protocol = tcp, host ip = , host port = 4438, guest ip = , guest port = 443

section "2 Install Vagrant from https://developer.hashicorp.com/vagrant/install?product_intent=vagrant"

section "3 Configure Vagrant for virtualbox"
# this is perhaps more for clouds with dynamic IP addrresses?
echo vagrant plugin install vagrant-vbguest

section "4. Install Virtualbox from https://www.virtualbox.org/wiki/Downloads"

section "5. Install the Base VM image, including Scale\'s prerequisites"
#$cmd  (vagrant box list|grep StorageScale_base) || (
#   time ./install_basebox.sh
#)

section "6. Install  a VM with Spectrum Scale"
# note that we should delete the VM if already exists
$cmd ./install_scale.sh

section "7. Install a client (using the same basebox VM image"
$cmd ./install_client.sh


section "8. Setup a multicluster mount betweeen the two clusters"
$cmd ./setup_multicluster.sh

section "9. Setup an S3 mount between the two clusters"
$cmd ./setup_mms3.sh


section "10. Setup an NFS mount between the two clusters"
$cmd ./setup_nfs.sh

section "11. Test the Rest API"
$cmd ./test_restapi.sh

# is there anything to intsall - or is it a set of demo restapi calls?
#
# Think too about using the RestAPI to set multicluster - that would be very cool
echo " (Do not use) time ./install_restapi.sh"

# future
# some clever restapi stuff etc

section "*** All Done"
