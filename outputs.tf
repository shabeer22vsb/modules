output "Loadbalancer_name" {
  description = "name of the loadbalancer"
  value = aws_lb.example.dns_name
}
output "asg_name"{
    description = "arn of the asg"
    value = aws_autoscaling_group.example.name
    }