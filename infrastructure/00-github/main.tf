resource "github_repository" "dotfiles_nix" {
  name        = "dotfiles-nix"
  description = "Connecting the . to build the perfect Nix-infrastructure."
  visibility  = "public"

  has_issues      = true
  has_projects    = false
  has_wiki        = false
  has_discussions = false

  delete_branch_on_merge = true
  allow_auto_merge       = true
  allow_squash_merge     = true
  allow_merge_commit     = false
  allow_rebase_merge     = true
}

resource "github_repository_vulnerability_alerts" "dotfiles_nix_alerts" {
  repository = github_repository.dotfiles_nix.id
}

resource "github_branch_protection" "main" {
  repository_id  = github_repository.dotfiles_nix.node_id
  pattern        = "main"
  enforce_admins = true

  required_status_checks {
    strict   = true
    contexts = ["Evaluate Nix Flake"] # Assurez-vous que c'est bien le nom de votre job d'Intégration Continue
  }

  required_pull_request_reviews {
    required_approving_review_count = 0 # Force de passer par une PR mais sans bloquer sur l'approbation d'un tiers
  }
}
