import requests
#import json
#import sys

server = 'https://127.0.0.1:47443/'
ss_auth=('admin','admin001')
#from auth_gren import *      # REST API username

#debug=False
line="-----------------------------------------------------------"
'''
Return the list of filesystems known to this Cluster'
'''
print('Return the list of filesystems known to this Cluster')
print(line)
url= server + 'scalemgmt/v2/' + 'filesystems'

try:
    # send a GET and return a response object
    r = requests.get(url = url, auth=ss_auth, verify=False) 
except:
    print('An error has occurred.')    
print(r.text)
