locals {
  full_app_name = var.APP_ENVIRONMENT == "production" ? var.APP_NAME :"${var.APP_NAME}-${var.APP_ENVIRONMENT}"
}

resource "doppler_secret" "full_app_name" {
  project = var.APP_NAME
  config = var.APP_ENVIRONMENT
  name = "FULL_APP_NAME"
  value = local.full_app_name
}

resource "doppler_secret" "db_connection" {
  project = var.APP_NAME
  config = var.APP_ENVIRONMENT
  name = "DB_CONNECTION"
  value = "mysql"
}

resource "doppler_secret" "db_host" {
  project = var.APP_NAME
  config = var.APP_ENVIRONMENT
  name = "DB_HOST"
  value = "${local.full_app_name}-db"
}

resource "doppler_secret" "db_port" {
  project = var.APP_NAME
  config = var.APP_ENVIRONMENT
  name = "DB_PORT"
  value = "3306"
}

resource "doppler_secret" "db_database" {
  project = var.APP_NAME
  config = var.APP_ENVIRONMENT
  name = "DB_DATABASE"
  value = var.APP_NAME
}

resource "random_password" "db_username" {
  length = 32
  special = false
}

resource "doppler_secret" "db_username" {
  project = var.APP_NAME
  config = var.APP_ENVIRONMENT
  name = "DB_USERNAME"
  value = random_password.db_username.result
}

resource "random_password" "db_root_password" {
  length = 56
  special = true
  override_special = "_"
}

resource "doppler_secret" "db_root_password" {
  project = var.APP_NAME
  config = var.APP_ENVIRONMENT
  name = "DB_ROOT_PASSWORD"
  value = random_password.db_root_password.result
}

resource "random_password" "db_password" {
  length = 56
  special = true
  override_special = "_"
}

resource "doppler_secret" "db_password" {
  project = var.APP_NAME
  config = var.APP_ENVIRONMENT
  name = "DB_PASSWORD"
  value = random_password.db_password.result
}

resource "doppler_secret" "kafka_host" {
  project = var.APP_NAME
  config = var.APP_ENVIRONMENT
  name = "KAFKA_HOST"
  value = "${local.full_app_name}-kafka"
}

resource "doppler_secret" "app_url" {
  project = var.APP_NAME
  config = var.APP_ENVIRONMENT
  name = "APP_URL"
  value = "${local.full_app_name}.${data.doppler_secrets.commons.map.DNS_DEFAULT_ZONE_ADDRESS}"
}

output "app_url" {
  value = nonsensitive(doppler_secret.app_url.value)
}

resource "doppler_secret" "kafka_dashboard_url" {
  project = var.APP_NAME
  config = var.APP_ENVIRONMENT
  name = "KAFKA_DASHBOARD_URL"
  value = "${local.full_app_name}-kafka.${data.doppler_secrets.commons.map.DNS_DEFAULT_ZONE_ADDRESS}"
}

resource "random_uuid" "kafka_cluster_id" {}

resource "doppler_secret" "kafka_cluster_id" {
  project = var.APP_NAME
  config = var.APP_ENVIRONMENT
  name = "KAFKA_CLUSTER_ID"
  value = random_uuid.kafka_cluster_id.result
}

output "kafka_dashboard_url" {
  value = nonsensitive(doppler_secret.kafka_dashboard_url.value)
}

resource "doppler_secret" "database_url" {
  project = var.APP_NAME
  config = var.APP_ENVIRONMENT
  name = "DATABASE_URL"
  value = "${local.full_app_name}-db.${data.doppler_secrets.commons.map.DNS_DEFAULT_ZONE_ADDRESS}"
}

output "database_url" {
  value = nonsensitive(doppler_secret.database_url.value)
}

resource "doppler_secret" "database_url_port" {
  project = var.APP_NAME
  config = var.APP_ENVIRONMENT
  name = "DATABASE_URL_PORT"
  value = var.TRAEFIK_DB_PORT
}
