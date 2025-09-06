variable "DOPPLER_PRIVATE_TOKEN" {
  sensitive = true
  ephemeral = true
  type = string
  description = "Doppler service token"
  nullable = false
}

variable "APP_NAME" {
  sensitive = false
  ephemeral = false
  type = string
  description = "Name to allocation to application"
  nullable = false
}

variable "GITHUB_REPOSITORY_NAME" {
  sensitive = false
  ephemeral = false
  type = string
  description = "Github repository allocated to application"
  nullable = false
}
