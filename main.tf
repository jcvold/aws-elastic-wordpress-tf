resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "A4LVPC"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "A4L-IGW"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "A4L Public Route Table"
  }
}

resource "aws_route_table_association" "public_subnet_asso" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "Public Subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "app_private_subnets" {
  count             = length(var.app_private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.app_private_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "App Private Subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "db_private_subnets" {
  count             = length(var.db_private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.db_private_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "DB Private Subnet ${count.index + 1}"
  }
}

resource "aws_security_group" "wordpress_sg" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "database_sg" {
  name        = "allow_mysql"
  description = "Allow mysql inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.wordpress_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "load_balancer_sg" {
  name        = "allow_lb_http"
  description = "Allow http inbound traffic to load balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "efs_sg" {
  name        = "allow_efs"
  description = "Allow efs inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.wordpress_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "wordpress" {
  name = "wordpress-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "wordpress_profile" {
  name = "wordpress_instance_profile"
  role = aws_iam_role.wordpress.id
}

resource "aws_iam_role_policy_attachment" "attachment" {
  for_each = toset([
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::aws:policy/AmazonSSMFullAccess",
    "arn:aws:iam::aws:policy/AmazonElasticFileSystemClientFullAccess"
  ])

  role       = aws_iam_role.wordpress.name
  policy_arn = each.value
}

resource "aws_ssm_parameter" "cw_agent_config" {
  name = "CWAgentConfig"
  type = "String"
  value = jsonencode({
    "agent" : {
      "metrics_collection_interval" : 60,
      "run_as_user" : "root"
    },
    "logs" : {
      "logs_collected" : {
        "files" : {
          "collect_list" : [
            {
              "file_path" : "/var/log/secure",
              "log_group_name" : "/var/log/secure",
              "log_stream_name" : "{instance_id}"
            },
            {
              "file_path" : "/var/log/httpd/access_log",
              "log_group_name" : "/var/log/httpd/access_log",
              "log_stream_name" : "{instance_id}"
            },
            {
              "file_path" : "/var/log/httpd/error_log",
              "log_group_name" : "/var/log/httpd/error_log",
              "log_stream_name" : "{instance_id}"
            }
          ]
        }
      }
    },
    "metrics" : {
      "append_dimensions" : {
        "AutoScalingGroupName" : "$${aws:AutoScalingGroupName}",
        "ImageId" : "$${aws:ImageId}",
        "InstanceId" : "$${aws:InstanceId}",
        "InstanceType" : "$${aws:InstanceType}"
      },
      "metrics_collected" : {
        "collectd" : {
          "metrics_aggregation_interval" : 60
        },
        "cpu" : {
          "measurement" : [
            "cpu_usage_idle",
            "cpu_usage_iowait",
            "cpu_usage_user",
            "cpu_usage_system"
          ],
          "metrics_collection_interval" : 60,
          "resources" : [
            "*"
          ],
          "totalcpu" : false
        },
        "disk" : {
          "measurement" : [
            "used_percent",
            "inodes_free"
          ],
          "metrics_collection_interval" : 60,
          "resources" : [
            "*"
          ]
        },
        "diskio" : {
          "measurement" : [
            "io_time",
            "write_bytes",
            "read_bytes",
            "writes",
            "reads"
          ],
          "metrics_collection_interval" : 60,
          "resources" : [
            "*"
          ]
        },
        "mem" : {
          "measurement" : [
            "mem_used_percent"
          ],
          "metrics_collection_interval" : 60
        },
        "netstat" : {
          "measurement" : [
            "tcp_established",
            "tcp_time_wait"
          ],
          "metrics_collection_interval" : 60
        },
        "statsd" : {
          "metrics_aggregation_interval" : 60,
          "metrics_collection_interval" : 10,
          "service_address" : ":8125"
        },
        "swap" : {
          "measurement" : [
            "swap_used_percent"
          ],
          "metrics_collection_interval" : 60
        }
      }
    }
  })
}
