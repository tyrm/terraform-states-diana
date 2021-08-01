terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }

  backend "s3" {
    skip_credentials_validation = true
    skip_metadata_api_check = true
    region = "us-east-1"
    bucket = "ptzo-terraform-state"
    key = "bootstrap-cluster/terraform.tfstate"
  }
}
