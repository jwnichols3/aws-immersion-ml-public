#!/bin/bash

sudo yum -y install docker

# nohup pip install --upgrade pip > pip-upgrade.out 2> pip-upgrade.err &

curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/kubectl

chmod +x ./kubectl

sudo mv -v ./kubectl /usr/local/bin

curl --silent --location "https://github.com/kubeflow/kfctl/releases/download/v1.0.2/kfctl_v1.0.2-0-ga476281_linux.tar.gz" | tar xz -C /tmp

sudo mv -v /tmp/kfctl /usr/local/bin

# May 14, 2020: Defaulting to 0.18 as 0.19 caused errors
# curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/0.18.0/eksctl_Linux_amd64.tar.gz" | tar xz -C /tmp

sudo mv -v /tmp/eksctl /usr/local/bin

curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/aws-iam-authenticator

chmod +x ./aws-iam-authenticator

sudo mv -v ./aws-iam-authenticator /usr/local/bin

# nohup eksctl create cluster --name=kf-sm-workshop --version=1.15 --nodes=6 --managed --alb-ingress-access --region=us-west-2 > kf-sm-workshop-eksctl.out 2> kf-sm-workshop-eksctl.err & 

eksctl create cluster --name=kf-sm-workshop --version=1.15 --nodes=6 --managed --alb-ingress-access --region=us-west-2

yum -y update

cd aws-ml-workshop
