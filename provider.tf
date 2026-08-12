# AWS provider configuration. Credentials are resolved from the execution
# environment (for example AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY, an AWS
# profile, or an assumed IAM role); do not store credentials in this module.
provider "aws" {
  region = var.region
}
