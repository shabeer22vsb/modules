variable "db_username" {
    description = "Username to login DB"
    type = string
    sensitive = true
}
variable "db_password" {
    description = "password to login DB"
    type = string
    sensitive = true
}
variable "db_instance_class"{
    description = "DB instance type"
    type = string
    default = "db.t3.micro"
}
variable "allocated_storage" {
    description = "DB storage size"
    type = number
    default = 10
}
variable "skip_final_snapshot" {
    description = "need to skip final snapshor or not"
    type = bool
    default = true
}
variable "backup_retention_period" {
  description = "Number of days to retain backup. Must be > 0 to enable replication"
  type = number
  default = null
}
variable "replicate_source_db" {
  description = "if specified repliate at source DB ARN"
  type = string
  default = "null"
}
variable "db_name" {
  description = "name of the DB"
  type = string
  default = "null"
}