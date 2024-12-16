#!/bin/bash


# be careful not to fill up the root filessystem of the new VM
cp Storage_Scale_Developer-*-Linux.zip client/setup

# Remove any existing VM first
# in a subshell because we have a 'cd' 
(cd client && vagrant destroy -f)


cd client && time vagrant up

SSHC="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i .vagrant/machines/*/virtualbox/private_key vagrant@10.1.2.21"
pwd
echo -e "we can ssh in with\n $SSHC \n viz:\n"

$SSHC uptime
$SSHC mmlscluster

