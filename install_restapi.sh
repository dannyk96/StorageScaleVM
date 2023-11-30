#!/bin/bash

# install_restapi.sh
git clone git@github.com:dannyk96/SpectrumScaleRestAPI.git


# Also from powershell
# 'C:\Program Files\Git\mingw64\bin/curl' --insecure -u "admin:admin001" https://127.0.0.1:8888/scalemgmt/v2/filesystems

# From mobaxterm (/vib/curl appears broken)
# /drives/c/Program\ Files/Git/mingw64/bin/curl --insecure -u "admin:admin001" https://127.0.0.1:8888/scalemgmt/v2/filesystems

# From Powershell
# Invoke-WebRequest -SkipCertificateCheck  -URI  https://127.0.0.1:8888/scalemgmt/v2/filesystems -Headers $Headers
# after first encoding the username and password via 
#   $encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
# $basicAuthValue = "Basic $encodedCreds"
# $Headers = @{ Authorization = $basicAuthValue
