#!/bin/bash
#
#   Configure the S3 Interface : both client and server sides
# for debug
#set +x
#set -e

#
# Pretty print section titles
#
function section () {
   echo " "
   echo "==================================================================================================="
   echo -e "`date +\%H:%M:%S`  $@"
   echo "==================================================================================================="
}
# 
# Set up shortcuts to ssh's (as user vagrant
#
function sshm1 () {
    echo "  $@" >&2
    ssh -t -o StrictHostKeyChecking=no  -i StorageScaleVagrant/virtualbox/.vagrant/machines/*/virtualbox/private_key  vagrant@10.1.2.11 $@
}
function sshc1 () {
    echo "  $@" >&2
    ssh -t -o StrictHostKeyChecking=no -i client/.vagrant/machines/*/virtualbox/private_key vagrant@10.1.2.21 $@
}

cat << EOF
This Scripts Set up the S3 API on both sides and tests:

  1. On the server ceate SSL certificates and start the CES S3 service
  2. On the server create a user account with mms3
  3. Downlaod and Install the 'aws' client on c1
  4. create ~/aws_cert file on the client
  5. get the host certificate: tls.cert from the server and put in /home/vagrant/aws-cert/
  6. Now need to get the two hashes from the last line of s3_access_Keys.txt to node c1
  7. Create a bucket and upload a file

EOF



section "1. On the server ceate SSL certificates and start the CES S3 service"


sshm1 "cat |tee  /tmp/san.cnf" <<< $(cat <<EOF
[req]
req_extensions = req_ext
distinguished_name = req_distinguished_name

[req_distinguished_name]
CN = localhost

[req_ext]
subjectAltName = DNS:localhost,DNS:cesip.example.com
EOF
)

echo " "

sshm1 <<< $(cat <<EOF
ls -ld /tmp/san.cnf;
sudo rm -f /tmp/tls.{key,csr,crt};
sudo openssl genpkey -algorithm RSA -out /tmp/tls.key;
sudo openssl req -new -key /tmp/tls.key -out /tmp/tls.csr -config /tmp/san.cnf -subj "/CN=localhost";
sudo openssl x509 -req -days 365 -in /tmp/tls.csr -signkey /tmp/tls.key -out /tmp/tls.crt -extfile /tmp/san.cnf -extensions req_ext;
sudo mkdir -p /ibm/cesShared/ces/s3-config/certificates;
sudo cp /tmp/{tls.key,tls.crt} /ibm/cesShared/ces/s3-config/certificates/;
EOF
)

echo "==> change CES IP from 192.168.56.101 to 10.1.2.31"
sshm1 sudo mmces address add --ces-node m1 --ces-ip 10.1.2.31

echo "==> Now restart CES to pick up the new certificates"
sshm1 sudo mmces service stop s3;
sshm1 sudo mmces service start s3;
sleep 10 
sshm1 "sudo mmces state show s3"


section "2. On the server create a user account with mms3 "

#echo "caveat: by creating the account with uid/gid 1000 will make the files owned by user 'vagrant'"
# note that we do not need to create /home/eric
sshm1 sudo groupadd -g 1010 s3_users 
sshm1 sudo useradd  -g 1010 -u 1010 -c 'S3_user' eric
sshm1 sudo mms3 account create eric --gid 1010 --uid 1010 --newBucketsPath /ibm/fs1/erics_buckets 

echo "==> Show that a bucket directory has been created with the correct uid/gid"
sshm1  ls -ld /ibm/fs1/erics_buckets/

section "3. Download and Install the 'aws' client on c1"

sshc1 <<< $(cat <<EOF
# only do this is /usr/local/bin/aws does not exist
if /usr/local/bin/aws --version; then
   echo "/usr/local/bin/aws already exisis, skipping re-install"
else
   echo "==> installing AWS CLI v2"
   cd /tmp
   sudo curl -s https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip
   #dnf -y install unzip
   sudo unzip -o awscliv2.zip 2>&1 >/dev/null 
   # cdaws
   sudo /tmp/aws/install --update
   /usr/local/bin/aws --version
fi
EOF
)

