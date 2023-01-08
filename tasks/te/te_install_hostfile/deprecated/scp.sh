#!/bin/sh
export name=$NAME
export VAULT_ADDR=$VAULT_ADDR
export SSH_TOKEN=$SSH_TOKEN
export TE_GROUP=$TE_GROUP
vault login --no-print $SSH_TOKEN
vault kv get --field=ssh-key concourse/cisco-fso-labs/$NAME/ssh-key >> sshkey.pem
chmod 400 sshkey.pem
sshkey='sshkey.pem'
echo "${sshkey}" | ssh-add -
key='sshkey.pem'
user='ubuntu'
hostfile='hostfile'
apt-get -yqq install ssh
for server in $(cat hostfile)
do
  ssh-keyscan -H "$server" >> ~/.ssh/known_hosts
  scp -i $sshkey -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null install_thousandeyes.sh $user@$server:/tmp/ &
done
wait