# TERRAFORM

# Prerequisites
- Terraform CLI
- AWS CLI

# How to
Terraform lifecycle 

Make sure to update provider.tf for profile
```sh
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply --auto-apply
terraform destroy --auto-apply
```sh

Validate access using ssh
```sh
ssh-add -K main-key.pem
ssh-add -l # to verify
ssh -A <public ip address (or dns) of public ec2 instance>
once logged in to public ec2 instance, login to private ec2
ssh <private ec2 instance private ip>
aws s3 ls
aws s3 ls s3://<s3 bucket name> # to list the content of the bucket
```sh
