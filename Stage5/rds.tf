resource "aws_db_subnet_group" "wordpress" {
  name = "wordpress-rds-subnet-group"

  subnet_ids = flatten([aws_subnet.db_private_subnets.*.id])

  tags = {
    Name = "A4L - db subnet group"
  }
}

data "aws_ssm_parameter" "db_user" {
  name = "/A4L/Wordpress/DBUser"
}

data "aws_ssm_parameter" "db_password" {
  name = "/A4L/Wordpress/DBPassword"
}

data "aws_ssm_parameter" "db_name" {
  name = "/A4L/Wordpress/DBName"
}
resource "aws_db_instance" "wordpress" {
  identifier             = "a4lwordpress"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "mysql"
  engine_version         = "8.0.28"
  username               = data.aws_ssm_parameter.db_user.value
  password               = data.aws_ssm_parameter.db_password.value
  db_name                = data.aws_ssm_parameter.db_name.value
  db_subnet_group_name   = aws_db_subnet_group.wordpress.name
  vpc_security_group_ids = [aws_security_group.database_sg.id]
  publicly_accessible    = false
  skip_final_snapshot    = true
}
