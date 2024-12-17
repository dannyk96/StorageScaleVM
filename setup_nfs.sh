#!/bin/bash
#
#   Configure the S3 Interface : both client and server sides
# for debug
#set +x
#set -e

#
# Pretty print section titles
#
function section () {
   echo " "
   echo "==================================================================================================="
   echo -e "`date +\%H:%M:%S`  $@"
   echo "==================================================================================================="
}
# 
# Set up shortcuts to ssh's (as user vagrant
#
function sshm1 () {
    echo "  $@" >&2
    ssh -o StrictHostKeyChecking=no  -i StorageScaleVagrant/virtualbox/.vagrant/machines/*/virtualbox/private_key  vagrant@10.1.2.11 $@
}
function sshc1 () {
    echo "  $@" >&2
    ssh -o StrictHostKeyChecking=no -i client/.vagrant/machines/*/virtualbox/private_key vagrant@10.1.2.21 $@
}


cat << EOF
This Scripts Set up the NFS mount on both sides and tests:

   1. On the server enable NFS via CES servicer"
   2. On the server create an NFS export "
   3. On the the client create an NFS mount "
   4. Upload a file"

EOF



section "1. On the server enable NFS via CES servicer"

echo "===> We need to only do this if NFS is not yet enaabled"
sshm1 <<EOF
(sudo mmces service list | head -1 |grep NFS)  || (
# next line is needed to avoid:
#   "You cannot enable/disable any of the smb/nfs protocols because auth has been configured"
sudo mmuserauth service remove --data-access-method file
sudo /usr/lpp/mmfs/5.2.2.0/ansible-toolkit/spectrumscale enable nfs
sudo /usr/lpp/mmfs/5.2.2.0/ansible-toolkit/spectrumscale deploy
# This might be already done for us?
# sudo mmces service enable NFS
)
EOF

echo "===> Make sure the CES has the right floating IP address"
sshm1 'sudo mmces address add --ces-ip 10.1.2.31'


echo "===> now start the NFS servic2"
sshm1 sudo mmces service start NFS



section "2. On the server create an NFS export "

echo "===> choose local authentication  (or NIS or ADi) "
#sshm1 mmuserauth service create --type local --data-access-method file
sshm1 sudo mmuserauth service create --data-access-method file  --type userdefined

echo "===> Check authentiation method is defined"
sshm1 sudo mmuserauth service check

echo "===> Now create the NFS export"
sshc1 sudo umount /nfs/fs1 --force
sshm1 sudo mmnfs export remove /ibm/fs1
sshm1 'sudo mmnfs export add /ibm/fs1 --client "10.1.2.0/24(Access_Type=RW)"'

echo "===> Create a directory that the client can write to"
# This perhaps should have been part of the original Vagrantfilei (./install_scale.sh)
sshm1 sudo mkdir -p /ibm/fs1/vagrant
sshm1 sudo chown vagrant:vagrant /ibm/fs1/vagrant

echo "===> show all exports"
sshm1 sudo mmnfs export list

section "3. On the the client create an NFS mount "

echo "===> Create an /etc/fstab entry"
# ideally we should delete any existing entries first?
# using sed or ex
sshc1 sudo sed -i.bak "/cesip.example.com/g"
sshc1 'echo  "cesip.example.com:/ibm/fs1      /nfs/fs1    nfs     defaults 0 0" |sudo tee -a /etc/fstab'

echo "===> Create and chmod the mountpoint"
sshc1 sudo mkdir -p /nfs/fs1
sshc1 sudo chmod 777 /nfs/fs1

echo "===> Perform the remote mount"
sshc1 sudo mount /nfs/fs1


section "4. Upload a file"

echo "==> create from the client"
# be careful if user vagrant cannot create /nfs/fs1/vagrant ?
sshc1 << EOF
mkdir -p /nfs/fs1/vagrant/cologne
cp /etc/hosts /nfs/fs1/vagrant/cologne/hosts_$(date +%H_%M_%S)
date
EOF

echo "==> and compare on the server"
sshm1 sudo ls -lrt /ibm/fs1/vagrant/*

section "All done"

