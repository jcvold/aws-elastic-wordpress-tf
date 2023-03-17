resource "aws_lb" "wordpress" {
  name               = "A4LWORDPRESSALB"
  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "ipv4"
  security_groups    = [aws_security_group.load_balancer_sg.id]
  subnets            = [for subnet in aws_subnet.public_subnets : subnet.id]

  enable_deletion_protection = false
}

resource "aws_lb_listener" "wordpress" {
  load_balancer_arn = aws_lb.wordpress.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress.arn
  }
}

resource "aws_lb_target_group" "wordpress" {
  name             = "A4LWORDPRESSALBTG"
  port             = 80
  protocol         = "HTTP"
  vpc_id           = aws_vpc.main.id
  protocol_version = "HTTP1"
  health_check {
    path     = "/"
    protocol = "HTTP"
  }
}

output "lb-dns" {
  value       = aws_lb.wordpress.dns_name
  description = "Public load balancer DNS name"
}
