# Learn Terraform Resources

This repo is a companion repo to the [Define Infrastructure with Terraform Resources Learn guide](https://learn.hashicorp.com/tutorials/terraform/resource), containing Terraform configuration files to provision two publicly EC2 instances and an ELB.
 df -T
 to mount, follow the scripts in script.tpl
 ssh -i ssh_key.pem ec2-user@ec2-3-125-48-46.eu-central-1.compute.amazonaws.com
get last ami for aws:
aws ssm get-parameters --names /aws/service/ecs/optimized-ami/amazon-linux-2/recommended