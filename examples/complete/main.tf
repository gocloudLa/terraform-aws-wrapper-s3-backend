module "organization_s3_backend" {
  source   = "../.."
  metadata = local.metadata

  s3_backend_parameters = {
    create_bucket = true
    name          = "${local.common_name}-tf-backend"
    aws_accounts = {
      "example-dev" = { account_id = "565219270600" }
      # "example-qa"  = { account_id = "123456789013" }
      # "example-uat"  = { account_id = "123456789014" }
      # "example-prd"  = { account_id = "123456789015" }
    }
  }

  s3_backend_defaults = var.s3_backend_defaults
}