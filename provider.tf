provider "aws" {
  region     = coalesce(var.aws_region, var.region)
  access_key = var.access_key
  secret_key = var.secret_key
  profile    = var.aws_profile
}
