module "s3_bucket" {
  source   = "../.."
  metadata = local.metadata

  s3_backend_parameters = {
    create_bucket = true
    name          = "${local.common_name}-${local.project_name}-state"
    aws_accounts = {
      "EXAMPLE-DEV" = { account_id = "565219270600" }
      # "EXAMPLE-QA"  = { account_id = "123456789013" }
      # "EXAMPLE-UAT"  = { account_id = "123456789014" }
      # "EXAMPLE-PRD"  = { account_id = "123456789015" }
    }
  }

  s3_backend_defaults = var.s3_backend_defaults
}