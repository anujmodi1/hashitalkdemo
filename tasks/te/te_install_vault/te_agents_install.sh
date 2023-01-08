#!/bin/sh
cd git-resource/tasks/te
export AWS_PAGER=""
export NAME=us-west-1a
apt -y update && apt -y upgrade
python3 -m pip install paramiko -U
export VAULT_ADDR=$VAULT_ADDR
export SSH_TOKEN=$SSH_TOKEN
vault login --no-print $SSH_TOKEN
vault kv get --field=ssh-key concourse/cisco-fso-labs/$NAME/ssh-key >> sshkey.pem
chmod 400 sshkey.pem
SSHKEY='sshkey.pem'
mkdir ~/.ssh
touch ~/.ssh/known_hosts
echo "${SSHKEY}" | ssh-add -
export server=$(vault kv get --field=ubuntu_ip concourse/cisco-fso-labs/$NAME/ubuntu_ip)
echo "The external ip for the ubuntu instance on the router subnet is....."
echo $server
ssh-keyscan -H "$server" >> ~/.ssh/known_hosts
scp -i sshkey.pem install_te.sh ubuntu@"$server":~/
python3 te_agents_install.py



