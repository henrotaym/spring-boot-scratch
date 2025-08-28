terraform {
  required_providers {
    doppler = {
      source = "DopplerHQ/doppler"
      version = "1.18.0"
    }

    ssh = {
      source = "loafoe/ssh"
      version = "2.7.0"
    }
  }
  required_version = "~> 1.13.0"
}

provider "doppler" {
  doppler_token = var.DOPPLER_TOKEN
  alias = "doppler"
}

data "doppler_secrets" "doppler" {
  provider = doppler.doppler
}

provider "doppler" {
  doppler_token = data.doppler_secrets.doppler.map.DOPPLER_USER_ACCESS_TOKEN
}

provider "ssh" {}