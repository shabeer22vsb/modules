output "address" {
    description = "connect to DB using this endpoint"
    value = aws_db_instance.example_settled.address
}
output "port" {
    description = "connect  port using this endpoint"
    value = aws_db_instance.example_settled.port
}
output "arn" {
  description = "ARN of the RDS instance"
  value = aws_db_instance.example_settled.arn
}