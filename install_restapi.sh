#!/bin/bash

# install_restapi.sh
git clone git@github.com:dannyk96/SpectrumScaleRestAPI.git


# Also from powershell
# 'C:\Program Files\Git\mingw64\bin/curl' --insecure -u "admin:admin001" https://127.0.0.1:8888/scalemgmt/v2/filesystems

# From mobaxterm (/vib/curl appears broken)
# /drives/c/Program\ Files/Git/mingw64/bin/curl --insecure -u "admin:admin001" https://127.0.0.1:8888/scalemgmt/v2/filesystems
# In git Bash
# -s = no [progress bar
# -k dont check host SSL certificate
# -u this is teh defauult admin user - I prefer -u performance:monitor

 curl -s -k -u admin:admin001 https://127.0.0.1:8888/scalemgmt/v2/filesystems

# and drill down
 `curl -sku admin:admin001 https://127.0.0.1:8888/scalemgmt/v2/filesystems/fs1 |jq " .filesystems[].replication"`
{
  "defaultDataReplicas": 1,
  "defaultMetadataReplicas": 1,
  "logReplicas": 0,
  "maxDataReplicas": 2,
  "maxMetadataReplicas": 2,
  "strictReplication": "whenpossible"
}


# From Powershell
$user="admin"
$pass="admin001"
$pair = "$($user):$($pass)"
$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
$basicAuthValue = "Basic $encodedCreds"
$Headers = @{ Authorization = $basicAuthValue}

Invoke-WebRequest  -URI  https://127.0.0.1:8888/scalemgmt/v2/filesystems -Headers $Headers

Invoke-WebRequest -SkipCertificateCheck  -URI  https://127.0.0.1:8888/scalemgmt/v2/filesystems -Headers $Headers
# after first encoding the username and password via 
#   

# compare with:  https://stackoverflow.com/questions/59924142/powershell-iwr-fails-when-attempting-skipcertificatecheck
add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
            return true;
        }
 }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
# 
# 
