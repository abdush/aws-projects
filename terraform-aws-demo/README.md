# terraform aws getting started
https://developer.hashicorp.com/terraform/tutorials/aws-get-started

## setup

1. create aws account (with access credentials)
   1. access & secret keys (not recommended anymore by AWS)
   2. todo: use aws sso, or short-lived tokens, use tools like aws-vault to store/manage credentials
2. install aws cli
3. install terraform (test simple demo)

## build EC2 instance

## Change instance 
- change EC2 AMI image id. This will require terraform to destroy and create the instance.
- some changes can be done in place (example instance name)

## input variables
- use variables file to pass input to terraform and make configuration more dynamic.
- can also be provided from terraform command line option

## output
- declare outputs to be captured by terraform such as instance id and public ip address

## remote state
- todo: create account and run/store state remotely
