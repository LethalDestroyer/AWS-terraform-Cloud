# alarms.tf

# Define CloudWatch alarms
resource "aws_cloudwatch_metric_alarm" "nginx_cpu_alarm" {
  alarm_name          = "nginx-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alarm when CPU exceeds 80%"
  alarm_actions       = ["arn:aws:sns:ap-south-1:381492000626:nginx-sns-topic"]
}

resource "aws_cloudwatch_metric_alarm" "nginx_5xx_error_alarm" {
  alarm_name          = "nginx-5xx-error-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ELB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "Alarm when 5xx errors exceed 10"
  alarm_actions       = ["arn:aws:sns:ap-south-1:381492000626:nginx-sns-topic"]
}
