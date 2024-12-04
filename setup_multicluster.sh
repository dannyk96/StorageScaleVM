#!/bin/bash


#
# Pretty primt section titles
#
function section () {
   echo " "
   echo "***"
   echo "*** $@"
   echo "***"
}
# 
# Set up shortcuts to ssh's (as user vagrant
#
function sshm1 () {
    echo "  $@" >&2
    ssh -o StrictHostKeyChecking=no  -i StorageScaleVagrant/virtualbox/.vagrant/machines/*/virtualbox/private_key  vagrant@10.1.2.11 $@
}
function sshc () {
    echo "  $@" >&2
    ssh -o StrictHostKeyChecking=no -i client/.vagrant/machines/*/virtualbox/private_key vagrant@10.1.2.21 $@
}


cat << EOF
   This Demo Illustartes how to configured a remote mount from one cluster to the other
   Steps:
      1. Get the Public key of each cluster and give to the other
      2. Tell the storage cluster to accept conenctions from the remote
      3. Tell the remote cluster the IP address to contact on the storage cluster
      4. export the filesystem
      5. set the mount point on teh remote and mount the filesystem
   See documenation at:  https://www.ibm.com/docs/en/storage-scale/5.1.9?topic=system-mounting-remote-gpfs-file
EOF


section "1. Get the public keys of each cluster"
sshm1 sudo cat /var/mmfs/ssl/id_rsa.pub >id_rsa_demo.pub
sshc  sudo cat /var/mmfs/ssl/id_rsa.pub >id_rsa_wilma_site.pub


section "   Give each cluster the public key of the other"
cat id_rsa_wilma_site.pub | sshm1 'cat > /tmp/id_rsa_wilma_site.pub'
cat id_rsa_demo.pub       | sshc  'cat > /tmp/id_rsa_demo.pub'


section "2. Tell the storage cluster to allow incoming conenctions from wilma_site"
sshm1 sudo mmauth add wilma_site.example.com -k /tmp/id_rsa_wilma_site.pub


section "3. Tell the remote cluster where to mount the filesystem from"
#sshc  ls -ld /tmp/id_rsa_demo.pub
sshc sudo mmremotecluster add demo.example.com -n 10.1.2.11 -k /tmp/id_rsa_demo.pub


section "4. Export the filesystem from the storage cluster"o
sshm1 sudo mmauth grant wilma_site.example.com -f fs1 -a rw


section "5. Mount the filesystem on the remote cluster"
sshc sudo mmremotefs add fs1 -f fs1 -C demo.example.com -T /ibm/fs1
sshc sudo mmmount fs1
sshc df -t gpfs


section "now test that both side can write a file and the other see it"
SHARED=/ibm/fs1/vagrant
sshm1 sudo mkdir $SHARED
sshm1 sudo chown vagrant:vagrant $SHARED

sshm1 cp /etc/hosts $SHARED/hosts_m1
sshc  cp /etc/hosts $SHARED/hosts_wilma01

sshm1 ls -l $SHARED
sshc  ls -l $SHARED

