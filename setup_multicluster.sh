#!/bin/bash


# Set up shortcuts to ssh's (as user vagrant
#
#
function section () {
echo " "
echo "***"
echo "*** $@"
echo "***"
}
function sshm1 () {
    echo "  $@" >&2
    #ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i StorageScaleVagrant/virtualbox/.vagrant/machines/*/virtualbox/private_key -p 2222 vagrant@127.0.0.1 $@
    ssh -o StrictHostKeyChecking=no  -i StorageScaleVagrant/virtualbox/.vagrant/machines/*/virtualbox/private_key -p 2222 vagrant@127.0.0.1 $@
}
function sshc () {
    echo "  $@" >&2
    ssh -o StrictHostKeyChecking=no -i client/.vagrant/machines/*/virtualbox/private_key -p 2200 vagrant@127.0.0.1 $@
}

#sshm1 hostname
#sshc hostname

#sshm1 sudo mmlscluster

section "Get the public keys of each cluster"
sshm1 sudo cat /var/mmfs/ssl/id_rsa.pub >id_rsa_demo.pub
sshc  sudo cat /var/mmfs/ssl/id_rsa.pub >id_rsa_wilma_site.pub

section "Give each cluster the public key of the other"
cat id_rsa_wilma_site.pub | sshm1 'cat > /tmp/id_rsa_wilma_site.pub'
cat id_rsa_demo.pub       | sshc  'cat > /tmp/id_rsa_demo.pub'

section "Tell the storage cluster to allow incoming conenctions from wilma_site"
#sshm1 ls -ld /tmp/id_rsa_wilma_site.pub
sshm1 sudo mmauth add wilma_site.example.com -k /tmp/id_rsa_wilma_site.pub

section "Tell the remote cluster where to mount the filesystem from"
#sshc  ls -ld /tmp/id_rsa_demo.pub
sshc sudo mmremotecluster add demo.example.com -n 10.1.2.11 -k /tmp/id_rsa_demo.pub

section "Export the filesystem from the storage cluster"o
sshm1 sudo mmauth grant wilma_site.example.com -f fs1 -a rw

section "Mount the filesystem on the remote cluster"
sshc sudo mmremotefs add fs1 -f fs1 -C demo.example.com -T /ibm/fs1
sshc sudo mmmount fs1
sshc df -t gpfs


section "now test that both side can write a file and the other see it"
SHARED=/ibm/fs1/vagrant
sshm1 mkdir $SHARED
sshm1 chown vagrant:vagrant $SHARED

sshm1 cp /etc/hosts $SHARED/hosts_m1
sshc  cp /etc/hosts $SHARED/hosts_wilma01

sshm1 ls -l $SHARED
sshc  ls -l $SHARED

