Section03 - Deploying_Concourse_CI_Server


Helm Install/Upgrade of Concourse
===========
Current Release
==========
- [] New install make sure the image tag and chart:
  imageTag: "7.8.1" chart: "concourse-17.0.15"
  https://github.com/concourse/concourse-chart/releases/

Concourse keeps adding in new features and integrations on a weekly cadence.
If you wish to upgrade the image tag or chart version, you should first test it with a new deploy in a separate environment

## pipeline-specific template for SSM parameters, defaults to: /concourse/{{.Team}}/{{.Pipeline}}/{{.Secret}}
      ##
      pipelineSecretTemplate: /concourse/{{.Team}}/{{.Pipeline}}/{{.Secret}}

- [] Before installing, update the ci user password in the values file on line 2788 from $PASSWORD to something new
    - line 2789:localUsers: "ci:cisco@2022,ap-south-1a:ap-south-1a!"
- [] Update your vault url and also your concourse web external url
    - line 250: externalUrl: http://dev-ci.ciscolivedemo2022.com:8080
    - line 568: url: http://dev-vault.ciscolivedemo2022.com:8200url: http://dev-vault.ciscolivedemo2022.com:8200
- [] Generate an approle_id and secret_id in vault and update the values file - there are two place to update this, search on "vaultAuthParam"
    - line 607: vaultAuthParam: "role_id:504cc747-f759-f26b-f477-d0de7c1b5bdb,secret_id:c81036b8-c7e1-0681-f427-9872f80d7020"
- [] Test out your approle_id and secret_id :

curl -k -XPOST -d '{"role_id":"c5b11052-e660-1615-2d99-4337dea60166","secret_id":"00d19ad5-8a45-ab8e-0ae3-d27bb5493914"}'http://prod-vault.devops-ontap.com:8200/v1/auth/approle/login | jq


Helm Upgrades
======

Before doing a helm upgrade of concourse you must generate a new secret_id
After doing a Helm upgrade of concourse you must re-create teams and assign appropriate roles

fly -t cisco-fso-labs set-team --team-name cisco-fso-labs --local-user us-west-1a -c roles/owner.yml

Login
====

fly --target=prod login --concourse-url=http://prod-ci.devops-ontap.com:8080 -n main --username=ci --password=""

fly --target=dev login --concourse-url=http://dev-ci.ciscolivedemo2022.com:8080 -n main --username=ci --password=cisco@2022

Set-Pipeline Example:
========
fly -t dev set-pipeline -p development e -c pipeline-v3.yml -l /Users/sconrod/dev/cisco-fso-lab-gen/params/main-us-west-2a.yml -v aws.region=us-west-2 -v az.name=us-west-2a -v vault.addr=http://prod-vault.devops-ontap.com:8200

fly -t dev set-pipeline -p development -c /Users/anmodi/dev/ciscolivedemo/pipelines/pipeline-v4.yml -l /Users/anmodi/dev/notes-ciscolive/ciscolive-params.yml -v aws.region=us-west-1 -v az.name=us-west-1a -v vault.addr=http://dev-vault.ciscolivedemo2022.com:8200

fly -t development set-pipeline -p pipeline1 -c /Users/anmodi/dev/ciscolivedemo/pipelines/pipeline-v2.yml -l /Users/anmodi/dev/notes-ciscolive/ciscolive-params.yml -v aws.region=ap-south-1 -v az.name=ap-south-1a -v vault.addr=http://dev-vault.ciscolivedemo2022.com:8200

(you can also put the variables passed to this command in your parameters file)

Setup Teams and Roles
==========

fly -t cisco-fso-labs set-team --team-name cisco-fso-labs --local-user us-west-1a -c roles/owner.yml

fly -t development set-team --team-name development --local-user ap-south-1a -c roles/operator-role-cisco-fso-labs.yml

#concourse installation
#clone the concourse helm chart
git clone https://github.com/concourse/concourse-chart.git
cd concourse-chart/
#add the concourse helm repo
helm repo add concourse https://concourse-charts.storage.googleapis.com/
helm repo add bitnami https://charts.bitnami.com/bitnami
cd concourse-chart/
helm dependency build
kubectl create ns dev-ci
helm -n dev-ci install dev-ci . -f /Users/anmodi/dev/ciscolivedemo/HELM/CONCOURSE/dev/dev-ci-values.yaml
helm -n dev-ci install dev-ci . -f values.yaml
kubectl get svc -n dev-ci
kubectl get pods -n dev-ci
helm uninstall dev-ci -n dev-ci

Note down the loadbalance fqdn from the list
#Paste on browser to check if concourse is accessible externally, add 8080 port no.
#After successful test, add the loadbalancer fqdn as CNAME in hosted zone in route 53 entry
http://dev-ci.cisco-fso-labs.com:8080/
#enter the default user name & password as values.yaml file
cd /Users/anmodi/dev/cisco-fso-labs/HELM/CONCOURSE
fly --target=cisco-fso-labs login --concourse-url=http://dev-ci.cisco-fso-labs.com:8080 -n main --username=ci --password=PASSWORD!
fly --target=development login --concourse-url=http://dev-ci.ciscolivedemo2022.com:8080 -n main --username=ci --password=cisco@2022

# create team cisco-fso--labs
#setting up team and users
#https://concourse-ci.org/managing-teams.html
fly -t cisco-fso-labs set-team --team-name cisco-fso-labs --local-user us-west-2a
fly -t cisco-fso-labs set-team -n cisco-fso-labs -c operator-role-cisco-fso-labs.yml

