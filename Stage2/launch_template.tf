resource "aws_launch_template" "wordpress" {
  name = "wordpress"

  credit_specification {
    cpu_credits = "standard"
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.wordpress_profile.name
  }

  image_id = "ami-0cc87e5027adcdca8"

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
}
