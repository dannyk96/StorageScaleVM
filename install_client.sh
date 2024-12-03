#!/bin/bash

cd client

vagrant destroy -f 
vagrant up  >> install_client.log

cat <<EOF
try:
alias sshc="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i client/.vagrant/machines/*/virtualbox/private_key -p 2200 vagrant@127.0.0.1"
EOF
