resource "aws_autoscaling_group" "wordpress" {
  min_size         = 1
  max_size         = 3
  desired_capacity = 1
  launch_template {
    id      = aws_launch_template.wordpress.id
    version = "$Latest"
  }
  vpc_zone_identifier   = aws_subnet.public_subnets[*].id
  target_group_arns     = [aws_lb_target_group.wordpress.id]
  protect_from_scale_in = false

  tag {
    key                 = "Name"
    value               = "Wordpress-ASG"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "wordpress_scale_up"
  autoscaling_group_name = aws_autoscaling_group.wordpress.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 120
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "wordpress_scale_down"
  autoscaling_group_name = aws_autoscaling_group.wordpress.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 120
}

resource "aws_cloudwatch_metric_alarm" "wordpress_cpu_alarm_up" {
  alarm_name          = "wordpress_cpu_alarm_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "60"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.wordpress.name
  }

  alarm_description = "This metric will monitor EC2 instance CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.scale_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "wordpress_cpu_alarm_down" {
  alarm_name          = "wordpress_cpu_alarm_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "40"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.wordpress.name
  }

  alarm_description = "This metric will monitor EC2 instance CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.scale_down.arn]
}
