#!/usr/bin/env python
import json, re, sys, os, json, subprocess, time, logging, requests, paramiko
from subprocess import call, check_output
from requests.structures import CaseInsensitiveDict



#Install the Agent
TE_GROUP = os.getenv('TE_GROUP')
host = os.getenv('HOST')


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
    "export TE_GROUP=$TE_GROUP",
    "echo $TE_GROUP",
    "sudo curl -Os https://downloads.thousandeyes.com/agent/install_thousandeyes.sh",
    "sudo chmod a+x install_thousandeyes.sh",
    "sudo ./install_thousandeyes.sh -f vojylvcce2gwg4u0e1mcg000gn96h0tj"

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
