output "acl_id" {
  value       = length(tailscale_acl.this) > 0 ? tailscale_acl.this[0].id : null
  description = "ID de la ressource ACL Tailscale appliquée"
}

output "magic_dns_enabled" {
  value       = tailscale_dns_preferences.this.magic_dns
  description = "Indique si MagicDNS est activé pour le Tailnet"
}

output "nameservers" {
  value       = length(tailscale_dns_nameservers.this) > 0 ? tailscale_dns_nameservers.this[0].nameservers : []
  description = "Liste des serveurs DNS globaux appliqués au Tailnet"
}

output "webhook_id" {
  value       = length(tailscale_webhook.this) > 0 ? tailscale_webhook.this[0].id : null
  description = "ID de la ressource Webhook Tailscale activée"
}

output "contact_account_email" {
  value       = length(tailscale_contacts.this) > 0 ? one(tailscale_contacts.this[0].account).email : null
  description = "Adresse courriel du contact principal Tailscale"
}
