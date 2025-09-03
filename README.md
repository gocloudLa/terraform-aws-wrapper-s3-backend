# Standard Platform - Terraform Module 🚀🚀
<p align="right"><a href="https://partners.amazonaws.com/partners/0018a00001hHve4AAC/GoCloud"><img src="https://img.shields.io/badge/AWS%20Partner-Advanced-orange?style=for-the-badge&logo=amazonaws&logoColor=white" alt="AWS Partner"/></a><a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-green?style=for-the-badge&logo=apache&logoColor=white" alt="LICENSE"/></a></p>

Welcome to the Standard Platform — a suite of reusable and production-ready Terraform modules purpose-built for AWS environments.
Each module encapsulates best practices, security configurations, and sensible defaults to simplify and standardize infrastructure provisioning across projects.

## 📦 Module: Terraform S3 DynamoDB IAM State Management Module
<p align="right"><a href="https://github.com/gocloudLa/terraform-aws-wrapper-s3-backend/releases/latest"><img src="https://img.shields.io/github/v/release/gocloudLa/terraform-aws-wrapper-s3-backend.svg?style=for-the-badge" alt="Latest Release"/></a><a href=""><img src="https://img.shields.io/github/last-commit/gocloudLa/terraform-aws-wrapper-s3-backend.svg?style=for-the-badge" alt="Last Commit"/></a><a href="https://registry.terraform.io/modules/gocloudLa/wrapper-s3-backend/aws"><img src="https://img.shields.io/badge/Terraform-Registry-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform Registry"/></a></p>
This folder contains the necessary resources to implement a Terraform state backend to manage the Terraform state in a centralized way and avoid conflicts in multi-user environments. The module creates an S3 bucket to store the Terraform state, a DynamoDB table for state locking, and specific IAM policies for each account.

### ✨ Features

- 🔧 [Initial Configuration](#initial-configuration) - Migrate workspaces from Terraform Cloud and download tfstate



### 🔗 External Modules
| Name | Version |
|------|------:|
| <a href="https://github.com/terraform-aws-modules/terraform-aws-dynamodb-table" target="_blank">terraform-aws-modules/dynamodb-table/aws</a> | 5.0.0 |
| <a href="https://github.com/terraform-aws-modules/terraform-aws-iam" target="_blank">terraform-aws-modules/iam/aws</a> | 5.59.0 |
| <a href="https://github.com/terraform-aws-modules/terraform-aws-s3-bucket" target="_blank">terraform-aws-modules/s3-bucket/aws</a> | 5.2.0 |



## 🚀 Quick Start
```hcl
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
```


## 🔧 Additional Features Usage

### Initial Configuration
Use case: Migrate workspaces from Terraform Cloud
Initialize the repository with Terraform Cloud credentials, perform *terraform plan*, and subsequently download the tfstate with the following command:
```hcl
terraform-base state pull > terraform.tfstate
```


<details><summary>Table of Variables</summary>

```hcl
terraform-base state pull > terraform.tfstate
```


</details>




## 📑 Inputs
| Name                    | Description                                            | Type     | Default                                                      | Required |
| ----------------------- | ------------------------------------------------------ | -------- | ------------------------------------------------------------ | -------- |
| create_bucket           | Whether to create the S3 bucket                        | `bool`   | `true`                                                       | no       |
| bucket                  | Bucket name for the S3 instance                        | `string` | `"${local.common_name}-${local.project_name}-state"`         | no       |
| block_public_acls       | Block public ACLs on the bucket                        | `bool`   | `true`                                                       | no       |
| block_public_policy     | Block public policies on the bucket                    | `bool`   | `true`                                                       | no       |
| ignore_public_acls      | Ignore public ACLs on the bucket                       | `bool`   | `true`                                                       | no       |
| restrict_public_buckets | Restrict public bucket access                          | `bool`   | `true`                                                       | no       |
| object_ownership        | Object ownership configuration for the bucket          | `string` | `"BucketOwnerEnforced"`                                      | no       |
| attach_policy           | Whether to attach a policy to the bucket               | `bool`   | `true`                                                       | no       |
| policy                  | IAM policy document to be attached to the bucket       | `string` | `data.aws_iam_policy_document.this.json`                     | no       |
| versioning              | Versioning configuration for the S3 bucket             | `map`    | `{enabled = true}`                                           | no       |
| create_table            | Whether to create the DynamoDB table                   | `bool`   | `true`                                                       | no       |
| name                    | Name of the DynamoDB table                             | `string` | `"${local.common_name}-${local.project_name}-lock"`          | no       |
| hash_key                | Hash key for the DynamoDB table                        | `string` | `"LockID"`                                                   | no       |
| table_class             | Table class for the DynamoDB table                     | `string` | `"STANDARD"`                                                 | no       |
| attributes              | Attributes for the DynamoDB table                      | `list`   | `[{ name = "LockID", type = "S" }]`                          | no       |
| trusted_role_arns       | ARNs of trusted roles for the IAM role                 | `list`   | `["arn:aws:iam::${each.value.account_id}:root"]`             | no       |
| create_instance_profile | Whether to create an instance profile for the role     | `bool`   | `false`                                                      | no       |
| max_session_duration    | Maximum duration for the role session                  | `number` | `3600`                                                       | no       |
| create_role             | Whether to create the IAM role                         | `bool`   | `true`                                                       | no       |
| role_name               | Name of the IAM role to be created                     | `string` | `"${local.common_name}-s3-backend-${each.value.account_id}"` | no       |
| role_requires_mfa       | Whether the role requires MFA                          | `bool`   | `false`                                                      | no       |
| custom_role_policy_arns | ARNs of custom role policies to attach to the IAM role | `list`   | `[aws_iam_policy.this[each.key].arn]`                        | no       |








---

## 🤝 Contributing
We welcome contributions! Please see our contributing guidelines for more details.

## 🆘 Support
- 📧 **Email**: info@gocloud.la
- 🐛 **Issues**: [GitHub Issues](https://github.com/gocloudLa/issues)

## 🧑‍💻 About
We are focused on Cloud Engineering, DevOps, and Infrastructure as Code.
We specialize in helping companies design, implement, and operate secure and scalable cloud-native platforms.
- 🌎 [www.gocloud.la](https://www.gocloud.la)
- ☁️ AWS Advanced Partner (Terraform, DevOps, GenAI)
- 📫 Contact: info@gocloud.la

## 📄 License
This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details. 