# AWS ECS Fargate Provisioning with ALB - Terraform

Simple AWS ECS Cluster provisioning with ALB using Terraform. 

There is also Cloudwatch logs enabled along with Cloudwatch alarms to monitor the ECS Cluster deployments.

For more details on Terraform : https://www.terraform.io/


## What is deployed ?

Things that are deployed as part of [Terraform] :

* VPC - With private and public subnet
* ECS Fargate
* VPC Security Group
* ELB - Application Load Balancer with Security Group configured
* S3 Bucket
* S3 Bucket Policy
* IAM roles for executing ECS Tasks
* EC2 Auto Scaling Group to run desired number of ECS Fargate instances


## Usage

In order to do any changes to the infrastructure you must:

* Init/Plan/Apply

### Init, Plan and Apply changes
```
# Run terraform to initialize, plan (preview the infrastructure) and apply for provisioning.

terraform init

terraform plan

terraform apply

# Finally, destroy all infrastructure using terraform destroy

terraform destroy
```

![AWS-ECS-Fargate-TF](/Aws-ECS-Fargate-diagram.png)





