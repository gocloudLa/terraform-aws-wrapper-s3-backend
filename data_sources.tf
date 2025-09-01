data "aws_caller_identity" "current" {}

/*----------------------------------------------------------------------*/
/* IAM ROLES                                                            */
/*----------------------------------------------------------------------*/
data "aws_iam_policy_document" "this" {

  for_each = lookup(var.s3_backend_parameters, "name", null) != null && lookup(var.s3_backend_parameters, "name", "") != "" ? var.s3_backend_parameters.aws_accounts : {}

  statement {
    effect = "Allow"
    sid    = "S3ListAccess"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      module.s3_bucket.s3_bucket_arn
    ]
    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values = [
        "${each.value.account_id}/*"
      ]
    }
  }

  statement {
    effect = "Allow"
    sid    = "S3Access"
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "${module.s3_bucket.s3_bucket_arn}/${each.value.account_id}/*"
    ]
  }

  statement {
    effect = "Allow"
    sid    = "DynamoDBAccess"
    actions = [
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:PutItem"
    ]
    resources = [
      "${module.dynamodb_table.dynamodb_table_arn}"
    ]
    condition {
      test     = "ForAllValues:StringLike"
      variable = "dynamodb:LeadingKeys"
      values = [
        "${var.s3_backend_parameters.name}/${each.value.account_id}/*/*.tfstate",
        "${var.s3_backend_parameters.name}/${each.value.account_id}/*/*.tfstate-md5"
      ]
    }
  }
}


resource "aws_iam_policy" "this" {
  for_each = (lookup(var.s3_backend_parameters, "name", null) != null && lookup(var.s3_backend_parameters, "name", "") != "") ? var.s3_backend_parameters.aws_accounts : {}

  name   = "${lookup(var.s3_backend_parameters, "name", null)}-${each.value.account_id}"
  path   = "/"
  policy = data.aws_iam_policy_document.this[each.key].json
}
