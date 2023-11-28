#!/bin/bash

# Recommended to run this in 'git bash' on Windows
# If run under powershell, I think there is a conflict between windows linux subsystem and opensssl ?

if test -d StorageScaleVagrant; then
   echo "change directory"
   cd StorageScaleVagrant
fi
cd StorageScaleVagrant
echo "*** copying a download of Storage Scale Dedveloper edition"
#
# Really we should be getting this zipfile direct from IBM ?
#
$BASE="Storage_Scale_Developer-5.1.8.2-x86_64-Linux"
if !test -f software/$(BASE)-Linux-install; then
   (cd software && unzip -o ~/Downloads/$BASE.zip)
fi

echo "*** Hack : stop the regeneration of SSL Vagrant keys. They end up in the wrong file format"
patch  -p1 -i ../vagrant.patch

cd virtualbox

# clean up step 
# but be careful if the vmdk files are still there as they might muild up in VirtualBox ?
vagrant destroy
if test -d disk; then
    rm -rf disk
fi
pwd
time vagrant up
