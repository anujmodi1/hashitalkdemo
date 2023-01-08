#!/bin/sh
export AWS_PAGER=""
export name=$NAME
export VAULT_ADDR=$VAULT_ADDR
export SSH_TOKEN=$SSH_TOKEN
export TE_GROUP=$TE_GROUP
vault login --no-print $SSH_TOKEN
vault kv get --field=ssh-key concourse/cisco-fso-labs/$NAME/ssh-key >> sshkey.pem
export tegroup=$(vault kv get --field=token concourse/cisco-fso-labs/te-group)
chmod 400 sshkey.pem
python3 configure_te_agent.py


