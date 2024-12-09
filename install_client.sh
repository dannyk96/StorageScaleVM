#!/bin/bash


cp Storage_Scale_Developer-*-Linux.zip client/setup

# in a subshell because we have a 'cd' 
{
  cd client
  vagrant destroy -f 
  vagrant up  >> install_client.log
}

SSHC="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i client/.vagrant/machines/*/virtualbox/private_key vagrant@10.1.2.21"
pwd
echo -e "we can ssh in with\n $SSHC"

$SSHC uptime
$SSHC mmlscluster

