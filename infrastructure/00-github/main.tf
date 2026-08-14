resource "github_repository" "dotfiles_nix" {
  name        = "dotfiles-nix"
  description = "Connecting the . to build the perfect Nix-infrastructure."
  visibility  = "public"

  has_issues      = true
  has_projects    = false
  has_wiki        = false
  has_discussions = false

  delete_branch_on_merge      = true
  allow_auto_merge            = true
  allow_squash_merge          = true
  allow_merge_commit          = false
  allow_rebase_merge          = true
  squash_merge_commit_title   = "PR_TITLE"
  squash_merge_commit_message = "PR_BODY"
}

resource "github_repository_vulnerability_alerts" "dotfiles_nix_alerts" {
  repository = github_repository.dotfiles_nix.id
}

resource "github_branch_protection" "main" {
  repository_id                   = github_repository.dotfiles_nix.node_id
  pattern                         = "main"
  enforce_admins                  = true
  require_signed_commits          = true
  require_conversation_resolution = true
  required_linear_history         = true

  required_status_checks {
    strict   = true
    contexts = ["ci-success"]
  }

  required_pull_request_reviews {
    required_approving_review_count = 0 # Force de passer par une PR mais sans bloquer sur l'approbation d'un tiers
  }
}



resource "github_repository" "profile" {
  name        = "fredericlebel"
  description = "My public GitHub profile"
  visibility  = "public"
  auto_init   = true
}

resource "github_repository_file" "profile_readme" {
  repository          = github_repository.profile.name
  branch              = "main"
  file                = "README.md"
  content             = file("${path.module}/files/profile_readme.md")
  commit_message      = "feat: update github profile readme"
  commit_author       = "Frédéric Lebel"
  commit_email        = "flebel@opval.com"
  overwrite_on_create = true
}
