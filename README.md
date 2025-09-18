# Standard Platform - Terraform Module 🚀🚀
<p align="right"><a href="https://partners.amazonaws.com/partners/0018a00001hHve4AAC/GoCloud"><img src="https://img.shields.io/badge/AWS%20Partner-Advanced-orange?style=for-the-badge&logo=amazonaws&logoColor=white" alt="AWS Partner"/></a><a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-green?style=for-the-badge&logo=apache&logoColor=white" alt="LICENSE"/></a></p>

Welcome to the Standard Platform — a suite of reusable and production-ready Terraform modules purpose-built for AWS environments.
Each module encapsulates best practices, security configurations, and sensible defaults to simplify and standardize infrastructure provisioning across projects.

## 📦 Module: Terraform S3 DynamoDB IAM State Management Module
<p align="right"><a href="https://github.com/gocloudLa/terraform-aws-wrapper-s3-backend/releases/latest"><img src="https://img.shields.io/github/v/release/gocloudLa/terraform-aws-wrapper-s3-backend.svg?style=for-the-badge" alt="Latest Release"/></a><a href=""><img src="https://img.shields.io/github/last-commit/gocloudLa/terraform-aws-wrapper-s3-backend.svg?style=for-the-badge" alt="Last Commit"/></a><a href="https://registry.terraform.io/modules/gocloudLa/wrapper-s3-backend/aws"><img src="https://img.shields.io/badge/Terraform-Registry-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform Registry"/></a></p>
This folder contains the necessary resources to implement a Terraform state backend to manage the Terraform state in a centralized way and avoid conflicts in multi-user environments. The module creates an S3 bucket to store the Terraform state, a DynamoDB table for state locking, and specific IAM policies for each account.

### ✨ Features



### 🔗 External Modules
| Name | Version |
|------|------:|
| <a href="https://github.com/terraform-aws-modules/terraform-aws-dynamodb-table" target="_blank">terraform-aws-modules/dynamodb-table/aws</a> | 5.1.0 |
| <a href="https://github.com/terraform-aws-modules/terraform-aws-iam" target="_blank">terraform-aws-modules/iam/aws</a> | 6.2.1 |
| <a href="https://github.com/terraform-aws-modules/terraform-aws-s3-bucket" target="_blank">terraform-aws-modules/s3-bucket/aws</a> | 5.7.0 |



