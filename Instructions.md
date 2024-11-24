Recipe to install the Storage Scale VM on a laptop using VirtualBox
===================================================================

Note to self: I really would have prefered to do this using Ansible playbooks?
but for now lets just script it in bash


## Part 1 : Install the Base O/S Image

Install the base O/S image - and include all prerequisites that Storage Scle will need.

```
time ./install_basebox.sh
```

## Part 2 : Install Spectrum Scale itself

```
# Recommended to run this in 'git bash' on Windows
# If run under powershell, I think there is a conflict between windows linux subsystem and opensssl ?

# Setup Scripts
# =============
#  1 Just check the Scale self extrating tarball exists
#  2 Abort if /usr/lpp/mmfs already exists
#    Extract Scale rpms from the tarball
#  3 initialise `spectrumscale` toolkit
#  4 define 5 NSDs
#  5 `spectrumscale install`
#    show what we created: mmlscluster, mmgetstate, mmhealth node show, mmlsnsd
#
#    show daemons with sytemctl status: gpfsgui, pmcollector
#    Init the Gui
#  6 `spectrumscale deploy` to create /ibm/fs1, enable quota calcs, mmlsfs, mmdf
#  7 tune mmperfmon
#    hide 2 mmhealth/gui warnings: callhome, unexpected o/s
#  8 enable CES (using cesShared). we re-run `sss deploy` which takes ages as it des the whole playbook again!
#    (so can save time if we switch this off)
```

```
time ./install_scale.sh
```

## Part 4 : Run the provided Demos

I think that I would like to run these indivually so that there is time to show and talk about each bklock of output


Demos
=====
|     Demo Number | Subject | Description |
|-----|---------------|-------------------|
|  1  | Query f/s     | mmlsmount, mmlsfs, curl |
|  2  | Addding NSDs  | mmlspool,mmdf, add 2 NSDs, mmlspool,mmdf |
|  3  | Placement     | mmchpolicy (based on file extension), mmlsattr |
|  4  |               |  (There is no script 4) |
|  5  | Users         | 2*groupadd, 8*adduser, 2*mmcrfileset, 6* mkdir, dd, 6*chown |
|  6  | snapshots    |  mmcrfileset, mmcrfileset, mmlssnapshot, cat filess |
|  7  |               |  (There is no script 6) |
|  8  | Openstack     | openstack user+credential create, project create, role add, but no file access ? |
| 80  | GUI for ACLs  | cli/mksuer, cli/chuser |
| 81  | Triggers      | 2* mmcrfileset (limit 1024 files(, 850*touch , 950*touch |
| 99  | Quota limits with the cli | mmcheckquota, cli/runtask QUOTA |

# consider here the possibility of disabling the IBM demos, or at least adding a substitue set of my own?
