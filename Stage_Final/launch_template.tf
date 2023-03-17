resource "aws_launch_template" "wordpress" {
  name = "wordpress"

  credit_specification {
    cpu_credits = "standard"
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.wordpress_profile.name
  }

  image_id = data.aws_ssm_parameter.aws-amzn2-linux-ami.value

  instance_initiated_shutdown_behavior = "terminate"

  instance_type = "t2.micro"

  monitoring {
    enabled = false
  }

  network_interfaces {
    associate_public_ip_address = true
    subnet_id                   = aws_subnet.public_subnets.*.id[0]
    security_groups             = [aws_security_group.wordpress_sg.id]
  }

  user_data = filebase64("init.sh")

  update_default_version = true

  tags = {
    Name = "Wordpress-LG"
  }

  depends_on = [
    aws_ssm_parameter.db_endpoint,
    aws_ssm_parameter.db_name,
    aws_ssm_parameter.db_user,
    aws_ssm_parameter.efs_fsid,
    aws_ssm_parameter.alb_dns_name
  ]
}

data "aws_ssm_parameter" "aws-amzn2-linux-ami" {
  # Returns the latest Amazon Linux 2 ami  
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}
