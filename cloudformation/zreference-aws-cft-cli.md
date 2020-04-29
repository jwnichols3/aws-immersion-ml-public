# Reference for deploying a cloudformation stack via the AWS CLI

Use this command to deploy the SageMaker Notebook that includes the EKS cluster, along with required software. Make sure you're pointed to the correct AWS account.

Change to the repo directory first. Note: this is set to run in us-west-2 (Oregon)

```
cd cloudformation

aws cloudformation create-stack --stack-name aws-ml-workshop-sagemaker --timeout-in-minutes 60 --template-body file://cft-sagemaker-notebook.yaml --output yaml --region us-west-2 --capabilities CAPABILITY_IAM

```
