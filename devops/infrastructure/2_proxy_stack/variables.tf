variable "DOPPLER_TOKEN" {
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
