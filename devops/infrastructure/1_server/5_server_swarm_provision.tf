locals {
  save_ports_command = "sudo iptables-save | sudo tee /etc/iptables/rules.v4"
  default_ports_to_open = [
    {
      port     = "2377"
      protocol = "tcp"
      comment  = "Docker Swarm Management"
    },
    {
      port     = "7946"
      protocol = "tcp"
      comment  = "Docker Swarm Node TCP Communication"
    },
    {
      port     = "7946"
      protocol = "udp"
      comment  = "Docker Swarm Node UDP Communication"
    },
    {
      port     = "4789"
      protocol = "udp"
      comment  = "Docker Swarm Overlay Network"
    },
    {
      port     = "80"
      protocol = "tcp"
      comment  = "HTTP Web Traffic"
    },
    {
      port     = "443"
      protocol = "tcp"
      comment  = "HTTPS Web Traffic"
    },
  ]
  database_ports_range = range(var.DATABASE_MIN_PORT, var.DATABASE_MAX_PORT + 1)
}

locals {
  database_ports_to_open = [
    for rule in local.database_ports_range :
    {
      port     = rule
      protocol = "tcp"
      comment  = "Database Traffic ${rule}"
    }
  ]
}

locals {
  all_ports_to_open = {
    for rule in concat(local.default_ports_to_open, local.database_ports_to_open) : "${rule.protocol}-${rule.port}" => rule
  }
}

locals {
  install_docker_command = <<-EOT
    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker $USER
    newgrp docker

    # Enable docker logs rotation to limit storage taken
    tee /etc/docker/daemon.json > /dev/null <<EOF
    {
      "log-driver": "json-file",
      "log-opts": {
        "max-size": "50m",
        "max-file": "3"
      }
    }
    EOF
    sudo systemctl restart docker
  EOT
  install_doppler_command = <<-EOT
    sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
    curl -sLf --retry 3 --tlsv1.2 --proto "=https" 'https://packages.doppler.com/public/cli/gpg.DE2A7741A397C129.key' | sudo gpg --dearmor -o /usr/share/keyrings/doppler-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/doppler-archive-keyring.gpg] https://packages.doppler.com/public/cli/deb/debian any-version main" | sudo tee /etc/apt/sources.list.d/doppler-cli.list
    sudo apt-get update && sudo apt-get install -y doppler
  EOT
}

resource "ssh_resource" "provide_server" {
  when = "create"
  host = doppler_secret.public_ip.value
  user = doppler_secret.ssh_username.value
  private_key = doppler_secret.ssh_private_key.value
  timeout = "3m"
  commands = [
    local.install_docker_command,
    local.install_doppler_command
  ]
}

resource "ssh_resource" "open_ports" {
  depends_on = [ ssh_resource.provide_server ]
  for_each = local.all_ports_to_open
  when = "create"
  host = doppler_secret.public_ip.value
  user = doppler_secret.ssh_username.value
  private_key = doppler_secret.ssh_private_key.value
  timeout = "30s"
  commands = [
    "sudo iptables -A INPUT -p ${each.value.protocol} --dport ${each.value.port} -j ACCEPT -m comment --comment \"${each.value.comment}\"",
    "${local.save_ports_command}"
  ]
}

resource "ssh_resource" "close_ports" {
  depends_on = [ ssh_resource.provide_server ]
  for_each = local.all_ports_to_open
  when = "destroy"
  host = doppler_secret.public_ip.value
  user = doppler_secret.ssh_username.value
  private_key = doppler_secret.ssh_private_key.value
  timeout = "30s"
  commands = [
     "sudo iptables -D INPUT -p ${each.value.protocol} --dport ${each.value.port} -j ACCEPT -m comment --comment \"${each.value.comment}\"",
    "${local.save_ports_command}"
  ]
}

resource "ssh_resource" "init_swarm" {
  depends_on = [ ssh_resource.provide_server ]
  when = "create"
  host = doppler_secret.public_ip.value
  user = doppler_secret.ssh_username.value
  private_key = doppler_secret.ssh_private_key.value
  timeout = "30s"
  commands = [
    "docker swarm init --advertise-addr ${doppler_secret.private_ip.value}",
    "docker network create --driver overlay --attachable accessible"
  ]
}

output "proxy_url" {
  value = nonsensitive("${var.SERVER_NAME}-proxy.${data.doppler_secrets.commons.map.DNS_DEFAULT_ZONE_ADDRESS}")
}

output "server_ip" {
  value = oci_core_instance.instance.public_ip
}
