## Test Restapi interface

curl -sk -u admin:admin001 https://127.0.0.1:8888/scalemgmt/v2/filesystems/fs1 |jq " .filesystems[].replication"

{
  "defaultDataReplicas": 1,
  "defaultMetadataReplicas": 1,
  "logReplicas": 0,
  "maxDataReplicas": 2,
  "maxMetadataReplicas": 2,
  "strictReplication": "whenpossible"
}

