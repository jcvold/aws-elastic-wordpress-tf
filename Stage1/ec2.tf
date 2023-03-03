### TODO ###
# data "aws_ami" "ubuntu" {
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   owners = ["099720109477"] # Canonical
# }

resource "aws_instance" "web" {
  ami           = "ami-0cc87e5027adcdca8"
  instance_type = "t2.micro"
  count         = 1
  vpc_security_group_ids = [
    aws_security_group.wordpress_sg.id
  ]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.wordpress_profile.id
  user_data                   = file("init.sh")
  subnet_id                   = aws_subnet.public_subnets.*.id[count.index]
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  tags = {
    Name = "Wordpress-Manual"
  }
}
output "instances" {
  value       = aws_instance.web.*.public_ip
  description = "PublicIP address details"
}
