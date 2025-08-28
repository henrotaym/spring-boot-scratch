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
  configure_ports_command = <<-EOT
    sudo iptables -A INPUT -p tcp --dport 2377 -j ACCEPT -m comment --comment "Docker Swarm Management"
    sudo iptables -A INPUT -p tcp --dport 7946 -j ACCEPT -m comment --comment "Docker Swarm Node TCP Communication"
    sudo iptables -A INPUT -p udp --dport 7946 -j ACCEPT -m comment --comment "Docker Swarm Node UDP Communication"
    sudo iptables -A INPUT -p udp --dport 4789 -j ACCEPT -m comment --comment "Docker Swarm Overlay Network"
    sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT -m comment --comment "HTTP Web Traffic"
    sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT -m comment --comment "HTTPS Web Traffic"
    sudo iptables -A INPUT -p tcp --dport 3306 -j ACCEPT -m comment --comment "Database Traffic 3306"
    sudo iptables-save | sudo tee /etc/iptables/rules.v4
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
    local.configure_ports_command,
    local.install_doppler_command
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
