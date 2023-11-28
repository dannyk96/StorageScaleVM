#!/bin/bash
#
# I really would have prefered to do this using Ansible playbooks
# but for now lats just script it in bash
#
mkdir dan && cd dan
echo "Checkout the latest copy of StorwageScaleVagrant"
#  use https or ssh ?
git clone https://github.com/IBM/StorageScaleVagrant.git
cd StorageScaleVagrant

echo "copying it a download of Storage Scale Dedveloper edition"
#
# Really we should be getting thius direct from IBM ?
#
pushd software && unzip ~/Downloads/Storage_Scale_Developer-5.1.8.2-x86_64-Linux.zip

patch  -p1 -i ../vagrantfile8.patch
