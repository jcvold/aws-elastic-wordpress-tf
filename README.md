# Aws-elastic-wordpress-tf

Source: [https://github.com/acantril/learn-cantrill-io-labs/tree/master/aws-elastic-wordpress-evolution](https://github.com/acantril/learn-cantrill-io-labs/tree/master/aws-elastic-wordpress-evolution)

Implementing the lessons via Terraform instead of manually in the AWS console.

 The [A4LVPC](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://learn-cantrill-labs.s3.amazonaws.com/aws-elastic-wordpress-evolution/A4LVPC.yaml&stackName=A4LVPC)  cloudformation stack file has been converted to Terraform (in Stage1).

The `A4LVPC.yaml` file is included for reference only and is not actually used in this project.

There are a few changes from the source instructions for my own setup. These can mostly be found in the `variables.tf` file. I use us-east-2 instead of us-east-1, and my subnet CIDRs are slightly different.

## Installation

Navigate to the desired **Stage** folder and run:

```bash
terraform init
```

## Usage

```terraform
# In each directory run the following:

# check formatting
terraform fmt

# check what will be created/destroyed
terraform plan

# commit changes to infrastructure
terraform apply

# remove changes to infrastructure
terraform destroy
```

## License

[MIT](https://choosealicense.com/licenses/mit/)