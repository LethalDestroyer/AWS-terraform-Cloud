# cloudwatch.tf

# Define CloudWatch dashboard
resource "aws_cloudwatch_dashboard" "nginx_dashboard" {
  dashboard_name = "nginx-dashboard"

  dashboard_body = <<-EOF
    {
      "widgets": [
        {
          "type": "metric",
          "x": 0,
          "y": 0,
          "width": 12,
          "height": 6,
          "properties": {
            "metrics": [
              [ "AWS/EC2", "CPUUtilization", "InstanceId", "i-0f33276a6500186c4" ],
              [ "...", "DiskReadOps", "InstanceId", "i-07be643bf4c6ee2b6" ],
              [ "AWS/ELB", "HealthyHostCount", "LoadBalancerName", "nginx-elb" ]
            ],
            "view": "timeSeries",
            "stacked": false,
            "region": "ap-south-1",
            "title": "Infrastructure Metrics"
          }
        }
      ]
    }
  EOF
}
