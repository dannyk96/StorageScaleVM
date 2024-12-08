#!/usr/bin/bash
# Exit script immediately, if one of the commands returns error code
#set -e


LINE="========================================================================================="

#
# Customisable settings
#
#VERSION=5.2.1.1                   # would be nice to detect this automatically?
name="wilma"                      # the basename of both the cluster and this node
INSTALL_NODE="10.1.1.21"          # FIXME  cf storage cluster is 10.1.1.11

#-------  no user configurable options to go below this line -------

echo $LINE
echo "Install some extra rpms, update /etc/hosts, turn off swap"
echo $LINE


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
#### end ####

EOF

# default is 2GB. we want all the real memory we can get!
sudo swapoff /swapfile

# we might want to look at this file later
clusterdef=/usr/lpp/mmfs/${VERSION}/ansible-toolkit/ansible/vars/scale_clusterdefinition.json


echo $LINE
echo "*** Unpack the Storage Scale tarball"
echo $LINE

echo $LINE
echo "Autodetect the version of Scale and unzip and auto-unpack the tarball"
echo $LINE

cd /tmp/setup

# I must check that this tarball exists and abort if it does not
#
TARBALL=`ls Storage_Scale_Developer*.zip`
echo "ls -l $TARBALL"
if [ ! -f $TARBALL ]; then 
   echo "*** Tarball $TARBALL does not exist. Aborting!"
   exit 1
fi
export VERSION=`echo $TARBALL |cut -d'-' -f2`
INSTALL="./Storage_Scale_Developer-${VERSION}-x86_64-Linux-install"
if [ ! -f $INSTALL ]; then 
  unzip  $TARBALL
fi 

SS="/usr/lpp/mmfs/$VERSION/ansible-toolkit/spectrumscale"
echo "unpack the tarball only if $SS does not yet exist"
if [ ! -f $SS ]; then
   sudo bash ./Storage_Scale_Developer-${VERSION}-x86_64-Linux-install  --silent >>tarball_unpack.log
fi 

echo $LINE
echo " Configure the Storage Scale installer then run it"
echo $LINE


echo "===> Setup management node (m1) as Storage Scale Install Node"
sudo $SS setup -s $INSTALL_NODE --storesecret

# note storage cluster  is already defined as 'demo' with node 'm1'
sudo $SS config gpfs -c ${name}_site.example.com        

sudo $SS callhome disable       # disable to avoid supurious warnings

# note one day I might want  -g - with gui to show client activity?
#  -g == --gui, -n == --nsd,  
#  -a == --admin,  -q== --quorum, -m == --manager
sudo $SS node add --gui --admin --quorum --manager  ${name}01.example.com     # a=admin, q=quorum, m=manager


echo "*** PATH=$PATH"
echo "current user is `id`"
sudo $SS node list
# I think we are already root, but sudo picks up /usr/local/bin ?
time sudo $SS install -f > install_scale.log

echo "check if the Installer succeeded in unpack the RPMS"
if [-f /usr/lpp/mmfs/bin/mmstartup]; then
  echo "*** Storage Scale binaries not found! exiting"
fi
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

echo $LINE
echo "start this one node cluster and do a few checks"
echo $LINE
export PATH=$PATH:/usr/lpp/mmfs/bin
sudo mmchlicense server --accept -N `hostname`    # or  ${name}01
mmlscluster
uptime

# TODO:
#  the mmauth exchange but and hence mmmount the remote /gpfs/fs1
#mmauth add

echo $LINE
echo "remote mount fronm the storage cluster vm"
echo $LINE
ping -c2 m1

cat <<EOF
1: cat /var/mmfs/ssl/id_rsa.pub and sent to m1 as  wilma_id_rsa.pub
1: cat /var/mmfs/ssl/id_rsa.pub and sent to wilma as  m1_id_rsa.pub
#
#   mmremotecluster add demo.example.com -k m1_id_rsa.pub -n m1
#
# then on the storage cluster
#
2: mmauth grant wilma_site.example.com -f fs1
   mmremotefs add fs1 -f fs1 -C demo.example.com -T /gpfs/fs1 -A yes
   mmmount fs1
EOF
