data "aws_vpc" "default" {

  default = true

}

locals {
  http_port = 80
  any_port = 0
  any_protocol = -1
  tcp_protocol = "tcp"
  any_cidr = ["0.0.0.0/0"]
}
data "aws_subnets" default {
filter {
  name = "vpc-id"
  values = [data.aws_vpc.default.id]
}

}

resource "aws_autoscaling_group" "example" {

    max_size                  = var.max_size

    min_size                  = var.min_size

    launch_configuration = aws_launch_configuration.example.name

    vpc_zone_identifier = data.aws_subnets.default.ids

    target_group_arns = [aws_lb_target_group.asg.arn]

    health_check_type = "ELB"

 

    tag {

        key = "${var.cluster_name}-sg"

        value = "terraform-example"

        propagate_at_launch = true

    }
    dynamic "tag" {
      for_each = var.custom_tags
      content {
        key = tag.key
        value = tag.value
        propagate_at_launch = true
      }
      
    }
    instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50 # Keeps at least half the instances up during the change
    }
    triggers = ["launch_configuration"] # Triggers the refresh when the config changes
  }

    lifecycle{

        create_before_destroy = true

    }

}

resource "aws_lb" "example" {

  name               = "${var.cluster_name}-lb"

  load_balancer_type = "application"

  security_groups    = [aws_security_group.lb_sg.id]

  subnets            = data.aws_subnets.default.ids

  tags = {

    Environment = "production"

  }

}

resource "aws_lb_target_group" "asg" {

  name     = "${var.cluster_name}-terraform-asg-example"

  port     = 8080

  protocol = "HTTP"

  vpc_id   = data.aws_vpc.default.id

  health_check {

    path = "/"

    protocol = "HTTP"

    matcher = "200"

    interval = 15

    timeout = 3

    healthy_threshold = 2

  }

}

resource "aws_lb_listener" "http" {

  load_balancer_arn = aws_lb.example.arn

  port              = local.http_port

  protocol          = "HTTP"

 

  default_action {

    type             = "fixed-response"

    fixed_response{

      content_type = "text/plain"

      message_body = "404:page not found"

      status_code = 404

    }

  }

}

resource "aws_lb_listener_rule" "asg" {

  listener_arn = aws_lb_listener.http.arn

  priority     = 100

 

  action {

    type             = "forward"

    target_group_arn = aws_lb_target_group.asg.arn

  }

 

  condition {

    path_pattern {

      values = ["*"]

    }

  }

}

data "terraform_remote_state" "db" {
    backend = "s3"
    config = {
       bucket = var.db_remote_state_bucket
       key = var.db_remote_state_key
       region = "eu-west-1"
    } 
}

resource "aws_launch_configuration" "example" {

    image_id           = "ami-0fe38eb778038c70c"

    instance_type = "${var.instance_type}"

    security_groups = [aws_security_group.instance.id]

    user_data = templatefile("${path.module}/user-data.sh",{
     # db_address = data.terraform_remote_state.db.outputs.address
      #db_port = data.terraform_remote_state.db.outputs.port
    })
}

resource "aws_security_group" "instance" {

  name        = "${var.cluster_name}-example"

  description = "example"

  ingress {

    cidr_blocks   = ["0.0.0.0/0"]

    from_port   = 0

    protocol = "tcp"

    to_port     = 65535

  }

}


resource "aws_security_group" "lb_sg" {

  name        = "${var.cluster_name}-terraform-example-alb"

  description = "example"

}
resource "aws_security_group_rule" "lb_sg_ingress" {
  description = "this is the ingress rules for loadbalancers"
  security_group_id = aws_security_group.lb_sg.id
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]  
}
resource "aws_security_group_rule" "lb_sg_egress" {
  description = "this is the ingress rules for loadbalancers"
  security_group_id = aws_security_group.lb_sg.id
  type = "egress"
  from_port = 0
  to_port = 65535
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]  
}
resource "aws_autoscaling_schedule" "scaleout" {
  count = var.enable_scaling_policy ? 1 : 0
  scheduled_action_name = "${var.cluster_name}- out during business hours"
  min_size = 2
  max_size = 5
  desired_capacity = 2
  recurrence = "0 9 * * *"
  autoscaling_group_name = aws_autoscaling_group.example.name
}