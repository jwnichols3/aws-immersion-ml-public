## Amazon SageMaker Operators for Kubernetes

Amazon SageMaker Operators for Kubernetes make it easier for developers and data scientists using Kubernetes to train, tune, and deploy machine learning models in Amazon SageMaker. You can install these SageMaker Operators on your Kubernetes cluster in Amazon Elastic Kubernetes Service (EKS) to create SageMaker jobs natively using the Kubernetes API and command-line Kubernetes tools such as ‘kubectl’. 

### Operator Deployment

Create an OpenID Connect Provider for Your Cluster

```
# Set the Region and cluster
export CLUSTER_NAME="<your cluster name>"
export AWS_REGION="<your region>"

```
Use the following command to associate the OIDC provider with your cluster.

```
eksctl utils associate-iam-oidc-provider --cluster ${CLUSTER_NAME} \
    --region ${AWS_REGION} --approve
```

Get the OIDC ID
To set up the ServiceAccount, first obtain the OpenID Connect issuer URL using the following command:

```
aws eks describe-cluster --name ${CLUSTER_NAME} --region ${AWS_REGION} \
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
aws iam create-role --role-name <role name> --assume-role-policy-document file://trust.json --output=text
```

Take note of ROLE ARN, you pass this value to your operator.

Attach the AmazonSageMakerFullAccess Policy to the Role

To give the role access to Amazon SageMaker, attach the AmazonSageMakerFullAccess policy. If you want to limit permissions to the operator, you can create your own custom policy and attach it.

To attach AmazonSageMakerFullAccess, run the following command:

```
aws iam attach-role-policy --role-name <role name>  --policy-arn arn:aws:iam::aws:policy/AmazonSageMakerFullAccess

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
Replace the '< execution role name >' with the name of the role you want to create

```
aws iam create-role --role-name <execution role name> --assume-role-policy-document file://<(echo "$assume_role_policy_document")

aws iam attach-role-policy --role-name <execution role name> --policy-arn arn:aws:iam::aws:policy/AmazonSageMakerFullAccess

```

#### Create training data

We will use the built in SageMaker xgboost container to train an xgboost model using the MNIST dataset

To prepare the dataset, you can use the upload_xgboost_mnist_dataset script in the scripts folder. 

First, create an S3 bucket with 'sagemaker' (for eg, {prefix}-sfdc-kf-sagemaker-workshop) in its name so that the role has the permission to create files in the bucket.

Next, execute the following command in the scripts folder by replacing the bucket name with the bucket you created.

```
./upload_xgboost_mnist_dataset --s3-bucket BUCKET_NAME --s3-prefix xgboost-mnist

```
This script will upload the training, validation and test data to the S3 bucket.

#### Submitting the training jobs

Next, we will use the YAML configuration files to start jobs (training, hpo, deployment etc.) in SageMaker.  Make sure you replace the SageMaker execution role ARN, S3 bucket and the AWS region values.

Before we can do training 
To start a training job, use the following command.

```
kubectl apply -f 00-xgboost-mnist-trainingjob.yaml

```
To deploy trained model to a SageMaker endpoint, use the following command. Edit the configuraiton file to provide the correct "modelDataUrl" and the SageMaker execution role ARN.


```
kubectl apply -f 02-xgboost-mnist-hostingdeployment

```



