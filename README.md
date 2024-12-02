# StorageScaleVM
My work based on enhancing and fixing issues with https://github.com/IBM/StorageScaleVagrant/

This uses a freely downloadable version of IBM Storage Scale
You can donwload a copy (after filling in a short form) from https://www.ibm.com/account/reg/us-en/signup?formid=urx-41728


This is a great gem - much faster that `vagrant ssh`
```
alias fastssh="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i .vagrant/machines/*/virtualbox/private_key -p 2200 vagrant@127.0.0.1"
```

then jsut type `fastssh`

