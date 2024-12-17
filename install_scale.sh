#!/bin/bash
#set -x # uncomment for debug

# Recommended to run this in 'git bash' on Windows
# If run under Mobaxterm or powershell, I think there is a conflict between windows linux subsystem and opensssl ?

#
# Pretty print section titles
#
function section () {
   echo " "
   echo "==================================================================================================="
   echo -e "`date +\%H:%M:%S`  $@"
   echo "==================================================================================================="
}

section "1 Download the Vagrant scripts from  https://github.com/IBM/StorageScaleVagrant.git"
# Have the Vagrant scripts been downlaoded yet?
# node option of a 'git pull' too to get the latest changes
if [ ! -d StorageScaleVagrant ]; then
  git clone https://github.com/IBM/StorageScaleVagrant.git
fi
cd StorageScaleVagrant



section "2 Download a copy of Storage Scale Dedveloper edition"
#
# Really we should be getting this zipfile direct from IBM ?
#
# better to read which zip file is in the base directory?
# above probably lack mms3 ?
VERSION="5.2.2.0"
BASE="Storage_Scale_Developer-${VERSION}-x86_64-Linux"


# should check that this file exists!
#
#

section " unpack the tarball if not yet done"

if [ ! -f software/${BASE}-install ]; then
   (cd software && unzip -o ../../$BASE.zip|| exit 1)
fi

cd virtualbox 
echo "*** save a copy of the Vagrantfile before I first make any changes"
if [ ! -f Vagrantfile.save ]; then
  cp Vagrantfile Vagrantfile.save
fi

section "5. Customise this Vagrantfile"

#echo "*** add a line to use version \$VERSION=$VERSION of Scale"
#sed -i.bak "/StorageScale_version =/a\$StorageScale_version = \"$VERSION\"" ../shared/Vagrantfile.common
# only need to do this if a newer versio nof Scale has come out (>5,2,1,1)
#printf '%s\n' /StorageScale_version/a "\$StorageScale_version = \"$VERSION\"" . w q |ex -s ../shared/Vagrantfile.common


#echo "*** change port 8888 to 4438 to avoid clash with Jupyter Notebooks"
#echo "otherwise smply connect to https://10.1.2.11:47433/"
#sed -i.bak 's/host: 8888/host: 4438/' Vagrantfile
# or instead allow use the `auto_correct: true` option of config.vm.network ?


echo "===> disable running of the demos after installing Scale"
# We will do this later one by one
sed -i.bak 's|/vagrant/demo/script.sh|#/vagrant/demo/script.sh|' Vagrantfile


#echo "*** We need to enable the GUI user here (was much later in demo/script-80,sh)"
# so sed it into the end of install/script-05.sh (after sudo /usr/lpp/mmfs/gui/cli/initgui)
#sed -i.bak -e '/initgui/ a\' -e 'sudo /usr/lpp/mmfs/gui/cli/mkuser performance -p monitor -g monitor' StorageScaleVagrant/setup/install/script-05.sh
# Harold has now added this to demo/script-01.sh but this imho is too late - should be in the setup/ section
#printf '%s\n' /initgui/a 'sudo /usr/lpp/mmfs/gui/cli/mkuser performance -g Monitor -p monitor' . w q |ex -s ../setup/install/script-05.sh


#echo "*** redict the output of './spectrumscale install' to a file (as bloats STDOUT here)"
#sed -i.bak -e '/spectrumscale install/ s/$/ > install.log/' StorageScaleVagrant/setup/install/script-05.sh
#printf '%s\n' '/spectrumscale install/' 's/$/ |tee install.log' . w q | ex -s ../setup/install/script-05.sh

#exit

# Now we need to patch the file to point to this version of Storage Scale
# StorageScaleVagrant/shared/Vagrantfile.common
# maybe I prefer to pass as an argument and have the above change only if it doesnet exist?

#echo "*** Hack : stop the regeneration of SSL Vagrant keys. They end up in the wrong file format"
# maybe this is only a problem if using Mobaxterm. Is it unneeded for Git Bash ?
#patch  -p1 -i ../vagrant.patch

#echo "*** we would prefer to cut down /vagrant/demo/script.sh to do just a basic install so as fast as possibke?"

section "6 Clean up step: destroy the VM if is already exists"
# but be careful if the vmdk files are still there as they might build up in VirtualBox ?
vagrant destroy -f
#if test -d disk; then
#    rm -rf disk
#fi
#pwd

section "7 Run vagrant (and hence the Spectrum Scale installer"
# I would prefer to do the dirction just of the ./spectrumscale install
time vagrant up
rc=$?
if [ $? -ne 0]; exit


section "8 Confirm that a Scale cluster has been created"

ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i .vagrant/machines/*/virtualbox/private_key vagrant@10.1.2.11 mmlscluster

if [ $rc == 0 ]; then
cat <<EOF 
     now proceed with:
     - testing the GUI 
     - testing the RestAPI
     - testing the S3 put/get Interface
     - testing CES NFS exports
     - testing Multicluster GPFs mounts
     - running the provided demo.sh scripts (extra NSDs, etc.
EOF
fi


