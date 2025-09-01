module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.2.0"

  create_bucket           = lookup(var.s3_backend_parameters, "name", null) != null && lookup(var.s3_backend_parameters, "name", "") != ""
  bucket                  = lookup(var.s3_backend_parameters, "name", null) != null && lookup(var.s3_backend_parameters, "name", "") != "" ? lookup(var.s3_backend_parameters, "name", null) : null
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  object_ownership        = "BucketOwnerEnforced"
  versioning              = { enabled = true }

  tags = local.common_tags
}

module "dynamodb_table" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "5.0.0"

  create_table = lookup(var.s3_backend_parameters, "name", null) != null && lookup(var.s3_backend_parameters, "name", "") != ""
  name         = lookup(var.s3_backend_parameters, "name", null) != null && lookup(var.s3_backend_parameters, "name", "") != "" ? lookup(var.s3_backend_parameters, "name", null) : null
  hash_key     = "LockID"
  table_class  = "STANDARD"
  attributes = [
    {
      name = "LockID"
      type = "S"
    }
  ]

  tags = local.common_tags
}

module "iam_assumable_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.59.0"

  for_each = lookup(var.s3_backend_parameters, "name", null) != null && lookup(var.s3_backend_parameters, "name", "") != "" ? var.s3_backend_parameters.aws_accounts : {}

  trusted_role_arns = [
    "arn:aws:iam::${each.value.account_id}:root"
  ]
  create_instance_profile = false
  max_session_duration    = 3600
  create_role             = true
  role_name               = "${lookup(var.s3_backend_parameters, "name", null)}-${each.value.account_id}"
  role_requires_mfa       = false
  custom_role_policy_arns = [
    aws_iam_policy.this[each.key].arn
  ]

  tags = local.common_tags
}