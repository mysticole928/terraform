# Create an EKS Cluster using Terraform

These Terraform files create a VPC in a designated region and deploy a single EKS cluster with one or more nodes without using `eksctl`.  

`eksctl` is an open source CLI tool created by Waveworks in partnership with AWS to manage EKS clusters.  It was written in `Go` and uses `CloudFormation` to create clusters.  In 2024, Waveworks went out of business and AWS took over `eksctl` development.  

The settings are in `terraform.tfvars`.  Modify them as needed.

The only external requirement is an existing SSH Key in the deployment region.
