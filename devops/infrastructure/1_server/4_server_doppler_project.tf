resource "doppler_project" "server" {
  name = "oci-${var.SERVER_NAME}"
}

resource "doppler_environment" "private" {
  project = doppler_project.server.name
  name = "private"
  slug = "private"
}

resource "doppler_secret" "ssh_username" {
  project = doppler_project.server.id
  config = doppler_environment.private.slug
  name = "SSH_USERNAME"
  value = "ubuntu"
}

resource "doppler_secret" "ssh_private_key" {
  project = doppler_project.server.id
  config = doppler_environment.private.slug
  name = "SSH_PRIVATE_KEY"
  value = chomp(tls_private_key.instance_ssh_key.private_key_openssh)
}

resource "doppler_secret" "public_ip" {
  project = doppler_project.server.id
  config = doppler_environment.private.slug
  name = "PUBLIC_IP"
  value = oci_core_instance.instance.public_ip
}

resource "doppler_secret" "private_ip" {
  project = doppler_project.server.id
  config = doppler_environment.private.slug
  name = "PRIVATE_IP"
  value = oci_core_instance.instance.private_ip
}
