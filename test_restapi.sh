#!/bin/bash
#
# Test the Storage Scale ResrAPI
# 
# Here we will use bash, but really I prefer python for RestAPI programming
#

auth="performance:monitor"
base="-s -k -u $auth https://127.0.0.1:4438/scalemgmt/v2"
s="%20"
#
# Pretty primt section titles
#
function section () {
   echo " "
   echo "***"
   echo "*** $@"
   echo "***"
}

section "1. List the filesytems"
curl ${base}/filesystems |jq .filesystems[].name

section "4.1 Perforamnce Monitoring"
#curl ${base}/perfmon/sensors | jq '.sensorConfig[] | "\(.sensorName)  \(.description)"' | head -2
curl ${base}/perfmon/sensors | jq '.sensorConfig[] | .sensorName + "...." + .description' | head -2

section "4.3 Query Perfmon for Free Memory over the last 5 hours"

#  check cluster health
#  tbc
# https://<gui>/scalemgmt/v2/nodes/all/health/events?filter=severity%21%3DINFO%2Ccomponent%3DFILESYSTEM'

#
# Get free memory over the last 300 samples for a bucketzie of 7200 seconds

#query= 'query':'metrics mem_memfree bucket_size '+  str(7200) +' last ' + str(60*5)} # last five hours

#curl ${base}/perfmon/data?query=metrics%20mem_memfree%20last%202%20bucket_size%207200
query="metrics mem_memfree last 2 bucket_size 7200"
metrics=$(echo $query |sed -e 's/ /%20/g') 
curl ${base}/perfmon/data?query=${metrics}



section "7. Create a new filesytem"
# note that were we need POST not GET


#section "10 List the vdisksets (GNR only)"
#curl ${base}/gnr/diskmgmt/vdiskset/server/list/all

