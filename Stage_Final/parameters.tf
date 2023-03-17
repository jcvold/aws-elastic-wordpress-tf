resource "aws_ssm_parameter" "db_name" {
  name        = "/A4L/Wordpress/DBName"
  description = "Wordpress Database Name"
  type        = "String"
  value       = "a4lworpressdb"
}

resource "aws_ssm_parameter" "db_user" {
  name        = "/A4L/Wordpress/DBUser"
  description = "Wordpress User Name"
  type        = "String"
  value       = "a4lwordpressuser"
}

resource "aws_ssm_parameter" "db_endpoint" {
  name        = "/A4L/Wordpress/DBEndpoint"
  description = "Wordpress Database Name"
  type        = "String"
  value       = aws_db_instance.wordpress.endpoint
}

resource "aws_ssm_parameter" "efs_fsid" {
  name        = "/A4L/Wordpress/EFSFSID"
  description = "EFS FS-id number"
  type        = "String"
  value       = aws_efs_file_system.wordpress.id
}

resource "aws_ssm_parameter" "alb_dns_name" {
  name        = "/A4L/Wordpress/ALBDNSNAME"
  description = "ALB DNS Name"
  type        = "String"
  value       = aws_lb.wordpress.dns_name
}

