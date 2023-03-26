data "aws_availability_zones" "available_az" {
}

data "aws_caller_identity" "current" {}

resource "aws_security_group" "ecs" {
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = "${var.public_subnets}"
  }
  tags = {
    "Name" = "${var.name}-${var.environment}-ecs-sg",
    "environment" = "${var.environment}",
    "Region" = "${var.aws_region}",
    "Domain" = "${var.name}",
    "requestor" = "${var.requestor}",
    "customer" = "${var.customer}",
    "tenant" = "${var.tenant}",
    "product" = "${var.product}",
    "manager" = "${var.manager}",
    "owner" = "${var.owner}",
    "purpose" = "${var.purpose}"
  }
}

resource "aws_security_group" "sample-elb" {
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "${var.name}-${var.environment}-lb",
    "environment" = "${var.environment}",
    "Region" = "${var.aws_region}",
    "Domain" = "${var.name}",
    "requestor" = "${var.requestor}",
    "customer" = "${var.customer}",
    "tenant" = "${var.tenant}",
    "product" = "${var.product}",
    "manager" = "${var.manager}",
    "owner" = "${var.owner}",
    "purpose" = "${var.purpose}"
  }
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer" {
  key_name   = "${var.name}-${var.environment}-key"
  public_key = tls_private_key.example.public_key_openssh
}

resource "local_file" "cloud_pem__private" { 
  filename = "${path.module}/${var.name}-${var.environment}-privatekey.pem"
  content = tls_private_key.example.private_key_pem
}

resource "local_file" "cloud_pem_public" { 
  filename = "${path.module}/${var.name}-${var.environment}-publickey.pem"
  content = tls_private_key.example.public_key_openssh
}

resource "aws_secretsmanager_secret" "secretmasterECS" {
  name = "${var.environment}/${var.name}/ECS"
}

resource "aws_secretsmanager_secret_version" "sversion3" {
  secret_id = aws_secretsmanager_secret.secretmasterECS.id
  secret_string = <<EOF
   {
    "PUBLICKEY": "${tls_private_key.example.public_key_openssh}",
    "PRIVATEKEY": "${tls_private_key.example.private_key_pem}"
   }
EOF
}

# Create a basic ALB
resource "aws_alb" "sample-app-alb" {
  name = "${var.name}-${var.environment}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sample-elb.id]
  subnets            = "${var.public_subnet.*.id}"
}

# Create target groups with one health check per group
resource "aws_alb_target_group" "target-group-1" {
  name = "${var.name}-${var.environment}-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id
  target_type = "instance"

  lifecycle { create_before_destroy=true }

  health_check {
    path = "/"
    healthy_threshold = 6
    unhealthy_threshold = 2
    timeout = 2
    interval = 5
    matcher = "200"
  }
}



# Create a Listener
resource "aws_alb_listener" "sample-alb-listener" {
  default_action {
    target_group_arn = "${aws_alb_target_group.target-group-1.arn}"
    type = "forward"
  }
  load_balancer_arn = "${aws_alb.sample-app-alb.arn}"
  port = 80
  protocol = "HTTP"
}

# Create Listener Rules
resource "aws_alb_listener_rule" "rule-1" {
  action {
    target_group_arn = "${aws_alb_target_group.target-group-1.arn}"
    type = "forward"
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }

  listener_arn = "${aws_alb_listener.sample-alb-listener.id}"
  priority = 100
}


data "aws_ami" "sample_ami" {
 most_recent = true


 filter {
   name   = "owner-alias"
   values = ["amazon"]
 }


 filter {
   name   = "name"
   values = ["${var.ecs_base_ami_name}"]
 }
}

