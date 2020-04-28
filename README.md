# Machine Learning Workshop

This is a set of instructions and exercises for a Machine Learning Workshop. This Machine Learning oriented content is focused on the use of Kubernetes (i.e. EKS).

## Overview

These instructions assume your Workshop is using Event Engine. You will have the following resources pre-configured in ```us-west-2 (Oregon)``` region:

- EKS Cluster named **kf-sm-workshop**
- Sagemaker Notebook with ```AWS CLI```, ```eksctl```, ```kubectl```, ```aws-iam-authentictor```, ```git```, and ```kfctl```.

Note: if you are running this workshop on your own, please see the [Self Paced Instructions](README-SELFPACED.md).

## First Steps

1. Login to your AWS Account using the supplied method.
2. Navigate to [SageMaker Service](https://us-west-2.console.aws.amazon.com/sagemaker/)
3. Verify / Change to the Oregon (us-west-2) region
4. Launch Juypter Hub on the BasicNotebookInstance
5. Open a terminal
6. Run the command: ```aws eks update-kubeconfig --name kf-sm-workshop```
7. Confirm connectivity to EKS by running ```kubectl get nodes -A``` - you should see a list of six nodes.

# What's Next
There are several labs included with this Workshop, including:

* [Kubeflow on EKS](labs/kubeflow/README.md)
* [Kubeflow Pipelines with SageMaker](labs/sagemaker-kubeflow-pipeline/README.md)
* [SageMaker Batch Transform](labs/sagemaker/README.md)
* [SageMaker Multi-Model Endpoints (MME)](labs/sagemaker/README.md)
* [SageMaker Hyper-Parameter Optimization](labs/sagemaker/README.md)
* [SageMaker Operators for Kubernetes](labs/sagemaker-operators-for-k8s/README.md)





