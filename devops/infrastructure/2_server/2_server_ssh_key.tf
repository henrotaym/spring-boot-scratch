resource "tls_private_key" "instance_ssh_key" {
  algorithm = "ED25519"
}

resource "local_file" "ssh_key" {
  content = tls_private_key.instance_ssh_key.private_key_openssh
  filename = "private_key.pem"
  file_permission = 600
}