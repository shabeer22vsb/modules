resource "aws_iam_user" "console_users" {
    for_each = toset(var.users)
    name = each.value
}
