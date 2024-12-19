#!/bin/bash
#
# Test the Storage Scale ResrAPI
# 
# Here we will use bash, but really I prefer python for RestAPI programming
#

auth="performance:monitor"
base="-s -k -u $auth https://10.1.2.11:47443/scalemgmt/v2"
s="%20"
#
# Pretty primt section titles
#
function section () {
   echo " "
   echo "==================================================================================================="
   echo -e "`date +\%H:%M:%S`  $@"
   echo "==================================================================================================="
}

section "00 Get the API Token (so dont need username/password with Curl"

curl ${base}/rest/auth

section "1. List the filesytems"

echo "===> First raw json output"
curl ${base}/filesystems 

echo -e  "\n===> now filter the output to get a list of filesystems"
filesystems=$(curl ${base}/filesystems |jq -r -c  .filesystems[].name | sed 's/\n/z/g')
#filesystems=$(curl ${base}/filesystems |jq -r  .filesystems[].name)
echo "The filesystems found are:" $filesystems

echo -e "\n===> Now get details of each filesystem"
for fs in $filesystems
do
    #echo "fs = $fs  foo"
    output=$(curl ${base}/filesystems/${fs})
    #echo $output |jq
    createTime=$(echo $output |jq -r .filesystems[0].createTime)
    mountPoint=$(echo $output |jq -r .filesystems[0].mount.mountPoint)
    printf "%-10s %-22s %12s %12s \n" $fs $mountPoint $createTime
done


section "2. List the restAPi endpoints"

echo "===> All endpoints"
curl ${base}/info | grep -i date
exit

echo "===> List just the filesytem endpoints"
curl ${base}/info | grep "filesystems\/" |head


section "3. Where to find doumentation"

curl https://10.1.2.11/ibm/api/explorer  head -12

section "4.1 Perforamnce Monitoring"
#curl ${base}/perfmon/sensors | jq '.sensorConfig[] | "\(.sensorName)  \(.description)"' | head -2
curl ${base}/perfmon/sensors | jq '.sensorConfig[] | .sensorName + "...." + .description' | head -2

section "4.3 Query Perfmon for Free Memory over the last 5 hours"
curl ${base}/filesystem.fs1


#  check cluster health
#  tbc
# https://<gui>/scalemgmt/v2/nodes/all/health/events?filter=severity%21%3DINFO%2Ccomponent%3DFILESYSTEM'

#
# Get free memory over the last 300 samples for a bucketzie of 7200 seconds

#query= 'query':'metrics mem_memfree bucket_size '+  str(7200) +' last ' + str(60*5)} # last five hours

#curl ${base}/perfmon/data?query=metrics%20mem_memfree%20last%202%20bucket_size%207200
query="metrics mem_memfree last 2 bucket_size 7200"
metrics=$(echo $query |sed -e 's/ /%20/g') 
curl ${base}/perfmon/data?query=${metrics}| head -12



section "7. Create a new filesytem"
# note that were we need POST not GET


#section "10 List the vdisksets (GNR only)"
#curl ${base}/gnr/diskmgmt/vdiskset/server/list/all

