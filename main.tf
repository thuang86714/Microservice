terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.52.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }
  required_version = ">= 1.1.0"

  backend "remote" {
    organization = "Tommys-Private-Projects"

    workspaces {
      name = "GitHub-Actions"
    }
  }
}


provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "available" {}

resource "aws_security_group" "instance" {
  name = "go-api-instance"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "example" {
  image_id      = "ami-58d7e821"
  instance_type = "t2.micro"

  security_groups = ["${aws_security_group.instance.id}"]

  user_data = <<-EOF
                #!/bin/bash
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
                sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
                sudo apt-get update
                apt-cache policy docker-ce
                sudo apt-get install -y docker-ce
                sudo docker pull forbsey/go-docker:first
                sudo docker run -d -p 8080:8080 tommyhuanghhh/microservice:lastest
                EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  launch_configuration = "${aws_launch_configuration.example.id}"
  load_balancers       = ["${aws_elb.example.name}"]
  availability_zones   = ["us-east-1b", "us-east-1a"]
  min_size             = 2
  max_size             = 5

  tag {
    key                 = "Name"
    value               = "terraform-go-api"
    propagate_at_launch = true
  }
}




resource "aws_security_group" "elb" {
  name = "terraform-go-api"

  ingress {
    from_port   = 8080
    to_port     = 8080
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

resource "aws_elb" "example" {
  name               = "terraform-go-api"
  availability_zones = ["us-east-1b", "us-east-1a"]
  security_groups    = ["${aws_security_group.elb.id}"]

  listener {
    lb_port           = 8080
    lb_protocol       = "http"
    instance_port     = 8080
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:8080/"
  }
}

output "elb_dns_name" {
  value = "${aws_elb.example.dns_name}"
}