resource "aws_instance" "web" {
  launch_template {
    id = aws_launch_template.wordpress.id
  }
  count = 1
}
output "instances" {
  value       = aws_instance.web.*.public_ip
  description = "PublicIP address details"
}
