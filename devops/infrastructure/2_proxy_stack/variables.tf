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

variable "DATABASE_MIN_PORT" {
  sensitive = false
  ephemeral = false
  type = number
  description = "Min port to allocate to database"
  nullable = true
  default = 25060
}

variable "DATABASE_MAX_PORT" {
  sensitive = false
  ephemeral = false
  type = number
  description = "Max port to allocate to database"
  nullable = true
  default = 25061
}
