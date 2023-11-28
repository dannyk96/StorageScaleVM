#!/bin/bash

# Recommended to run this in 'git bash' on Windows
# If run under powershell, I think there is a conflict between windows linux subsystem and opensssl ?

if test -d StorageScaleVagrant; then
   cd StorageScaleVagrant
fi
echo "*** copying a download of Storage Scale Dedveloper edition"
#
# Really we should be getting this zipfile direct from IBM ?
#
(cd software && unzip -o ~/Downloads/Storage_Scale_Developer-5.1.8.2-x86_64-Linux.zip)

echo "*** Hack : stop the regeneration of SSL Vagrant keys. They end up in the wrong file format"
patch  -p1 -i ../vagrant.patch

# clean up step 
# but be careful if the vmdk files are still there as they might muild up in VirtualBox ?
if test -d disk; then
    rm -rf disk
fi

time vagrant up
