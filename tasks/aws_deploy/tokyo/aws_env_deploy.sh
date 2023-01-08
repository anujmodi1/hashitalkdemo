#!/bin/sh
export AWS_PAGER=""
export VAULT_ADDR=$VAULT_ADDR
export VAULT_TOKEN=$SSH_TOKEN
vault login --no-print $VAULT_TOKEN
export NAME=$NAME
python3 git-resource/tasks/aws_deploy/tokyo/aws-deploy-env-train.py
