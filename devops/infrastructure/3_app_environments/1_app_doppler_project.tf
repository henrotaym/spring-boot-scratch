resource "doppler_project" "app" {
  name = var.APP_NAME
}

locals {
  environments = toset(["production", "staging", "local"])
}

resource "doppler_environment" "environments" {
  for_each = local.environments
  project  = doppler_project.app.name
  name     = each.value
  slug     = each.value
}

resource "doppler_service_token" "environment_tokens" {
  for_each = doppler_environment.environments
  project  = doppler_project.app.id
  config   = each.value.name
  name     = each.value.name
}

resource "doppler_secret" "doppler_tokens" {
  for_each = doppler_service_token.environment_tokens
  project  = doppler_project.app.name
  config   = each.value.config
  name     = "DOPPLER_TOKEN"
  value    = each.value.key
}

resource "doppler_secret" "app_names" {
  for_each = doppler_environment.environments
  project  = doppler_project.app.name
  config   = each.value.name
  name     = "APP_NAME"
  value    = var.APP_NAME
}

resource "doppler_secret" "dockerhub_usernames" {
  for_each = doppler_environment.environments
  project  = doppler_project.app.name
  config   = each.value.name
  name     = "DOCKERHUB_USERNAME"
  value    = data.doppler_secrets.commons.map.DOCKERHUB_USERNAME
}
