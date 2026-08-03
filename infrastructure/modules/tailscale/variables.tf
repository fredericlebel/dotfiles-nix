variable "acl_json" {
  type        = string
  default     = null
  description = "Contenu JSON/HuJSON définissant les règles ACL et politiques Tailscale"
}

variable "dns_nameservers" {
  type        = list(string)
  default     = []
  description = "Liste des serveurs DNS globaux pour le Tailnet (ex: 1.1.1.1, NextDNS)"
}

variable "dns_search_paths" {
  type        = list(string)
  default     = []
  description = "Liste des chemins de recherche DNS pour le Tailnet"
}

variable "enable_magic_dns" {
  type        = bool
  default     = true
  description = "Activer ou désactiver MagicDNS dans le Tailnet"
}

variable "webhook_url" {
  type        = string
  default     = null
  sensitive   = true
  description = "URL du Webhook Discord/Slack pour recevoir les notifications Tailscale"
}

variable "webhook_provider_type" {
  type        = string
  default     = "discord"
  description = "Type de fournisseur pour le Webhook (ex: discord, slack, generic)"
}

variable "webhook_subscriptions" {
  type = list(string)
  default = [
    "categoryTailnetManagement",
    "categoryDeviceMisconfigurations",
    "nodeCreated",
    "nodeNeedsApproval",
    "nodeApproved",
    "nodeKeyExpiringInOneDay",
    "nodeKeyExpired",
    "nodeDeleted",
    "policyUpdate",
    "userCreated",
    "userNeedsApproval",
    "userSuspended",
    "userRestored",
    "userDeleted",
    "userApproved",
    "userRoleUpdated",
    "subnetIPForwardingNotEnabled",
    "exitNodeIPForwardingNotEnabled"
  ]
  description = "Liste des événements et catégories Tailscale déclenchant une notification Webhook"
}

variable "contact_email" {
  type        = string
  default     = null
  description = "Adresse courriel principale pour les contacts d'administration, sécurité, support et facturation Tailscale"
}
