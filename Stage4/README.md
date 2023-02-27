# Aws-elastic-wordpress-tf - Stage4

Source: [https://github.com/acantril/learn-cantrill-io-labs/blob/master/aws-elastic-wordpress-evolution/02_LABINSTRUCTIONS/STAGE4%20-%20Add%20EFS%20and%20Update%20the%20LT.md](https://github.com/acantril/learn-cantrill-io-labs/blob/master/aws-elastic-wordpress-evolution/02_LABINSTRUCTIONS/STAGE4%20-%20Add%20EFS%20and%20Update%20the%20LT.md)

This folder includes the updated Terraform files for **Stage4** of the project.

Step 4E is handled by editing the `init.sh` file instead of the launch template.

**Note: Each time you destroy, than re-apply the efs module, you must edit the `/A4L/Wordpress/EFSFSID` efs id parameter in SSM.**