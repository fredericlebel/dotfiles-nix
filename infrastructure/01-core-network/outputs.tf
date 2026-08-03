output "tailscale_acl_id" {
  value       = module.tailscale.acl_id
  description = "ID de l'ACL Tailscale appliquée"
}

output "magic_dns_enabled" {
  value       = module.tailscale.magic_dns_enabled
  description = "Statut de MagicDNS dans le Tailnet"
}

output "dns_nameservers" {
  value       = module.tailscale.nameservers
  description = "Serveurs DNS globaux appliqués au Tailnet"
}

output "tailscale_webhook_id" {
  value       = module.tailscale.webhook_id
  description = "ID de la ressource Webhook Tailscale configurée"
}

output "tailscale_contact_account_email" {
  value       = module.tailscale.contact_account_email
  description = "Adresse courriel du contact principal Tailscale"
}
