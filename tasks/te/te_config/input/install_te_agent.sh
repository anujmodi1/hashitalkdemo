#!/bin/sh
export AWS_PAGER=""
export name=$NAME
export VAULT_ADDR=$VAULT_ADDR
export SSH_TOKEN=$SSH_TOKEN
export TE_GROUP=$TE_GROUP
vault login --no-print $SSH_TOKEN
cd git-resource/tasks/te/te_config/input
vault kv get --field=ssh-key concourse/cisco-fso-labs/$NAME/ssh-key >> sshkey.pem
chmod 400 sshkey.pem
export HOST=$(vault kv get --field=ubuntu_ip concourse/cisco-fso-labs/$NAME/ubuntu_ip)
python3 install_te_agent.py