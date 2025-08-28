terraform {
  required_providers {
    doppler = {
      source = "DopplerHQ/doppler"
      version = "1.18.0"
    }
    oci = {
      source = "oracle/oci"
      version = "7.5.0"
    }

    tls = {
      source = "hashicorp/tls"
      version = "4.1.0"
    }

    local = {
      source = "hashicorp/local"
      version = "2.5.3"
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

data "doppler_secrets" "oci" {
  project = "oci"
  config = "private"
}

data "doppler_secrets" "cloudns" {
  project = "cloudns"
  config = "private"
}

provider "oci" {
  tenancy_ocid = data.doppler_secrets.oci.map.OCI_TENANCY
  user_ocid = data.doppler_secrets.oci.map.OCI_USER
  private_key = data.doppler_secrets.oci.map.OCI_PRIVATE_KEY
  fingerprint = data.doppler_secrets.oci.map.OCI_FINGERPRINT
  region = data.doppler_secrets.oci.map.OCI_REGION
}

provider "tls" {}

provider "local" {}

provider "ssh" {}