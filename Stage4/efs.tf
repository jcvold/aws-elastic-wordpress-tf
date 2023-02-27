resource "aws_efs_file_system" "wordpress" {
  creation_token   = "A4L-WORDPRESS-CONTENT"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  tags = {
    Name = "A4L-WORDPRESS-CONTENT"
  }
}

