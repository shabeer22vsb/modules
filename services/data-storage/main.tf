
data "aws_caller_identity" "self" {}
data "aws_secretsmanager_secret_version" "db-creds" {
  secret_id = "db-creds"
}
locals {
  db_creds=jsondecode(
    data.aws_secretsmanager_secret_version.db-creds.secret_string
  )
}

data "aws_iam_policy_document" "cmk_admin_policy"{
  statement {
    sid = "1"
    effect = "Allow"
    resources = ["*"]
    actions = ["kms:*"]
        principals {
          type = "AWS"
          identifiers = [ data.aws_caller_identity.self.arn ]
    }
  }
}
resource "aws_kms_key" "cmk" {
  policy = data.aws_iam_policy_document.cmk_admin_policy.json
}

resource "aws_kms_alias" "cmd" {
  name = "alias/kms-cmk-example"
  target_key_id = aws_kms_key.cmk.id
  
}
resource "aws_db_instance" "example_settled" {
  identifier_prefix = "terraform-up-and-running"
  engine = "mysql"
  username = var.db_username
  password = var.db_password
  allocated_storage = var.allocated_storage
  instance_class = var.db_instance_class
  skip_final_snapshot = var.skip_final_snapshot
  db_name = "example_database"
}