## 🚀 Quick Start
```hcl
s3_backend_parameters = {
    create_bucket = true
    name          = "${local.common_name}-tf-backend"
    aws_accounts = {
      "EXAMPLE-DEV" = { account_id = "123456789012" }
      # "EXAMPLE-QA"  = { account_id = "123456789013" }
      # "EXAMPLE-UAT"  = { account_id = "123456789014" }
      # "EXAMPLE-PRD"  = { account_id = "123456789015" }
    }
  }
```
<details>
<summary><strong>Complete Setup Guide 🚀🚀</strong></summary>

  This guide walks you through setting up a centralized Terraform state management solution using S3 and DynamoDB for state locking. Follow these steps to implement the backend infrastructure for your organization.

  **Step 1: Infrastructure Account Setup (Optional)**

  First, deploy your infrastructure account (Shared) with the following configuration:

  ```hcl
  organizational_units = {
    "Infrastructure" = {
      ou_policies = {
        "tag-convention"      = {}
        "aws-backup-deletion" = {}
        "governance"          = {}
        "compliance"          = {}
      }
    }
  }
  accounts = {
    "${local.metadata.public_domain}-sha" = {
      email                             = "username+${local.metadata.public_domain}-sha@gmail.com",
      parent_id                         = "Infrastructure",
      allow_iam_users_access_to_billing = true
    }
  }
  ```

  **Step 2: Configure S3 Backend Parameters**

  Add the S3 backend configuration block to your Terraform configuration:

  ```hcl
  s3_backend_parameters = {
    name = "${local.common_name}-tf-backend"
    aws_accounts = {
      "root" = { account_id = "XXXXXXXXXXXX" }
      "dev"  = { account_id = "XXXXXXXXXXXX" }
      # Add additional accounts as needed
    }
  }
  ```

  **Step 3: Migrate Initial State to S3 (Optional)**

  After running `terraform apply` in Step 2 and creating the S3 backend infrastructure, if you have an existing local state file, you need to migrate it to S3. This is typically done for the first workspace that creates the backend infrastructure.

  **3.1: Configure Backend for Initial State Migration**

  Add the following backend configuration block to your Terraform configuration. Replace `XXXXXXX` with the account ID where you're currently running Terraform and `YYYYYYYYYY` with the shared account ID where the bucket is deployed:

  ```hcl
  terraform {
    backend "s3" {
      bucket         = "${local.common_name}-tf-backend"
      key            = "XXXXXXX/organization/terraform.tfstate"
      region         = "us-east-2"
      dynamodb_table = "${local.common_name}-tf-backend"
      encrypt        = true
      assume_role = {
        role_arn = "arn:aws:iam::YYYYYYYYYY:role/${local.common_name}-tf-backend-XXXXXXX"
      }
    }
  }
  ```

  **3.2: Initialize and Migrate State**

  Run the following commands to initialize the backend and migrate your local state to S3:

  ```bash
  terraform init
  ```

  When prompted, type `yes` to copy the existing state to the new backend:

  ```
  Do you want to copy existing state to the new backend?
    Pre-existing state was found while migrating the previous "local" backend to the
    newly configured "s3" backend. No existing state was found in the newly
    configured "s3" backend. Do you want to copy this state to the new "s3"
    backend? Enter "yes" to copy and "no" to start with an empty state.

    Enter a value: yes
  ```

  **3.3: Verify State Migration**

  After successful migration, verify that your state is now stored in S3:

  ```bash
  terraform state list
  ```

  **Step 4: Configure Terraform Backend for Additional Workspaces**

  For each environment, configure the Terraform backend by adding the following block. Replace `XXXXXXX` with the account ID where resources are created and `YYYYYYYYYY` with the shared account ID where the bucket is deployed:

  ```hcl
  terraform {
    backend "s3" {
      bucket         = "${local.common_name}-tf-backend"
      key            = "XXXXXXX/organization/terraform.tfstate"
      region         = "us-east-2"
      dynamodb_table = "${local.common_name}-tf-backend"
      encrypt        = true
      assume_role = {
        role_arn = "arn:aws:iam::YYYYYYYYYY:role/${local.common_name}-tf-backend-XXXXXXX"
      }
    }
  }
  ```

  **Step 5: Configure Secrets Management (Optional)**

  If you need to manage sensitive variables, create a `_secrets.tf` file:

  ```hcl
  data "aws_ssm_parameter" "terraform" {
    name = "/terraform/${local.common_name}-project"
  }

  locals {
    secrets = jsondecode(data.aws_ssm_parameter.terraform.value)
  }
  ```

  **Environment-Specific Parameters:**

  | Environment   | Parameter Path                                    |
  | :------------ | :------------------------------------------------ |
  | base          | `"/terraform/${local.common_name}-base"`          |
  | foundation    | `"/terraform/${local.common_name}-foundation"`    |
  | organization  | `"/terraform/${local.common_name}-organization"`  |
  | project       | `"/terraform/${local.common_name}-project"`       |
  | workload      | `"/terraform/${local.common_name}-workload"`      |

  **Important:** Parameters must be manually created in the AWS account where resources are deployed. Maintain the standard tagging convention and use the following JSON format:

  ```json
  {
    "key1": "value1",
    "key2": "value2"
  }
  ```

  **⚠️ Critical:** Ensure each value (except the last one) is followed by a comma to separate it from the next entry, otherwise you'll encounter parsing errors.

  **Step 6: Initialize and Plan**

  Run the following commands to initialize your Terraform configuration and create an execution plan:

  ```bash 
  terraform init
  terraform plan
  ```
