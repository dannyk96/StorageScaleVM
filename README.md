StorageScaleVM
==============
My work based on enhancing and fixing issues with https://github.com/IBM/StorageScaleVagrant/

This uses a freely downloadable version of IBM Storage Scale
You can donwload a copy (after filling in a short form) from https://www.ibm.com/account/reg/us-en/signup?formid=urx-41728

Objectives
----------

These are some of the key objectives
    
   1 Automate the install of Storage ScaleVagrant including the: git download, basbox build, and build of the Storage Scale server
   Also I want to skip the automated running of the built-in demos so I can either:
   
         x Run each one on demand, possibly menu driven (Curses anyone?)
         x Run my own demos customised for the client's interests
   
   2 Speed up the deployment time to be able to demonstate features as soon as possible by:
   
         x Have a reliable Basebox stored bentrally that I can build both servers and clients from.
         x Avoid repeating slow steps such as `spectrumscale {install, deploy} eg ny detecting that they have already been run
         x Enable to GUI as soon as it is deployed
         x (todo) create a Boxfile of the server VM so can spin up say the S3 demo very quickly. Also consider the use of VirtualBox snapshots here?
   
   3 Try and minimise any modifcation of `StorageScaleVagrant`. This is beause I don't want to risk incompatability as new drops of this come out every few months.  Currently the main think I change is to disable the automated running of the built-in demos.
   
   4 Be able to demonstate as many data access protocols as possible. Also remote management
     so far we have:
     
     x POSIX using native GPFS via Mulicluster
     x S3  using the AWS toolkiy and he new Nooba based S3 sever in Storage Scale CES
     x NFS : as standard client server
     x (Todo) HDFS  - although this may be difficult client side
     x https RestAPI for management
     x (Todo) New role based access to the 'mm' commands

How to Use this repository
--------------------------

The only prerequisites are freely downloadable copies of

    - VirtualBox
    - Vagrant
    - Spectrum Scale Developer edition tarball

Firstly create the basbox which contains a copy of Centos/8 with added to the RPMs that Storage Scale depends on. We also install some nice to have RPMs like `unzip` and `jq`
```
./install_basebox.sh
```
Then we can install in either order the server
```
./install_scale.sh
```
and the client
```
./install_client.sh
```
Then the followign can be run in any order:
```
./setup_multicluster.sh

./setup_mms3.sh

./setup_nfs.sh
'''

Additional demos
----------------

'''
 ./run_demos.sh
'''
    
     

Some usefull Gems for Vagrant and VirtualBox enviroments.
---------------------------------------------------------

`Vagrant ssh` is  quite slow as it loads a lot of stuff. It is better and far quicker to run ssh directly. 
But to do this we need to remember where we stored the ssh keys for passwordless login. 
Also as the VM can get re-installed regularly we don't want erroneous security warnings about the host's SSL keys having changing 

This is a great gem - much faster that `vagrant ssh`
```
alias fastssh="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i .vagrant/machines/*/virtualbox/private_key -p 2200 vagrant@127.0.0.1"
```
Actually the methid I prfer much more than this is to populate ~/.ssh/config on my laptop (Git Bash or Mobaxterm).
Here we will ssh direct to the VM's IP address rather than a forwardd port like 20222 on `localhost`