section "4. Create ~/aws_cert file on the client"

# I am not sure I understand what this is used for?
# If I delete aws-cert/san.cnf then it all stil works
# ie I think all we need is the .pem public certificate
sshc1 mkdir -p aws-cert
sshc1 "cat > aws-cert/san.cnf" <<< $(cat <<EOF
[req]
req_extensions = req_ext
distinguished_name = req_distinguished_name
[req_distinguished_name]
CN = localhost
[req_ext]
# The subjectAltName line directly specifies the domain names and IP addresses that the certificate should be valid for.
# This ensures the SSL certificate matches the domain or IP used in your S3 command.
# Example:
# 'DNS:localhost' makes the certificate valid when accessing S3 storage via 'localhost'.
# 'DNS:cess3-domain-name-example.com' adds a specific domain to the certificate. Replace 'cess3- domain-name-example.com' with your actual domain.
# 'IP:<nsfs-server-ip>' includes an IP address. Replace '<nsfs-server-ip>' with the actual IP address of your S3 server.
subjectAltName = DNS:localhost,DNS:cesip.example.com
EOF
)



section "5. Get the host certificate: cesip-example.com.pem from the server and put in /home/vagrant/aws-cert/"

# I can also get this certifcate from a curl to https://10.2.1.31:6443
#
# compare with doing this from anywhere:
#
# #echo "Q" | openssl  s_client -showcerts -servername 10.1.2.31 -connect 10.1.2.31:6443|openssl x509

#sshc1 "cat |tee aws-cert/tls.crt" <<<\
#	$(ssh m1 sudo cat /ibm/cesShared/ces/s3-config/certificates/tls.crt)
# note that the location isn't special. we have a shell variable $AWS_CA_BUNDLE that poitns to it
sshc1 "cat |tee aws-cert/cesip-example-com.pem" <<<\
	$(ssh m1 sudo cat /ibm/cesShared/ces/s3-config/certificates/tls.crt)



section "6. Now need to get the two hashes from the last line of s3_access_Keys.txt to node c1 "

# is there a timeout on the next or could it hang if mmces returns an error?
read -r name bucketpath uid gid AWS_ACCESS_KEY AWS_SECRET_KEY  <<< $(ssh m1 sudo mms3 account list eric |tail -1)
echo " "
echo "$bucketpath for user ${name}(uid=${uid},gid=${gid}) has keys  $AWS_ACCESS_KEY and $AWS_SECRET_KEY"
echo " "

# I think the aws_ca_bundle isn't working : I still need the envvar
sshc1 aws configure set aws_access_key_id     $AWS_ACCESS_KEY        --profile eric
sshc1 aws configure set aws_secret_access_key $AWS_SECRET_KEY        --profile eric
sshc1 aws configure set aws_ca_bundle /home/vagrant/aws-cert/cesip-example-com.pem  --profile eric
sshc1 aws configure set endpoint_url https://cesip.example.com:6443  --profile eric

section "7. Create a bucket and upload a file"

echo "==> create a alias on ~/.bashrc"
sshc1 <<< $(cat <<EOF
echo 'alias S3="aws --profile eric --endpoint https://cesip.example.com:6443 s3"' >> ~/.bashrc
EOF
)

echo "==> create from the client"
sshc1  <<< $(cat <<EOF
export AWS_CA_BUNDLE=/home/vagrant/aws-cert/cesip-example-com.pem
aws --profile eric s3 mb s3://bremmen60 
aws --profile eric s3 ls
date
aws --profile eric s3 cp /etc/hosts s3://bremen/etc_hosts_$(date +%H_%M_%S)
aws --profile eric s3 ls s3://bremen --human-readable --color on --summarize
EOF
)

echo "==> and compare on the server"
sshm1 sudo ls -lrt /ibm/fs1/erics_buckets/bremen

section "All done"

