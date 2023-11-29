#!/bin/bash
#
# I really would have prefered to do this using Ansible playbooks
# but for now lats just script it in bash
#


time ./install_basebox.sh

time ./install_scale.sh

# future
# some clever restapi stuff etc

echo "*** All Done"
