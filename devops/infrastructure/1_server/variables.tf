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
  description = "Name to allocate to server. Also used to prefix networking pieces"
  nullable = false
}

variable "SERVER_SHAPE_NAME" {
  sensitive = false
  ephemeral = false
  type = string
  description = "Shape name to allocate to server"
  nullable = true
  default = "VM.Standard.A1.Flex"
}

variable "SERVER_CPU_COUNT" {
  sensitive = false
  ephemeral = false
  type = number
  description = "Number of CPU units to allocate to server"
  nullable = true
  default = 1
}

variable "SERVER_RAM_IN_GBS" {
  sensitive = false
  ephemeral = false
  type = number
  description = "RAM quantity to allocate to server"
  nullable = true
  default = 6
}

variable "SERVER_OPERATING_SYSTEM_NAME" {
  sensitive = false
  ephemeral = false
  type = string
  description = "Operating system to allocate to server"
  nullable = true
  default = "Canonical Ubuntu"
}

variable "SERVER_OPERATING_SYSTEM_VERSION" {
  sensitive = false
  ephemeral = false
  type = string
  description = "Operating system to allocate to server"
  nullable = true
  default = "24.04"
}

variable "NETWORKING_SUBNET_CIDR" {
  sensitive = false
  ephemeral = false
  type = string
  description = "Subnet CIDR to use for networking"
  nullable = true
  default = "10.0.0.0/24"
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
