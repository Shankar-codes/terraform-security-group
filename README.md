# terraform-security-group

A minimal, reusable Terraform module for provisioning an [AWS Security Group](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html) (`aws_security_group`) with sensible default tagging and a permissive default egress rule.

> **Note:** This module is intentionally lightweight (no ingress rules are defined). It's meant as a starting building block — extend it with `aws_security_group_rule` resources, or fork it to add inline `ingress` blocks, depending on your use case.

## Features

- Creates a single AWS Security Group scoped to a given VPC
- Applies consistent, merged tagging via `locals.tf` (`Project`, `Environment`, `Terraform`, plus any custom tags)
- Auto-generates a standardized `Name` tag in the form `<sg_name>-<project_name>-<environment>`
- Default egress rule allowing all outbound traffic (`0.0.0.0/0`, all ports/protocols)
- Outputs the created security group ID for use by other modules/resources

## Repository Structure

| File | Description |
|---|---|
| [`security_group.tf`](./security_group.tf) | Defines the `aws_security_group.main` resource, its default egress rule, and merged tags |
| [`variables.tf`](./variables.tf) | Input variable declarations for the module |
| [`locals.tf`](./locals.tf) | Computed local values — common tags and a name suffix used for consistent naming |
| [`output.tf`](./output.tf) | Exposes the created security group's ID as an output |

## Usage

Reference this module from your Terraform configuration:

```hcl
module "security_group" {
  source = "github.com/Shankar-codes/terraform-security-group"

  project_name    = "myapp"
  environment     = "dev"
  sg_name         = "myapp-web-sg"
  sg_description  = "Security group for web tier"
  vpc_id          = "vpc-0123456789abcdef0"

  sg_tags = {
    Owner = "platform-team"
  }
}

output "security_group_id" {
  value = module.security_group.Sg_id
}
```

Then run the standard Terraform workflow:

```bash
terraform init
terraform plan
terraform apply
```

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| `project_name` | Name of the project, used for tagging and name suffix | `string` | n/a | yes |
| `environment` | Deployment environment (e.g. `dev`, `staging`, `prod`) | `string` | n/a | yes |
| `sg_name` | Base name for the security group | `string` | n/a | yes |
| `sg_description` | Description for the security group | `string` | `""` | no |
| `vpc_id` | ID of the VPC where the security group will be created | `string` | n/a | yes |
| `sg_tags` | Additional custom tags to merge with the common tags | `map` | `{}` | no |

## Outputs

| Name | Description |
|---|---|
| `Sg_id` | The ID of the created security group (`aws_security_group.main.id`) |

## Tagging Behavior

Every security group created by this module is tagged with:

- `Project` — from `var.project_name`
- `Environment` — from `var.environment`
- `Terraform` — always `"true"`, to flag Terraform-managed resources
- `Name` — automatically computed as `<sg_name>-<project_name>-<environment>`
- Any additional key/value pairs supplied via `sg_tags`

This logic lives in [`locals.tf`](./locals.tf) and is merged into the resource tags in [`security_group.tf`](./security_group.tf).

## Default Egress Rule

The module creates one default egress rule allowing **all outbound traffic**:

```hcl
egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}
```

No ingress rules are defined by default — add them via additional `aws_security_group_rule` resources or extend the module as needed for your environment.

## Requirements

| Requirement | Notes |
|---|---|
| Terraform | A recent Terraform release (0.13+ recommended for module sourcing) |
| AWS Provider | `hashicorp/aws` provider, configured with valid credentials |
| AWS Permissions | IAM permissions to create/manage EC2 security groups in the target VPC |

## Known Limitations / Improvement Ideas

- `sg_tags` uses an untyped `map`; consider changing to `map(string)` for stricter type validation.
- No ingress rules are defined — consumers must add their own or the module must be extended.
- No `variable` description fields or validation blocks are currently set — adding these would improve module usability and `terraform-docs` output.
- No example usage (`examples/`) directory or automated tests (e.g. Terratest) are included.

## License

No license file is currently present in this repository. Add a `LICENSE` file to clarify usage terms before relying on this module in production or sharing it publicly.
