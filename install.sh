#!/bin/bash
#
# I really would have prefered to do this using Ansible playbooks
# but for now lats just script it in bash
#

#
#  1: Install the base O/S image - and include all prerequisites that Storage Scle will need.
#
time ./install_basebox.sh

#
# 2: Install Spectrum Scale itself
#    This include the demos
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

# consider here the possibility of disabling the IBM demos, or at least adding a substitue set of my own?

time ./install_scale.sh

# time ./install_restapi.sh

# future
# some clever restapi stuff etc

echo "*** All Done"
