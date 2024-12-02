#!/bin/bash

# Recommended to run this in 'git bash' on Windows
# If run under powershell, I think there is a conflict between windows linux subsystem and opensssl ?


if test -d StorageScaleVagrant; then
   echo "change directory"
   cd StorageScaleVagrant
fi
echo "*** copying a download of Storage Scale Dedveloper edition"
#
# Really we should be getting this zipfile direct from IBM ?
#
# better to read which zip file is in the base directory?
VERSION="5.1.9.1"
VERSION="5.2.0.1"
# above probably lack mms3 ?
VERSION="5.2.1.1"
BASE="Storage_Scale_Developer-${VERSION}-x86_64-Linux"


# should check that this file exists!
#
echo "*** unpack the tarball if not yet done"
#ls -lrt software
if [ ! -f software/${BASE}-install ]; then
   (cd software && unzip -o ../../$BASE.zip|| exit 1)
fi

cd virtualbox 
echo "*** save a copy of the Vagrantfiel before I first make any changes"
if [ ! -f Vagrantfile.save ]; then
  cp Vagrantfile Vagrantfile.save
fi

echo "*** add a line to use version \$VERSION=$VERSION of Scale"
sed -i "/StorageScale_version =/a\$StorageScale_version = \"$VERSION\"" ../shared/Vagrantfile.common


echo "*** change port 8888 to 8443 to avoid clash with Jupyter Notebooks"
sed -i 's/host: 8888/host: 4438/' Vagrantfile
# or instead allow use the `auto_correct: true` option of config.vm.network ?

echo "*** disable running of the demos after installing Scale"
# We will do this later one by one
sed -i 's|/vagrant/demo/script.sh|#/vagrant/demo/script.sh|' Vagrantfile

echo "*** We need to enable the GUI user here (was much later in demo/script-80,sh)"
# so sed it into the end of install/script-05.sh (after sudo /usr/lpp/mmfs/gui/cli/initgui)
sed '/\/cli\/initgui/asudo /usr/lpp/mmfs/gui/cli/mkuser performance -p monitor -g monitor' setup/install/script-05.sh

# Now we need to patch the file to point to this version of Storage Scale
# StorageScaleVagrant/shared/Vagrantfile.common
# maybe I prefer to pass as an argument and have the above change only if it doesnet exist?

#echo "*** Hack : stop the regeneration of SSL Vagrant keys. They end up in the wrong file format"
# maybe this is only a problem if using Mobaxterm. Is it unneeded for Git Bash ?
#patch  -p1 -i ../vagrant.patch

#echo "*** we would prefer to cut down /vagrant/demo/script.sh to do just a basic install so as fast as possibke?"

echo "*** clean up step: destroy the VM if is already exists"
# but be careful if the vmdk files are still there as they might build up in VirtualBox ?
vagrant destroy -f
#if test -d disk; then
#    rm -rf disk
#fi
pwd

time vagrant up >>install.log
rc=$?
echo "*** all done"

if [ $rc -eq 0 ] cat <<EOF 
     now proceed with:
     - testing the GUI 
     - testing the RestAPI
     - testing teh S3 put/get Interface
     - running the provided demo.sh scripts (extra NSDs, etc.
EOF


