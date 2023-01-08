#!/usr/bin/env python
import json, re, sys, os, json, subprocess, time, logging, requests, paramiko
from subprocess import call, check_output
from requests.structures import CaseInsensitiveDict

#Download the TE Agent
#Scp the Agent to the Ubuntu
#Install the Agent
os.getenv('tegroup')
host='54.177.5.8'

private_key='sshkey.pem'
key = paramiko.RSAKey.from_private_key_file(private_key)
username='ubuntu'

# connect to server
con = paramiko.SSHClient()
con.set_missing_host_key_policy(paramiko.AutoAddPolicy())
con.load_system_host_keys()
con.connect(host, username=username, allow_agent=False, pkey=key)

commands = [
    "export TERMINFO=/usr/lib/terminfo",
    "TERM=xterm",
    "sudo curl -Os https://downloads.thousandeyes.com/agent/install_thousandeyes.sh",
    "sudo chmod a+x install_thousandeyes.sh",
    "sudo ./install_thousandeyes.sh -f -b tegroup",
    "sudo apt-add-repository https://apt.thousandeyes.com",
    "sudo wget -q https://apt.thousandeyes.com/thousandeyes-apt-key.pub -O- | sudo apt-key add -",
    "sudo apt -y update",
    "sudo apt-key list",
    "sudo apt-get install te-agent-utils"

]

# execute the commands
for command in commands:
    print("="*50, command, "="*50)
    stdin, stdout, stderr = con.exec_command(command, get_pty=True)
    print(stdout.read().decode())
    err = stderr.read().decode()
    time.sleep(3)
    if err:
        print(err)
con.close()
