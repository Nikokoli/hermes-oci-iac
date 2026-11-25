terraform {
  required_version = ">= 1.5"

  required_providers {
    oci = {
      source  = "hashicorp/oci"
      version = "~> 5.50"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}
