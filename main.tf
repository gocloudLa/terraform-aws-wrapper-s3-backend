module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.8.2"

  create_bucket           = lookup(var.s3_backend_parameters, "name", null) != null && lookup(var.s3_backend_parameters, "name", "") != ""
  bucket                  = lookup(var.s3_backend_parameters, "name", null) != null && lookup(var.s3_backend_parameters, "name", "") != "" ? lookup(var.s3_backend_parameters, "name", null) : null
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  object_ownership        = "BucketOwnerEnforced"
  versioning              = { enabled = true }

  tags = merge(local.common_tags, try(var.s3_backend_parameters.tags, var.s3_backend_defaults.tags, null))
}

module "dynamodb_table" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "5.2.0"

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

  tags = merge(local.common_tags, try(var.s3_backend_parameters.tags, var.s3_backend_defaults.tags, null))
}

module "iam_assumable_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "6.2.3"

  for_each = lookup(var.s3_backend_parameters, "name", null) != null && lookup(var.s3_backend_parameters, "name", "") != "" ? var.s3_backend_parameters.aws_accounts : {}

  trust_policy_permissions = {
    AllowAssumeRole = {
      actions = [
        "sts:AssumeRole",
        "sts:TagSession",
      ]
      principals = [{
        type        = "AWS"
        identifiers = ["arn:aws:iam::${each.value.account_id}:root"]
      }]
    }
  }
  create_instance_profile = false
  max_session_duration    = 3600
  create                  = true
  use_name_prefix         = false
  name                    = "${lookup(var.s3_backend_parameters, "name", null)}-${each.value.account_id}"
  policies = {
    custom = aws_iam_policy.this[each.key].arn
  }

  tags = merge(local.common_tags, try(var.s3_backend_parameters.tags, var.s3_backend_defaults.tags, null))
}