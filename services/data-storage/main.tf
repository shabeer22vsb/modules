provider "aws" {
    region = "eu-west-1"
}
resource "aws_db_instance" "example_settled" {
  identifier_prefix = "terraform-up-and-running"
  engine = "mysql"
  allocated_storage = var.allocated_storage
  instance_class = var.db_instance_class
  skip_final_snapshot = var.skip_final_snapshot
  db_name = "example_database"

  username = var.db_username
  password = var.db_password
}
terraform {
  backend "s3" {
    bucket       = "my-tf-practical-bucket-166373406634-eu-west-1-an"
    key          = "modules/data-stores/mysql/terraform.tfstate"
    use_lockfile = true
    region       = "eu-west-1"
  }
}