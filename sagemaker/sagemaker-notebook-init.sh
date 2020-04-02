#!/bin/bash
set -e
cd /home/ec2-user/SageMaker
curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv -v ./kubectl /usr/local/bin
curl --silent --location "https://github.com/kubeflow/kfctl/releases/download/v1.0.1/kfctl_v1.0.1-0-gf3edb9b_linux.tar.gz" | tar xz -C /tmp
sudo mv -v /tmp/kfctl /usr/local/bin
curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv -v /tmp/eksctl /usr/local/bin
curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/aws-iam-authenticator
chmod +x ./aws-iam-authenticator
sudo mv -v ./aws-iam-authenticator /usr/local/bin
### Commenting out
# nohup eksctl create cluster --name=kf-sm-workshop --version=1.15 --nodes=6 --managed --alb-ingress-access --region=us-west-2 & 

## Commenting out
# git clone https://github.com/jwnichols3/aws-immersion-ml-public.git ml-immersion-day
#cd ml-immersion-day
