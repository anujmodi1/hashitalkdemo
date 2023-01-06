Section02-Deploying_Vault_Prod_Server

Helm is required to install the Vault server on kubernetes clusters.

**#helm installation**
sudo snap install helm --classic
#brew install helm
#https://helm.sh/docs/intro/install/

**#vault installation**
Current Release for Vault
Chart -  vault-0.20.1    APP VERSION 1.10.3
**Download the vault-helm chart**
#helm repo add hashicorp https://helm.releases.hashicorp.com
#helm pull https://github.com/hashicorp/vault-helm/releases/tag/v0.21.1

git checkout https://github.com/hashicorp/vault-helm.git
git checkout tags/v0.20.1

kubectl create ns dev-vault
kubectl  get all -n dev-vault
#clone the vault helm chart
git clone https://github.com:hashicorp/vault-helm.git
cd vault-helm/
#Use the chart.yaml file from repo to deploy vault
**#Vault Depployment**
helm -n dev-vault install dev-vault hashicorp/vault -f values.yaml
helm -n dev-vault install dev-vault . -f /Users/anmodi/dev/hashitalkdemo/Section02-Deploying_Vault_Prod_Server/dev-vault-values.yaml

helm status dev-vault -n dev-vault
kubectl  get all -n dev-vault
kubectl exec -it dev-vault-0 -n dev-vault -- vault status
kubectl exec -it pod/dev-vault-0 -n dev-vault -- vault operator init -n 1 -t 1
kubectl exec -it pod/dev-vault-0 -n dev-vault -- vault operator unseal FEosw0j/DTg3Dl+Q1qFKHH+5aFIjiiRSAYWl/hb1sT4=
#deleting the data in the vault
helm del --purge vault
helm uninstall dev-vault -n dev-vault

kubectl  get pods -n dev-vault
kubectl  get svc -n dev-vault
#Note down the loadbalance fqdn from the list
#Paste on browser to check if vault is accessible externally, add 8200 port no.
#After successful test, add the loadbalancer fqdn as CNAME in hosted zone in route 53 entry
http://dev-vault.cisco-fso-labs.com:8200/
#enter the root token to access the vault.

#Login into vault pod
kubectl exec -it dev-vault-0 -n dev-vault /bin/sh
vault login
#enable to concourse authentication into vault
#https://concourse-ci.org/vault-credential-manager.html

#configure kv secrets engine and mount it at /concourse
vault secrets enable -version=1 -path=concourse kv
#create a policy to allow Concourse to read from this path & save it.
path "concourse/*" {
capabilities = ["read"]
}

Until IAM STS Auth is configured (complex and not necessarily required for lab)

- [] Add the AWS Keys in the following format required by the pipeline. Check Pipeline Params.

- [] vault auth enable approle
- [] vault write auth/approle/role/concourse policies=concourse period=24h
- [] vault read auth/approle/role/concourse/role-id
- [] vault write -f auth/approle/role/concourse/secret-id
- [] update the concourse helm chart with the role-id and secret-id

#approle authentication for concourse
vault auth enable approle
#default is 1hour expiration policy
vault write auth/approle/role/concourse policies=concourse period=24h
#configure role_id and generate a secret_id to enter into concourse
vault read auth/approle/role/concourse/role-id
vault write -f auth/approle/role/concourse/secret-id

#ciscolivedemo and main policy

path "concourse/ciscolivedemo/*" {
  capabilities = ["read", "create","update", "list"]
}

path "concourse/main/*" {
  capabilities = ["read", "create","update", "list"]
}

#ciscolivedemo and main secrets
aws key, secret and ssh.token
AWS_KEY_ID: ((Access_key_ID.Access_key))
AWS_KEY: ((Secret_access_key.Secret_access_key))
SSH_TOKEN: ((ssh-token.token))


vault token create --policy ciscolivedemo --period 24h