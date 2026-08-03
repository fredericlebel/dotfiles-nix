terraform {
  required_version = ">= 1.6.0"

  required_providers {
    tailscale = {
      source  = "tailscale/tailscale"
      version = "~> 0.17"
    }
  }

  backend "pg" {
    schema_name = "layer_01_core_network"
  }
}
