resource "github_actions_secret" "dockerhub_username" {
  repository      = var.GITHUB_REPOSITORY_NAME
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = data.doppler_secrets.commons.map.DOCKERHUB_USERNAME
}

resource "github_actions_secret" "dockerhub_token" {
  repository      = var.GITHUB_REPOSITORY_NAME
  secret_name     = "DOCKERHUB_TOKEN"
  plaintext_value = data.doppler_secrets.commons.map.DOCKERHUB_TOKEN
}

resource "github_actions_secret" "app_name" {
  repository      = var.GITHUB_REPOSITORY_NAME
  secret_name     = "APP_NAME"
  plaintext_value = var.APP_NAME
}

resource "github_actions_secret" "doppler_tokens" {
  for_each        = doppler_service_token.environment_tokens
  repository      = var.GITHUB_REPOSITORY_NAME
  secret_name     = "${upper(each.value.name)}_DOPPLER_TOKEN"
  plaintext_value = each.value.key
}
