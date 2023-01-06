Section01 - Deploying_K8s_Cluster

To deploy the kubernetes cluster on AWS, you should have AWS access key and secret key with rights to execute the aws cli commands.

**Pre-requisites**

**#aws cli installation**
# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
#curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
#sudo installer -pkg AWSCLIV2.pkg -target /

**#brew installation**
# https://mac.install.guide/homebrew/3.html
# xcode-select --install
#/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

**# Kops installation**
#brew update && brew install kops

#Create the AWS root and developer account, save the access key id and secret.
#https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html

# create kops account user, group and assign policies to group and user.
aws iam create-group --group-name kops

aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess --group-name kops
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonRoute53FullAccess --group-name kops
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess --group-name kops
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/IAMFullAccess --group-name kops
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonVPCFullAccess --group-name kops
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonSQSFullAccess --group-name kops
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess --group-name kops

aws iam create-user --user-name kops
aws iam add-user-to-group --user-name kops --group-name kops
aws iam create-access-key --user-name kops

**AWS Access Key ID and Secret Config**
aws configure --profile kops
aws s3 ls --profile kops
export AWS_PROFILE=default
export AWS_PROFILE=kops
cat ~/.aws/credentials
aws iam list-users

export AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id)
export AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key)
#DNS configuration, create the hosted zone in route53
# domain name: ciscolivedemo2022.com
#name servers from aws
ns-1924.awsdns-48.co.uk.
ns-1037.awsdns-01.org.
ns-193.awsdns-24.com.
ns-739.awsdns-28.net.

#test dns servers
dig ns ciscolivedemo2022.com

**Creating s3 bucket**
aws s3api create-bucket \
--bucket cisco-fso-labs-kops-state \
--region us-west-1

aws s3api create-bucket \
--bucket ciscolivedemo2022-kops-state \
--region ap-south-1 \
--create-bucket-configuration LocationConstraint=ap-south-1

#Enable versioning
aws s3api put-bucket-versioning --bucket ciscolivedemo-kops-state  --versioning-configuration Status=Enabled
#export variables
#export NAME=cluster1.k8s.local
export NAME=k8s.ciscolivedemo2022.com
export KOPS_STATE_STORE=s3://ciscolivedemo2022-kops-state

#Enable versioning
aws s3api put-bucket-versioning --bucket ciscolivedemo-kops-state  --versioning-configuration Status=Enabled
#export variables
#export NAME=cluster1.k8s.local
export NAME=k8s.ciscolivedemo2022.com
export KOPS_STATE_STORE=s3://ciscolivedemo2022-kops-state

#kops export kubeconfig $NAME --admin

**#Kubernets cluster creation**
kops create cluster --name=${NAME} --cloud=aws --zones=us-west-1a --master-size t2.micro --node-size t2.micro --kubernetes-version 1.20.15
kops create cluster --name=${NAME} --cloud=aws --zones=us-west-1a --master-size t2.medium --node-size t2.medium
kops create cluster --name=${NAME} --cloud=aws --zones=us-west-1a --master-size t2.micro --node-size t2.micro --kubernetes-version 1.20.15
kops create cluster --name=${NAME} --cloud=aws --zones=ap-south-1a --master-size t2.medium --node-size t2.medium
kops get cluster
kops edit cluster ${NAME}
#kops update cluster --name ${NAME} --yes --admin
kops update cluster --name ${NAME} --yes --admin
kops validate cluster --wait 10m
# ssh -i ~/.ssh/id_rsa ubuntu@api.kube.ciscolivedemo2022.com
kops delete cluster --name ${NAME} --yes
kubectl get nodes --show-labels

#upgrading cluster
kops upgrade cluster --yes
kops rolling-update cluster --yes


#testing pods and loadbalancer
kubectl create deployment my-nginx --image=nginx --replicas=1 --port=80
kubectl expose deployment my-nginx --port=80 --type=LoadBalancer