</details>


## 🔧 Additional Features Usage



## 📑 Inputs
| Name                    | Description                                            | Type     | Default                                                      | Required |
| ----------------------- | ------------------------------------------------------ | -------- | ------------------------------------------------------------ | -------- |
| create_bucket           | Whether to create the S3 bucket                        | `bool`   | `true`                                                       | no       |
| bucket                  | Bucket name for the S3 instance                        | `string` | `"${local.common_name}-${local.project_name}-state"`         | no       |
| attach_policy           | Whether to attach a policy to the bucket               | `bool`   | `true`                                                       | no       |
| policy                  | IAM policy document to be attached to the bucket       | `string` | `data.aws_iam_policy_document.this.json`                     | no       |
| create_table            | Whether to create the DynamoDB table                   | `bool`   | `true`                                                       | no       |
| name                    | Name of the DynamoDB table                             | `string` | `"${local.common_name}-${local.project_name}-lock"`          | no       |
| trusted_role_arns       | ARNs of trusted roles for the IAM role                 | `list`   | `["arn:aws:iam::${each.value.account_id}:root"]`             | no       |
| role_name               | Name of the IAM role to be created                     | `string` | `"${local.common_name}-s3-backend-${each.value.account_id}"` | no       |
| custom_role_policy_arns | ARNs of custom role policies to attach to the IAM role | `list`   | `[aws_iam_policy.this[each.key].arn]`                        | no       |
| tags                    | A map of tags to assign to resources.                  | `map`    | `{}`                                                         | no       |







## ⚠️ Important Notes
<details>
<summary><strong>UPGRADE v1.1.0</strong></summary>
  
  **Important:** This version introduces changes to the IAM role policy attachment resource structure that requires a Terraform apply with additional configuration.
  
  **Required Action:** Add the following `moved` blocks to your Terraform configuration to handle the resource migration:
  
  ```hcl
  moved {
    from = module.organization_s3_backend.module.wrapper_s3_backend.module.iam_assumable_role["EXAMPLE-DEV"].aws_iam_role_policy_attachment.custom[0]
    to   = module.organization_s3_backend.module.wrapper_s3_backend.module.iam_assumable_role["EXAMPLE-DEV"].aws_iam_role_policy_attachment.this["custom"]
  }
  
  moved {
    from = module.organization_s3_backend.module.wrapper_s3_backend.module.iam_assumable_role["EXAMPLE-QA"].aws_iam_role_policy_attachment.custom[0]
    to   = module.organization_s3_backend.module.wrapper_s3_backend.module.iam_assumable_role["EXAMPLE-QA"].aws_iam_role_policy_attachment.this["custom"]
  }
  ```
  
  **Note:** Replace `"EXAMPLE-DEV"` and `"EXAMPLE-QA"` with your actual account identifiers as defined in your `aws_accounts` configuration.
  
  **Steps to upgrade:**
  1. Add the appropriate `moved` blocks to your configuration
  2. Run `terraform plan` to verify the changes
  3. Run `terraform apply` to complete the migration
  4. Remove the `moved` blocks after successful migration
  
  This ensures a smooth transition without destroying and recreating IAM role policy attachments.
</details>



---

## 🤝 Contributing
We welcome contributions! Please see our contributing guidelines for more details.

## 🆘 Support
- 📧 **Email**: info@gocloud.la

## 🧑‍💻 About
We are focused on Cloud Engineering, DevOps, and Infrastructure as Code.
We specialize in helping companies design, implement, and operate secure and scalable cloud-native platforms.
- 🌎 [www.gocloud.la](https://www.gocloud.la)
- ☁️ AWS Advanced Partner (Terraform, DevOps, GenAI)
- 📫 Contact: info@gocloud.la

## 📄 License
This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details. 