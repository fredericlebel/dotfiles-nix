variable "tailscale_api_key" {
  type        = string
  default     = null
  sensitive   = true
  description = "Clé API Tailscale (ou utiliser la variable d'environnement TAILSCALE_API_KEY)"
}

variable "tailscale_oauth_client_id" {
  type        = string
  default     = null
  sensitive   = true
  description = "OAuth Client ID Tailscale (ou utiliser TAILSCALE_OAUTH_CLIENT_ID)"
}

variable "tailscale_oauth_client_secret" {
  type        = string
  default     = null
  sensitive   = true
  description = "OAuth Client Secret Tailscale (ou utiliser TAILSCALE_OAUTH_CLIENT_SECRET)"
}

variable "tailscale_tailnet" {
  type        = string
  default     = null
  description = "Nom du Tailnet (ex: example.org ou org.ts.net)"
}

variable "dns_nameservers" {
  type        = list(string)
  default     = ["1.1.1.1", "1.0.0.1"]
  description = "Serveurs DNS globaux pour le Tailnet"
}

variable "dns_search_paths" {
  type        = list(string)
  default     = []
  description = "Chemins de recherche DNS pour le Tailnet"
}

variable "enable_magic_dns" {
  type        = bool
  default     = true
  description = "Activer ou désactiver MagicDNS"
}

variable "discord_webhook_url" {
  type        = string
  default     = null
  sensitive   = true
  description = "URL du Webhook Discord pour recevoir les alertes Tailscale (alimentée via SOPS/direnv)"
}

variable "tailscale_contact_email" {
  type        = string
  default     = null
  description = "Adresse courriel pour les notifications administratives, sécurité, support et facturation Tailscale (alimentée via SOPS/direnv)"
}
