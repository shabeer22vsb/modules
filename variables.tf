variable "cluster_name" {
  description = "name of cluster"
  type = string
  default = "staging"
}
variable "db_remote_state_bucket" {
    description = "name of terraform state bucket"
    type = string
    default = "my-tf-practical-bucket-166373406634-eu-west-1-an"
}
variable "custom_tags" {
    description = "this is custom tags for ASG"
    type = map(string)
    default = {
      "project" = "aom"
      "country" = "uk"
      "location" = "newbury"
    }
  
}
variable "db_remote_state_key" {
    description = "name of terraform state bucket key"
    type = string
    default = "stage/data-stores/mysql/terraform.tfstate"
}
variable "instance_type" {
    description = "instance type for ASG"
    type = string
    default = "t3.micro"
}
variable "min_size"{
    description = "number of minimum instances in ASG"
    default = 1
}
variable "max_size"{
    description = "number of maximum instances in ASG"
    default = 1
}
variable "enable_scaling_policy"{
  description = "enable disable scaling policy"
  type = bool
}