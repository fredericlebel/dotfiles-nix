# 🧅 Infrastructure as Code (OpenTofu)

Ce répertoire contient la gestion déclarative de l'infrastructure du Homelab via **OpenTofu**.

## 🏗️ Architecture par Domaine Fonctionnel (Martin Fowler)

L'infrastructure est découpée en **niveaux fonctionnels indépendants (Layers)** ordonnés par dépendances d'exécution. Chaque niveau possède son propre état OpenTofu (`terraform.tfstate`) pour garantir l'isolation et la modularité.

```text
infrastructure/
├── README.md
├── 01-core-network/        # Le socle : Tailscale (ACLs, MagicDNS, AuthKeys), DNS global
├── 02-compute/             # Le contenant : Hyperviseurs, VMs Proxmox, LXC, stockage
├── 03-observability/       # La surveillance : Supervision Zabbix, Grafana, alertes
├── 04-services/            # Les applicatifs : Ingress, certificats TLS, microservices
└── modules/                # Modules OpenTofu réutilisables
    └── tailscale/          # Module encapsulant les ressources Tailscale
```

---

## 🚀 Utilisation (via `just`)

Pour agir sur un niveau d'infrastructure spécifique (par défaut `01-core-network`) :

| Commande                     | Description                                                  |
| ---------------------------- | ------------------------------------------------------------ |
| `just tofu-init [layer]`     | Initialiser un niveau (ex: `just tofu-init 01-core-network`) |
| `just tofu-plan [layer]`     | Prévisualiser les changements (dry-run)                      |
| `just tofu-apply [layer]`    | Appliquer les modifications sur le fournisseur               |
| `just tofu-fmt`              | Formater l'ensemble du code HCL du projet                    |
| `just tofu-validate [layer]` | Valider la syntaxe et la cohérence de la configuration       |

### Authentification Tailscale

Fournir les identifiants via des variables d'environnement avant d'exécuter `tofu-plan` ou `tofu-apply` :

```bash
export TAILSCALE_API_KEY="tskey-api-k..."
# ou OAuth :
export TAILSCALE_OAUTH_CLIENT_ID="k..."
export TAILSCALE_OAUTH_CLIENT_SECRET="tskey-client-..."
export TAILSCALE_TAILNET="mon-tailnet.ts.net"
```

---

## 🗄️ Backend d'État (PostgreSQL sur `ecaz`)

L'état d'OpenTofu est hébergé de façon centralisée et sécurisée dans la base PostgreSQL de l'hôte `ecaz`, accessible via le réseau VPN Tailscale.

Chaque niveau isole sa table d'état dans son propre **schéma PostgreSQL** (`schema_name`) :

- `01-core-network` ➔ `schema_name = "layer_01_core_network"`
- `02-compute` ➔ `schema_name = "layer_02_compute"`
- `03-observability` ➔ `schema_name = "layer_03_observability"`
- `04-services` ➔ `schema_name = "layer_04_services"`

### Connexion au backend :

Le mot de passe de la base de données est stocké de façon chiffrée dans `secrets/ecaz.yaml` (`postgres-opentofu-password`). Pour vous connecter :

```bash
# Récupérer le mot de passe SOPS
POSTGRES_PASS=$(sops -d --extract '["postgres-opentofu-password"]' secrets/ecaz.yaml)

# Définir la chaîne de connexion PostgreSQL pour OpenTofu (via Tailscale)
export PG_CONN_STR="postgres://opentofu:${POSTGRES_PASS}@ecaz.taila562f9.ts.net:5432/opentofu?sslmode=disable"

# Initialiser le backend du niveau
just tofu-init 01-core-network
```
