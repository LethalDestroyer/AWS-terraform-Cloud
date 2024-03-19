provider "aws" {
  region = var.region
}


# Create VPC
resource "aws_vpc" "nginx_vpc" {
  cidr_block = var.vpc_cidr
}

# Create two subnets across multiple AZs
resource "aws_subnet" "nginx_subnet_public" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.nginx_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = var.availability_zones[count.index]
}

resource "aws_subnet" "nginx_subnet_private" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.nginx_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 4)
  availability_zone = var.availability_zones[count.index]
}

# give internet gateway
resource "aws_internet_gateway" "aws_ig" {
  vpc_id = aws_vpc.nginx_vpc.id
}

resource "aws_security_group" "nginx_sg" {
  name        = "nginx-security-group"
  description = "Allow HTTP and SSH access"

  vpc_id = aws_vpc.nginx_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_launch_configuration" "nginx_lc" {
  name_prefix     = "nginx-lc-"
  image_id        = var.ami_id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.nginx_sg.id]
  user_data       = file("${path.module}/userdata.sh")

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "nginx_asg" {
  name                      = "nginx-asg"
  max_size                  = var.instance_count
  min_size                  = var.instance_count
  desired_capacity          = var.instance_count
  vpc_zone_identifier       = tolist(concat(aws_subnet.nginx_subnet_public[*].id, aws_subnet.nginx_subnet_private[*].id))
  launch_configuration      = aws_launch_configuration.nginx_lc.name
  health_check_type         = "EC2"
  health_check_grace_period = 300
  termination_policies      = ["OldestInstance"]
}

resource "aws_elb" "nginx_elb" {
  name            = "nginx-elb"
  subnets         = aws_subnet.nginx_subnet_public[*].id
  security_groups = [aws_security_group.nginx_sg.id]

  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }

  health_check {
    target              = "HTTP:80/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  tags = {
    Name = "nginx_elb"
  }
}

