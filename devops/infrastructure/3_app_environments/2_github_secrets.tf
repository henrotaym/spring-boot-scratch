locals {
  github_repository_name = coalesce(var.GITHUB_REPOSITORY_NAME, var.APP_NAME)
}

resource "github_actions_secret" "dockerhub_username" {
  repository      = local.github_repository_name
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = data.doppler_secrets.commons.map.DOCKERHUB_USERNAME
}

resource "github_actions_secret" "dockerhub_token" {
  repository      = local.github_repository_name
  secret_name     = "DOCKERHUB_TOKEN"
  plaintext_value = data.doppler_secrets.commons.map.DOCKERHUB_TOKEN
}

resource "github_actions_secret" "app_name" {
  repository      = local.github_repository_name
  secret_name     = "APP_NAME"
  plaintext_value = var.APP_NAME
}

resource "github_actions_secret" "doppler_tokens" {
  for_each        = doppler_service_token.environment_tokens
  repository      = local.github_repository_name
  secret_name     = "${upper(each.value.name)}_DOPPLER_TOKEN"
  plaintext_value = each.value.key
}
