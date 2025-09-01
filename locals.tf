locals {

  metadata = var.metadata

  # common_name = join("-", [
  #   local.metadata.key.company,
  #   local.metadata.key.env
  # ])

  project_name = "tf"

  common_tags = {
    "company"     = local.metadata.key.company
    "provisioner" = "terraform"
    # "environment" = local.metadata.env
    "created-by" = "GoCloud.la"
  }
}