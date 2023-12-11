#!/bin/bash

# Recommended to run this in 'git bash' on Windows
# If run under powershell, I think there is a conflict between windows linux subsystem and opensssl ?


# note the demos that get run for the IBM scripts:
#
# Demos
# =====
#  1   Query f/s     : mmlsmount, mmlsfs, curl
#  2   Addding NSDs  : mmlspool,mmdf, add 2 NSDs, mmlspool,mmdf
#  3   Placement     : mmchpolicy (based on file extension), mmlsattr
#  4                   (There is no script 4)
#  5   Users         : 2*groupadd, 8*adduser, 2*mmcrfileset, 6* mkdir, dd, 6*chown
#  6   snapshots:      mmcrfileset, mmcrfileset, mmlssnapshot, cat filess
#  7                   (There is no script 6)
#  8   Openstack     : openstack user+credential create, project create, role add, but no file access ?
# 80   GUI for ACLs  : cli/mksuer, cli/chuser
# 81   Triggers      : 2* mmcrfileset (limit 1024 files(, 850*touch , 950*touch
# 99   Quota limits with the cli : mmcheckquota, cli/runtask QUOTA



if test -d StorageScaleVagrant; then
   echo "change directory"
   cd StorageScaleVagrant
fi
#cd StorageScaleVagrant
echo "*** copying a download of Storage Scale Dedveloper edition"
#
# Really we should be getting this zipfile direct from IBM ?
#
BASE="Storage_Scale_Developer-5.1.9.1-x86_64-Linux"
ls -lrt software
if [ ! -f software/${BASE}-install ]; then
   (cd software && unzip -o ~/Downloads/$BASE.zip)
fi

echo "*** Hack : stop the regeneration of SSL Vagrant keys. They end up in the wrong file format"
patch  -p1 -i ../vagrant.patch

cd virtualbox

# clean up step 
# but be careful if the vmdk files are still there as they might muild up in VirtualBox ?
vagrant destroy -f
if test -d disk; then
    rm -rf disk
fi
pwd
time vagrant up
