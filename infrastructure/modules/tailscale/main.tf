resource "tailscale_acl" "this" {
  count = var.acl_json != null ? 1 : 0

  acl = var.acl_json
}

resource "tailscale_dns_nameservers" "this" {
  count = length(var.dns_nameservers) > 0 ? 1 : 0

  nameservers = var.dns_nameservers
}

resource "tailscale_dns_preferences" "this" {
  magic_dns = var.enable_magic_dns
}

resource "tailscale_dns_search_paths" "this" {
  count = length(var.dns_search_paths) > 0 ? 1 : 0

  search_paths = var.dns_search_paths
}

resource "tailscale_webhook" "this" {
  count = var.webhook_url != null ? 1 : 0

  endpoint_url  = var.webhook_url
  provider_type = var.webhook_provider_type
  subscriptions = var.webhook_subscriptions
}

resource "tailscale_contacts" "this" {
  count = var.contact_email != null ? 1 : 0

  account {
    email = var.contact_email
  }

  support {
    email = var.contact_email
  }

  security {
    email = var.contact_email
  }
}
