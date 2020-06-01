# Machine Learning Workshop CloudFormation Templates

CloudFormation templates can be used to setup your AWS account (in the event you want to use this environment outside of an Event Engine enabled Immersion Day)

## SageMaker Notebook Instance - The One CFT to Rule Them All

[This CloudFormation template](cft-sagemaker-notebook.yaml) lauches:

- A SageMaker Notebook with kubectl, eksctl, kfctl, and aws-iam-authenticator.
- An EKS Kubernetes Cluster (called kf-sm-workshop) with 6 managed nodes.

**Caveats:**

- This CloudFormation template assumes you have sufficient service limits to create a new VPC and a new EKS Cluster.

## Optional Connect to the EKS cluster from a Different System

**If you do not need/want to connect to the EKS cluster from a different system (e.g. your local workstation), you can move on.**

The following are optional and needed only if you want to connect to the EKS cluster from a different system (other than the SageMaker Notebook). For the KubeFlow lab, you won't need to connect to the EKS cluster from a different system.

### Accessing EKS cluster from a different system.

When the [SageMaker Notebook cloudformation](cft-sagemaker-notebook.yaml) launches an EKS cluster, the only user in the cluster is the Role that created the cluster (in this case, the SageMaker Notebook role). If you want to interact with the cluster from another system (i.e. local workstation), you'll need to add your user to the EKS cluster. Reference: [Add a user to an EKS cluster](https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html).

These are the steps:

#### Step 1 - get your local identity from the system you are trying to connect from

(these instructions assume you have the AWS CLI installed and configured to connect to the AWS Account that has the SageMaker Notebook / EKS Cluster)

At the command line, run this:

```
aws sts get-caller-identity
```

This will return your ARN that looks something like this:

```
arn:aws:iam::123456789012:user/your-user-id
```

In the above, `123456789012` represents your AWS account number and `your-user-id` represents your IAM user.

#### Step 2 - update the EKS configmap Auth settings

From the original SageMaker Notebook instance that launched the EKS cluster, open a Terminal session and run the following command:

```
kubectl edit -n kube-system configmap/aws-auth
```

Underneath the `mapRoles:` section and before the `kind:` section, insert the following.
Notes:

- Adjust the spacing to match the YAML indentation.
- Replace the userarn parameter with the ARN returned from the above command.

```
  mapUsers: |
    - userarn: arn:aws:iam::123456789012:user/your-user-id
      username: admin
      groups:
        - system:masters
```

When you save the configuration, it will update the EKS cluster.

Your final configmap should look something like the following (NOTE: all references have been obfuscated, so DO NOT copy/paste this):

```
# Please edit the object below. Lines beginning with a '#' will be ignored,
# and an empty file will abort the edit. If an error occurs while saving this file will be
# reopened with the relevant failures.
#
apiVersion: v1
data:
  mapRoles: |
    - groups:
      - system:bootstrappers
      - system:nodes
      rolearn: arn:aws:iam::999555999555:role/something-prefixed-nodegroup-n-NodeInstanceRole-ABC123ABC123
      username: system:node:{{EC2PrivateDNSName}}
  mapUsers: |
    - userarn: arn:aws:iam::123456789012:user/your-user-id
      username: admin
      groups:
        - system:masters
kind: ConfigMap
metadata:
  creationTimestamp: "YYYY-MM-DDTHH:MM:SSZ"
  name: aws-auth
  namespace: kube-system
  resourceVersion: "123815"
  selfLink: /api/v1/namespaces/kube-system/configmaps/aws-auth
  uid: long-uid-number
```

Reminder: The `mapUsers:` section is what you'll be adding.

### Step 3: Test Access

(This assumes you have both the AWS CLI and kubectl installed)

From your local workstation (or wherevery you're attempting to connect from), run the following command (replace `your-cluster-name` with the EKS cluster you want to connect to):

```
aws eks update-kubeconfig --name your-cluster-name
```

This will update kube config and set the context.

Run this command to confirm connectivity:

```
kubectl get pods -A
```

You should see a listing of all PODs on the EKS Cluster.
