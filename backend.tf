terraform {
  backend "s3" {
    bucket         = "omnia-fortstack-terraform-state"
    key            = "wordpress-mysql/terraform.tfstate"
    region         = "us-west-1"
    use_lockfile = true
    encrypt      = true
  }
}
