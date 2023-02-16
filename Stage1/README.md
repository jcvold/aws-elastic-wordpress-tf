# Aws-elastic-wordpress-tf - Stage1

Source: [https://github.com/acantril/learn-cantrill-io-labs/blob/master/aws-elastic-wordpress-evolution/02_LABINSTRUCTIONS/STAGE1%20-%20Setup%20and%20Manual%20wordpress%20build.md](https://github.com/acantril/learn-cantrill-io-labs/blob/master/aws-elastic-wordpress-evolution/02_LABINSTRUCTIONS/STAGE1%20-%20Setup%20and%20Manual%20wordpress%20build.md)

This folder includes the necessary Terraform files to setup and complete **Stage1** of the project.

The only manual steps needed are in [STAGE 1B - Create SSM Parameter Store values for wordpress](https://github.com/acantril/learn-cantrill-io-labs/blob/master/aws-elastic-wordpress-evolution/02_LABINSTRUCTIONS/STAGE1%20-%20Setup%20and%20Manual%20wordpress%20build.md#stage-1b---create-ssm-parameter-store-values-for-wordpress) where you have to set the database info into the SSM Parameter Store.

Steps _STAGE 1A - Login to an AWS Account_, _STAGE 1B - Create an EC2 Instance to run wordpress_, and _STAGE 1C - Connect to the instance and install a database and wordpress_ are automated via the included Terraform files.