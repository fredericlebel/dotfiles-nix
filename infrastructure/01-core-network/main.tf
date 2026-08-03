module "tailscale" {
  source = "../modules/tailscale"

  acl_json         = file("${path.module}/policy.hujson")
  dns_nameservers  = var.dns_nameservers
  dns_search_paths = var.dns_search_paths
  enable_magic_dns = var.enable_magic_dns
  webhook_url      = var.discord_webhook_url
  contact_email    = var.tailscale_contact_email
}
