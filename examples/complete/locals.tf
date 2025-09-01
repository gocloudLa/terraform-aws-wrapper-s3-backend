locals {

  metadata = {
    aws_region = "us-east-1"
    env        = "Infrastructure"

    key = {
      company = "dmc"
      env     = "inf"
    }
  }

  common_name = join("-", [
    local.metadata.key.company,
    local.metadata.key.env
  ])

  project_name = "tf"
}