resource "aws_iam_role" "sample_role" {
  name = "test_role"

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



resource "aws_iam_instance_profile" "sample_profile" {
  name = "sample_profile"
  role = "${aws_iam_role.sample_role.name}"
}



resource "aws_iam_role_policy" "sample_policy" {
  name = "sample_policy"
  role = "${aws_iam_role.sample_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_launch_configuration" "sample" {
  name_prefix = "${var.name}-${var.environment}-lc"
  image_id = "ami-06046a121f3a4623c"
  instance_type = "${var.ecs_instance_type}"
  iam_instance_profile = aws_iam_instance_profile.sample_profile.name
  root_block_device {
    volume_size = "${var.ecs_volume_size}"
  }
  key_name = aws_key_pair.deployer.key_name
  security_groups = [ "${aws_security_group.ecs.id}" ]
  associate_public_ip_address = false
  user_data     = <<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=sample-dev-ecs-cluster >> /etc/ecs/ecs.config; echo ECS_BACKEND_HOST= >> /etc/ecs/ecs.config
    EOF
  lifecycle {
    create_before_destroy = true
  }
}

# Create an ASG that ties all of this together
resource "aws_autoscaling_group" "sample-alb-asg" {
  name = "${var.name}-${var.environment}-sample-alb-asg"
  min_size = "${var.ecs_min_size}"
  desired_capacity = "${var.ecs_desired_capacity}"
  max_size = "${var.ecs_max_size}"
  launch_configuration = "${aws_launch_configuration.sample.name}"
  termination_policies = [
    "OldestInstance",
    "OldestLaunchConfiguration",
  ]
  
  health_check_type = "ELB"
  tag {
      key                 = "Name"
      value               = "${var.name}-${var.environment}"
      propagate_at_launch = true
    }
  tag {
    key                 = "environment"
    value               = "${var.environment}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Region"
    value               = "${var.aws_region}"
    propagate_at_launch = true
  }
  tag {
    key                 = "Domain"
    value               = "${var.name}"
    propagate_at_launch = true
  }
  tag {
    key                 = "Appname"
    value               = "sample"
    propagate_at_launch = true
  }
  tag {
    key                 = "requestor"
    value               = "${var.requestor}"
    propagate_at_launch = true
  }
  tag {
    key                 = "customer"
    value               = "${var.customer}"
    propagate_at_launch = true
  }
  tag {
    key                 = "tenant"
    value               = "${var.tenant}"
    propagate_at_launch = true
  }
  tag {
    key                 = "product"
    value               = "${var.product}"
    propagate_at_launch = true
  }
  tag {
    key                 = "manager"
    value               = "${var.manager}"
    propagate_at_launch = true
  }
  tag {
    key                 = "owner"
    value               = "${var.owner}"
    propagate_at_launch = true
  }
  tag {
    key                 = "purpose"
    value               = "${var.purpose}"
    propagate_at_launch = true
  }

  depends_on = [
    aws_alb.sample-app-alb,
  ]
  vpc_zone_identifier       = "${var.private_subnet.*.id}"
  target_group_arns = [
    "${aws_alb_target_group.target-group-1.arn}"
  ]

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.name}-${var.environment}-ecs-cluster"
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = "${var.name}-${var.environment}-ecs-task"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
#  cpu                      = 0
  memory                   = 512
  container_definitions    = <<DEFINITION
[
  {
    "name": "${var.name}-${var.environment}-container",
    "image": "514026916061.dkr.ecr.ap-south-1.amazonaws.com/sample-app-repo:latest",
    "memory": 512,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80,
        "protocol": "tcp"
      }
    ]
  }
]
DEFINITION
}

resource "aws_ecs_service" "ecs_service" {
  name            = "${var.name}-${var.environment}-service"
  cluster         = aws_ecs_cluster.ecs_cluster.arn
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count   = 1
  launch_type = "EC2"
  
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent = 100

#  network_configuration {
#    security_groups = [aws_security_group.ecs.id]
#    subnets         = "${var.private_subnet.*.id}"
#  }

  load_balancer {
    target_group_arn = aws_alb_target_group.target-group-1.arn
    container_name   = "${var.name}-${var.environment}-container"
    container_port   = 80
  }
}