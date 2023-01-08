#!/bin/sh
export AWS_PAGER=""
export name=$NAME
export VAULT_ADDR=$VAULT_ADDR
export SSH_TOKEN=$SSH_TOKEN
vault login --no-print $SSH_TOKEN
vault kv get --field=ssh-key concourse/cisco-fso-labs/$NAME/ssh-key >> sshkey.pem
export TE_GROUP=$(vault kv get --field=token concourse/cisco-fso-labs/te-group)
chmod 400 sshkey.pem
python3 configure_te_agent.py


