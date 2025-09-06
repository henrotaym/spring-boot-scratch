variable "DOPPLER_PRIVATE_TOKEN" {
  sensitive = true
  ephemeral = true
  type = string
  description = "Doppler service token"
  nullable = false
}

variable "SERVER_NAME" {
  sensitive = false
  ephemeral = false
  type = string
  description = "Name allocated to server"
  nullable = false
}

variable "APP_NAME" {
  sensitive = false
  ephemeral = false
  type = string
  description = "Name to allocation to application"
  nullable = false
}

variable "APP_ENVIRONMENT" {
  sensitive = false
  ephemeral = false
  type = string
  description = "Application environment to allocate to application"
  nullable = false
}

variable "TRAEFIK_DB_PORT" {
  sensitive = false
  ephemeral = false
  type = number
  description = "Entrypoint port allocated to database in traefik config"
  nullable = false
  default = 25060
}

variable "GITHUB_REPOSITORY_NAME" {
  sensitive = false
  ephemeral = false
  type = string
  description = "Github repository allocated to application"
  nullable = false
}
