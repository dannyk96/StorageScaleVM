#!/bin/bash
# for debug
set +x
#set -e

#
# Pretty print section titles
#
function section () {
   echo " "
   echo "==================================================================================================="
   echo "`date +\%H:%M:%S`  $@"
   echo "==================================================================================================="
}
# 
# Set up shortcuts to ssh's (as user vagrant
#
set +x
set -e

function sshm1 () {
    echo "  $@" >&2
    ssh -o StrictHostKeyChecking=no  -i StorageScaleVagrant/virtualbox/.vagrant/machines/*/virtualbox/private_key  vagrant@10.1.2.11 $@
}
function sshc1 () {
    echo "  $@" >&2
    ssh -o StrictHostKeyChecking=no -i client/.vagrant/machines/*/virtualbox/private_key vagrant@10.1.2.21 $@
}


cat << EOF
   This runs the demos provided by IBM in https://github.com/IBM/StorageScaleVagrant/tree/main/setup/demo
      1 	Query f/s 	mmlsmount, mmlsfs, curl
      2 	Addding NSDs 	mmlspool, mmdf, add 2 NSDs, mmlspool, mmdf
      3 	Placement 	mmchpolicy (based on file extension), mmlsattr
      4 	(There is no script 4)
      5 	Users 	2groupadd, 8*adduser, 2*mmcrfileset, 6* mkdir, dd, 6*chown
      6 	snapshots 	mmcrfileset, mmcrfileset, mmlssnapshot, cat filess
      7 	(There is no script 6)
      8 	Openstack 	openstack user+credential create, project create, role add, but no file access ?
     80 	GUI for ACLs 	cli/mksuer, cli/chuser
     81 	Triggers 	2* mmcrfileset (limit 1024 files(, 850touch , 950touch
     99 	Quota limits with the cli 	mmcheckquota, cli/runtask QUOTA

     Note that these demos were expected to be run a single time. If re-run then many will error as directories already exist etc.
EOF



section "1.  Make a few changes to the scripts"
echo "** script-81   switch off excessive verosity"
# Harold has now done this change
#printf '%s\n' '/Create files to exceed warning threshold/a' 'set +x' . w q | ex -s StorageScaleVagrant/setup/demo/script-81.sh


exit

section "2.   Run the demo suite"
# should I delete these 2 public keys to make sure I get fresh ones?
sshm1 'sudo /vagrant/demo/script.sh VirtualBox'


section "All done"

