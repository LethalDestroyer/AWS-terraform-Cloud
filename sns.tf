# sns.tf

# Create SNS topic
resource "aws_sns_topic" "nginx_sns_topic" {
  name = "nginx-sns-topic"
}

# Subscribe email address to SNS topic
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.nginx_sns_topic.arn
  protocol  = "email"
  endpoint  = "shubh.harne13@gmail.com"
}
