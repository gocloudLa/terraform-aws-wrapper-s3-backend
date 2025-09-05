locals {

  metadata = {
    aws_region     = "us-east-1"
    environment    = "Infrastructure"
    public_domain  = "democorp.cloud"
    private_domain = "democorp"

    key = {
      company = "dmc"
      region  = "use1"
      env     = "sha"
      layer   = "organization"
    }
  }

  common_name = join("-", [
    local.metadata.key.company,
    local.metadata.key.env
  ])

}