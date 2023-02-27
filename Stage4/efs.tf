resource "aws_efs_file_system" "wordpress" {
  creation_token   = "A4L-WORDPRESS-CONTENT"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name = "A4L-WORDPRESS-CONTENT"
  }
}

resource "aws_efs_access_point" "wordpress" {
  file_system_id = aws_efs_file_system.wordpress.id
}

resource "aws_efs_mount_target" "wordpress" {
  file_system_id  = aws_efs_file_system.wordpress.id
  count           = length(aws_subnet.app_private_subnets.*.id)
  subnet_id       = element(aws_subnet.app_private_subnets.*.id, count.index)
  security_groups = [aws_security_group.efs_sg.id]
}
