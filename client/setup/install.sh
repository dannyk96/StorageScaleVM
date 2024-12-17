#!/usr/bin/bash
# Exit script immediately, if one of the commands returns error code
#set -e


#
# Pretty print section titles
#
function section () {
   echo " "
   echo "==================================================================================================="
   echo -e "`date +\%H:%M:%S`  $@"
   echo "==================================================================================================="
}

#
# Customisable settings
#
#VERSION=5.2.1.1                  # would be nice to detect this automatically?
name="wilma"                      # the basename of both the cluster and this node
INSTALL_NODE="10.1.1.21"          # FIXME  cf storage cluster is 10.1.1.11

#-------  no user configurable options to go below this line -------

section " 1.Install some extra rpms, update /etc/hosts, turn off swap"


# some extra RPMS
sudo dnf -y install jq            # jq is great for testing out a restapi
sudo dnf -y install unzip         # to unpack the Scale tarball

#  not so sure wht we need this ?
# I suspect it fixes a missing /usr/local/bin from PATH ?

# I wonder if this needs to be done in a previous vagrant ssh  as otherwise /usr/local/bin is not available (to provide ansible-playbook)
cat <<EOF | sudo tee -a /etc/sudoers.d/spectrumscale
# Provisioned by Vagrant `date`

# Add Storage Scale executables
Defaults:root       secure_path = /sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin:/usr/lpp/mmfs/bin
Defaults:centos     secure_path = /sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin:/usr/lpp/mmfs/bin
Defaults:vagrant    secure_path = /sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin:/usr/lpp/mmfs/bin
EOF

#
# Create the entries for my hostanmes
#

#sudo bash -c 'cat <<EOF >>/etc/hosts
cat <<EOF  | sudo tee -a /etc/hosts

#### added by $0 via vagrant on `date`   ####
127.0.0.1  localhost.localdomain localhost

# management network
10.1.1.11  m1.example.com m1m
10.1.1.21  wilma01m.example.com wilma01m

# high bandwidth data network
10.1.2.11  m1.example.com m1
10.1.2.21  wilma01.example.com wilma01

# S3 interface (floating)
10.1.2.31  cesip.example.com cesip
#### end ####

EOF

# default is 2GB. we want all the real memory we can get!
#sudo swapoff /swapfile

# we might want to look at this file later
#clusterdef=/usr/lpp/mmfs/${VERSION}/ansible-toolkit/ansible/vars/scale_clusterdefinition.json


section " 2. Unpack the Storage Scale tarball"

section " 2.1: Autodetect the version of Scale and unzip and auto-unpack the tarball"

cd /tmp/setup

# I must check that this tarball exists and abort if it does not
#
# get the higherst numbered version :-)
#
TARBALL=$(ls Storage_Scale_Developer*.zip|tail -1)
echo "ls -l $TARBALL"
if [ ! -f $TARBALL ]; then 
   echo "*** Tarball $TARBALL does not exist. Aborting!"
   exit 1
fi
export VERSION=`echo $TARBALL |cut -d'-' -f2`
INSTALL="./Storage_Scale_Developer-${VERSION}-x86_64-Linux-install"
if [ ! -f $INSTALL ]; then 
  unzip  $TARBALL
  rm $TARBALL    # to save disk space
fi 

SS="/usr/lpp/mmfs/$VERSION/ansible-toolkit/spectrumscale"

section "3. Unpack the tarball (only if $SS does not yet existi)"

# if the unpack was successfull we will delete the large install executable
if [ ! -f $SS ]; then
   if sudo bash ./Storage_Scale_Developer-${VERSION}-x86_64-Linux-install  --silent >>tarball_unpack.log;then
     sudo rm -f ./Storage_Scale_Developer-${VERSION}-x86_64-Linux-install
   fi 
fi 

section " 4. Configure the Storage Scale installer"


sudo $SS setup -s $INSTALL_NODE --storesecret

# note storage cluster  is already defined as 'demo' with node 'm1'
sudo $SS config gpfs -c ${name}_site.example.com        

sudo $SS callhome disable       # disable to avoid supurious warnings

# note one day I might want  -g - with gui to show client activity?
#  -g == --gui, -n == --nsd,  
#  -a == --admin,  -q== --quorum, -m == --manager
sudo $SS node add --gui --admin --quorum --manager  ${name}01.example.com     # a=admin, q=quorum, m=manager


echo "---> PATH=$PATH"
echo "current user is `id`"
sudo $SS node list
 
section " 6: Run the Installer (can take quite a while)\nlogs to install_scale.log"

#
# I think we are already root, but sudo picks up /usr/local/bin ?
time sudo $SS install -f |tee install_scale.log

# if the GUI has been installed we need this
sudo /usr/lpp/mmfs/gui/cli/mkuser performance -g Monitor -p monitor
#
#
#
# Now lets fire up Storage Scale !
#
# default sems to be to start automatically?
# sudo /usr/lpp/mmfs/bin/mmstartup

# add scale binaries to the default path for everybody
sudo echo "export PATH=\$PATH:/usr/lpp/mmfs/bin" > /etc/profile.d/spectrumscale.sh
# add /usr/local/bin to the default path for everybody (really ansible-playbook is key)
sudo echo "export PATH=\$PATH:/usr/local/bin" > /etc/profile.d/usr_local_bin.sh

# belt and braces
PATH=$PATH:/usr/local/bin

# no need to deploy if we are only a client cluster as no disks, no CES etc.
#time $SS deploy

#echo "check if the Ansible succeeded in unpack the RPMS"
#if [ -f /usr/lpp/mmfs/bin/mmstartup ]; then
#  echo "*** Storage Scale binaries not found! exiting"
#fi

section  "7: start this one node cluster and do a few checks"

export PATH=$PATH:/usr/lpp/mmfs/bin
mmlscluster
# I don't thinkl we need to do the next?
#sudo mmchlicense server --accept -N `hostname`    # or  ${name}01
uptime

# TODO:
#  the mmauth exchange but and hence mmmount the remote /gpfs/fs1
#mmauth add

ping -c2 m1

section "All Complete"

