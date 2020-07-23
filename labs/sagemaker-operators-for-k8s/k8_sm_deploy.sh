#!/bin/bash
# Install Sagemaker Operators on EKS

source ~/.bash_profile

# Set the Region and cluster
export AWS_CLUSTER_NAME="kf-sm-workshop"
export AWS_REGION="us-west-2"

#Upgrade AWSCLI
#sudo yum install python3 pip3 -y
#sudo pip3 install --upgrade awscli
#sudo pip3 install --upgrade numpy
#source ~/.bashrc

export AWS_ACCOUNT_NUMBER=$(aws sts get-caller-identity --output text --query Account)
eksctl utils associate-iam-oidc-provider --cluster ${AWS_CLUSTER_NAME} --region ${AWS_REGION} --approve
#export OIDC_ID=$(aws eks describe-cluster --query cluster --name ${AWS_CLUSTER_NAME} --output text | grep OIDC | awk  '{print $2}' | grep -oP '(?<=https://oidc.eks.us-west-2.amazonaws.com/id/).*' )
export OIDC_ID=$(aws eks describe-cluster --query cluster --name ${AWS_CLUSTER_NAME} --output text | grep OIDC | awk  '{print $2}' | grep -oP '(?<=amazonaws.com/id/).*' )



echo $AWS_ACCOUNT
echo $OIDC_ID
echo ================================

cd /home/ec2-user/SageMaker/aws-ml-workshop/labs/sagemaker-operators-for-k8s
envsubst < "trust-placeholder.json" > "trust.json"

aws iam create-role --role-name sagemaker-${AWS_CLUSTER_NAME} --assume-role-policy-document file://trust.json --output=text

aws iam attach-role-policy --role-name sagemaker-${AWS_CLUSTER_NAME} --policy-arn arn:aws:iam::aws:policy/AmazonSageMakerFullAccess

wget -O installer.yaml https://raw.githubusercontent.com/aws/amazon-sagemaker-operator-for-k8s/master/release/rolebased/installer.yaml

export SagemakerRoleArn=$(aws iam get-role --role-name sagemaker-${AWS_CLUSTER_NAME} --output text | grep  role | awk  '{print $2}')
echo ${SagemakerRoleArn}
# Edit the installer.yaml file to replace eks.amazonaws.com/role-arn. Replace the ARN here with the Amazon Resource Name (ARN) for the OIDC-based role you’ve created.

sed -i "s|arn:aws:iam::123456789012:role.*|$SagemakerRoleArn|" installer.yaml

eksctl utils write-kubeconfig --cluster ${AWS_CLUSTER_NAME}

kubectl apply -f installer.yaml

sleep 15

kubectl get crd | grep sagemaker

kubectl -n sagemaker-k8s-operator-system get pods

echo =================================
export assume_role_policy_document='{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Service": "sagemaker.amazonaws.com"
    },
    "Action": "sts:AssumeRole"
  }]
}'


export SAGEMAKER_IAM_ROLE=sm-operator-k8s-role

aws iam create-role --role-name $SAGEMAKER_IAM_ROLE --assume-role-policy-document file://<(echo "$assume_role_policy_document")
aws iam attach-role-policy --role-name $SAGEMAKER_IAM_ROLE --policy-arn arn:aws:iam::aws:policy/AmazonSageMakerFullAccess
aws iam attach-role-policy --role-name $SAGEMAKER_IAM_ROLE --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

export SAGEMAKER_IAM_ROLE_ARN=$(aws iam get-role --role-name $SAGEMAKER_IAM_ROLE --output text | grep  role | awk  '{print $2}')
echo ${SAGEMAKER_IAM_ROLE_ARN}

echo ====== uploading training data to S3 bucket ======
aws s3 mb "s3://k84sm-bucket-2"
export S3_BUCKET=k84sm-bucket-2
cd /home/ec2-user/SageMaker/aws-ml-workshop/labs/sagemaker-operators-for-k8s/scripts/upload_xgboost_mnist_dataset 
./upload_xgboost_mnist_dataset --s3-bucket ${S3_BUCKET} --s3-prefix xgboost-mnist
cd /home/ec2-user/SageMaker/aws-ml-workshop/labs/sagemaker-operators-for-k8s
echo $SAGEMAKER_IAM_ROLE_ARN
echo $SAGEMAKER_IAM_ROLE
echo $S3_BUCKET
echo $AWS_REGION

echo ==== exporting setting env var for reuse in bash shell ====
echo export S3_BUCKET=${S3_BUCKET}
echo export AWS_REGION=us-west-2
echo export SAGEMAKER_IAM_ROLE=sm-operator-k8s-role
echo export SAGEMAKER_IAM_ROLE_ARN=${SAGEMAKER_IAM_ROLE_ARN}


echo ==== and finally, let us launch a training job ====
envsubst < 00-xgboost-mnist-trainingjob.yaml | kubectl create -f -

# this is how to launch a real-time endpoint
#export MODEL_DATA_URL=s3://.....model.tar.gz
#envsubst < 02-xgboost-mnist-hostingdeployment.yaml | kubectl create -f -


###Clean-up if you want to re-run the script to create a new training job:
#kubectl delete --all --all-namespaces hyperparametertuningjob.sagemaker.aws.amazon.com
#kubectl delete --all --all-namespaces trainingjobs.sagemaker.aws.amazon.com
#kubectl delete --all --all-namespaces batchtransformjob.sagemaker.aws.amazon.com
#kubectl delete --all --all-namespaces hostingdeployment.sagemaker.aws.amazon.com

# kubectl edit trainingjob xgboost-mnist
### delete these two lines from the file:
#  finalizers:
#  - sagemaker-operator-finalizer

# kubectl delete trainingjob xgboost-mnist

# Delete the operator and its resources
# kubectl delete -f installer.yaml

# delete the two IAM roles that were previously created, such as
## sagemaker-kf-sm-workshop
## sm-operator-k8s-role


### other useful kubectl commands:
# kubectl describe trainingjob xgboost-mnist

# eksctl get clusters
# aws eks update-kubeconfig --name kf-sm-workshop
# kubectl get nodes -A


#export S3_BUCKET=k84sm-bucket-2
#export AWS_REGION=us-west-2
#export SAGEMAKER_IAM_ROLE=sm-operator-k8s-role
#export SAGEMAKER_IAM_ROLE_ARN=arn:aws:iam::656344526285:role/sm-operator-k8s-role
