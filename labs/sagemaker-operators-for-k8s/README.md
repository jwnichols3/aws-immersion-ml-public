## Amazon SageMaker Operators for Kubernetes

Amazon SageMaker Operators for Kubernetes make it easier for developers and data scientists using Kubernetes to train, tune, and deploy machine learning models in Amazon SageMaker. You can install these SageMaker Operators on your Kubernetes cluster in Amazon Elastic Kubernetes Service (EKS) to create SageMaker jobs natively using the Kubernetes API and command-line Kubernetes tools such as ‘kubectl’. 

### Operator Deployment

switch to bash
```
bash
```

Create an OpenID Connect Provider for Your Cluster

```
# Set the Region and cluster
export AWS_CLUSTER_NAME="kf-sm-workshop"
export AWS_REGION="us-west-2"

```

Use the following command to associate the OIDC provider with your cluster.

```
eksctl utils associate-iam-oidc-provider --cluster ${AWS_CLUSTER_NAME} \
    --region ${AWS_REGION} --approve
```

Get the OIDC ID
To set up the ServiceAccount, first obtain the OpenID Connect issuer URL using the following command:

```
aws eks describe-cluster --name ${AWS_CLUSTER_NAME} --region ${AWS_REGION} \
    --query cluster.identity.oidc.issuer --output text
```

The command will return a URL like the following:

```
https://oidc.eks.${AWS_REGION}.amazonaws.com/id/D48675832CA65BD10A532F597OIDCID
```
In this URL, the value D48675832CA65BD10A532F597OIDCID is the OIDC ID. The OIDC ID for your cluster will be different. You need this OIDC ID value to create a role.

Create an IAM Role

Create a file named trust.json and insert the following trust relationship code block into it. Be sure to replace all OIDC ID, AWS account number, and EKS Cluster region placeholders with values corresponding to your cluster.


```

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<AWS account number>:oidc-provider/oidc.eks.<EKS Cluster region>.amazonaws.com/id/<OIDC ID>"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.<EKS Cluster region>.amazonaws.com/id/<OIDC ID>:aud": "sts.amazonaws.com",
          "oidc.eks.<EKS Cluster region>.amazonaws.com/id/<OIDC ID>:sub": "system:serviceaccount:sagemaker-k8s-operator-system:sagemaker-k8s-operator-default"
        }
      }
    }
  ]
}

```
Run the following command to create a role with the trust relationship defined in trust.json. This role enables the Amazon EKS cluster to get and refresh credentials from IAM.

```
aws iam create-role --role-name sm-operator-k8s-oidc-role --assume-role-policy-document file://trust.json --output=text
```

Take note of ROLE ARN, you pass this value to your operator.

Attach the AmazonSageMakerFullAccess Policy to the Role

To give the role access to Amazon SageMaker, attach the AmazonSageMakerFullAccess policy. If you want to limit permissions to the operator, you can create your own custom policy and attach it.

To attach AmazonSageMakerFullAccess, run the following command:

```
aws iam attach-role-policy --role-name sm-operator-k8s-oidc-role  --policy-arn arn:aws:iam::aws:policy/AmazonSageMakerFullAccess

```

The Kubernetes ServiceAccount sagemaker-k8s-operator-default should have AmazonSageMakerFullAccess permissions. Confirm this when you install the operator.


#### Deploy the Operator Using YAML

Download the installer script using the following command:

```
wget https://raw.githubusercontent.com/aws/amazon-sagemaker-operator-for-k8s/master/release/rolebased/installer.yaml

```

Edit the installer.yaml file to replace eks.amazonaws.com/role-arn. Replace the ARN here with the Amazon Resource Name (ARN) for the OIDC-based role you’ve created.

Use the following command to deploy the cluster:

```
kubectl apply -f installer.yaml

```

Verify the operator deployment

```
kubectl get crd | grep sagemaker

```
Ensure that the operator pod is running successfully. Use the following command to list all pods:

```
kubectl -n sagemaker-k8s-operator-system get pods

```

### Creating an IAM Role for SageMaker

Next, using the commands below, we will create a SageMaker execution role. We will use this role from the SageMaker Job definition files. This role should be different from the one attached to the OIDC provider.

```
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

```
Run following commands to create sm-operator-k8s-role role and attach role policy. 

```
export SAGEMAKER_IAM_ROLE=sm-operator-k8s-role
aws iam create-role --role-name $SAGEMAKER_IAM_ROLE --assume-role-policy-document file://<(echo "$assume_role_policy_document")

aws iam attach-role-policy --role-name $SAGEMAKER_IAM_ROLE --policy-arn arn:aws:iam::aws:policy/AmazonSageMakerFullAccess

```

#### Create training data

We will use the built in SageMaker xgboost container to train an xgboost model using the MNIST dataset

To prepare the dataset, you can use the upload_xgboost_mnist_dataset script in the "scripts/upload_xgboost_mnist_dataset" folder. 

Use previously created bucket in earlier labs {prefix}-sfdc-kf-sagemaker-workshop-data

```
export S3_BUCKET={prefix}-sfdc-kf-sagemaker-workshop-data

```

Next, execute the following command in the scripts folder by replacing the bucket name with the bucket you created.

```
cd /home/ec2-user/SageMaker/aws-ml-workshop/labs/sagemaker-operators-for-k8s/scripts/upload_xgboost_mnist_dataset
./upload_xgboost_mnist_dataset --s3-bucket $S3_BUCKET --s3-prefix xgboost-mnist

```
This script will upload the training, validation and test data to the S3 bucket.

#### Submitting the training jobs

Next, we will use the YAML configuration files to start jobs (training, hpo, deployment etc.) in SageMaker.  

Navigate to the "sagemaker-operators-for-k8s" folder 

```shell
cd /home/ec2-user/SageMaker/aws-ml-workshop/labs/sagemaker-operators-for-k8s

```

Execute the following command to start the training job by substituting the environment variables in the yaml file(SAGEMAKER_IAM_ROLE, S3_BUCKET & AWS_REGION)

```

envsubst < 00-xgboost-mnist-trainingjob.yaml | kubectl create -f -

```

Look up the path for the "model.tar.gz" file generated by the training job in the AWS S3 Console(You can find the model file inside the "output" folder inside the S3 bucket
It should look like the following S3 URL:
"s3://{prefix}-sfdc-kf-sagemaker-workshop-data/xgboost-mnist/xgboost-mnist-fe96de1600c145feaa55485c8a10ba58/output/model.tar.gz")

Set an environment variable "MODEL_DATA_URL" with the path to the model.tar.gz file.
```
export MODEL_DATA_URL=s3://{prefix}-sfdc-kf-sagemaker-workshop-data/xgboost-mnist/xgboost-mnist-fe96de1600c145feaa55485c8a10ba58/output/model.tar.gz

To deploy trained model to a SageMaker endpoint, use the following command by substituting the environment variables in the yaml file(SAGEMAKER_IAM_ROLE, MODEL_DATA_URL)
```
envsubst < 00-xgboost-mnist-trainingjob.yaml | kubectl create -f

```



