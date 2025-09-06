locals {
  github_secret_prefix = upper(var.APP_ENVIRONMENT)
}

data "doppler_secrets" "server" {
  project = "oci-${var.SERVER_NAME}"
  config = "private"
}

resource "github_actions_secret" "ssh_username" {
  repository = var.GITHUB_REPOSITORY_NAME
  secret_name = "${local.github_secret_prefix}_SSH_USERNAME"
  plaintext_value = data.doppler_secrets.server.map.SSH_USERNAME
}

resource "github_actions_secret" "ssh_private_key" {
  repository = var.GITHUB_REPOSITORY_NAME
  secret_name = "${local.github_secret_prefix}_SSH_PRIVATE_KEY"
  plaintext_value = data.doppler_secrets.server.map.SSH_PRIVATE_KEY
}

resource "github_actions_secret" "public_ip" {
  repository = var.GITHUB_REPOSITORY_NAME
  secret_name = "${local.github_secret_prefix}_PUBLIC_IP"
  plaintext_value = data.doppler_secrets.server.map.PUBLIC_IP
}

output "server_ip" {
  value = nonsensitive(data.doppler_secrets.server.map.PUBLIC_IP)
}

resource "github_actions_secret" "stack_location" {
  repository = var.GITHUB_REPOSITORY_NAME
  secret_name = "${local.github_secret_prefix}_STACK_LOCATION"
  plaintext_value = local.app_stack_target_location
}

resource "github_actions_secret" "stack_name" {
  repository = var.GITHUB_REPOSITORY_NAME
  secret_name = "${local.github_secret_prefix}_STACK_NAME"
  plaintext_value = local.full_app_name
}
