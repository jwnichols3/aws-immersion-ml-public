# Machine Learning Workshop

This is a set of instructions and exercises for a Machine Learning Workshop. This Machine Learning oriented content is focused on the use of Kubernetes (i.e. EKS).

## Overview

These instructions assume you are running this on your own. If you are running as part of an AWS Workshop, it is likely you are using Event Engine. In that case, please refer to the main [README](README.md) for instructions.

## Running on your own

### AWS Account

The first pre-requsite is you need an AWS Account. This Workshop assumes you either have access to an AWS Account or know how to create and manage an AWS Account. Charges incurred as part of this Workshop are your responsibility. **Be sure to terminate any resources at the end of each section to stop incurring charges.**

This workshop assumes you have working knowledge of AWS and understand the above statement about terminating resources. If you don't know what that means, I recommend starting with the course [Introduction to AWS on A Cloud Guru](https://acloud.guru/learn/aws-technical-essentials).

### Workstation Setup

If you are running this on your own: on your workstation, have the following installed and configured. For maintainability of this repo, these are links to the package installation instructions for each (versus a set of instructions in this project).

- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
- [eksctl](https://eksctl.io/intro/#installation)
- [kubectl (EKS specific)](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html)
- [aws-iam-authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)
- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) - [GitHub Setup](https://help.github.com/en/github/getting-started-with-github/set-up-git)

## Launching your Environment

(If the following instructions do not make sense, please check out the A Cloud Guru course [Introduction to AWS CloudFormation](https://acloud.guru/learn/intro-aws-cloudformation).)
Launch [AWS CloudFormation console in `us-west-2`](https://us-west-2.console.aws.amazon.com/cloudformation/home?region=us-west-2).

Launch the [SageMaker Notebook CloudFormation template](cloudformation/cft-sagemaker-notebook.yaml).

If you have your AWS CLI configured, you can run this command at a shell prompt in the root of the github repo folder:

```shell
aws cloudformation create-stack --stack-name MLWorkshop --template-body file://cloudformation/cft-sagemaker-notebook.yaml --output json --region us-west-2 --capabilities CAPABILITY_IAM
```

### Environment

This CloudFormation template creates the following resources:

- SageMaker Notebook Instance (ml.t3.large) with all of the pre-requsite packages installed.
- When the SageMaker Notebook lauches, it launches an EKS cluster called `kf-sm-workshop` via `eksctl`.

#### kf-sm-workshop

The output of the eksctl command is stored in the SageMaker Notebook instance in `/home/ec2-user/SageMaker/kf-sm-workshop-eksctl.out` (errors are logged in `/home/ec2-user/SageMaker/kf-sm-workshop-eksctl.err`). If you have any issues with the EKS cluster launching, please check these two files.

### Github Repo

The instructions, including this file, are stored on the SageMaker Notebook instance in the folder `/home/ec2-user/SageMaker/aws-ml-workshop`.

## Connecting to your EKS Cluster from a Different System (e.g. your local Workstation)

If you want to connect to the EKS cluster from a different system (e.g. your local workstation), follow [these instructions](cloudformation/README.md#Optional-Connect-to-the-EKS-cluster-from-a-Different-System).

## What's Next

Launch the Juypter Labs on the SageMaker Notebook instance and follow along with the next steps. There are several labs included with this Workshop, including:

- [Kubeflow on EKS](labs/kubeflow/README-SELFPACED.md)
- [Kubeflow Pipelines with SageMaker](labs/sagemaker-kubeflow-pipeline/README-SELFPACED.md)
- [SageMaker Batch Transform](labs/sagemaker/README-SELFPACED.md)
- [SageMaker Multi-Model Endpoints (MME)](labs/sagemaker/README-SELFPACED.md)
- [SageMaker Hyper-Parameter Optimization](labs/sagemaker/README-SELFPACED.md)
- [SageMaker Operators for Kubernetes](labs/sagemaker-operators-for-k8s/README-SELFPACED.md)
