locals {
  proxy_stack_name = "proxy"
}
locals {
  proxy_stack_target_location = "/home/ubuntu/apps/${local.proxy_stack_name}"
}

locals {
  proxy_stack_compose_file_target_location = "${local.proxy_stack_target_location}/docker-compose.yml"
}

data "doppler_secrets" "server" {
  project = "oci-${var.SERVER_NAME}"
  config = "private"
}

resource "ssh_resource" "create_stack_folder" {
  when = "create"
  host = data.doppler_secrets.server.map.PUBLIC_IP
  user = data.doppler_secrets.server.map.SSH_USERNAME
  private_key = data.doppler_secrets.server.map.SSH_PRIVATE_KEY
  timeout = "15s"
  commands = [
    "mkdir -p ${local.proxy_stack_target_location}"
  ]
}

locals {
  database_ports_range = range(var.DATABASE_MIN_PORT, var.DATABASE_MAX_PORT + 1)
}

resource "ssh_resource" "deploy_proxy_stack" {
  depends_on = [ ssh_resource.create_stack_folder ]
  triggers = {
    always_run = "${timestamp()}"
  }
  host = data.doppler_secrets.server.map.PUBLIC_IP
  user = data.doppler_secrets.server.map.SSH_USERNAME
  private_key = data.doppler_secrets.server.map.SSH_PRIVATE_KEY
  timeout = "1m"
  file {
    content = templatefile("stacks/proxy/docker-compose.yml.tmpl", {
      database_ports_range = local.database_ports_range,
      dns_acme_email = nonsensitive(data.doppler_secrets.commons.map.DNS_DEFAULT_ZONE_EMAIL_ADDRESS),
      proxy_url = "${var.SERVER_NAME}-proxy.${nonsensitive(data.doppler_secrets.commons.map.DNS_DEFAULT_ZONE_ADDRESS)}"
    })
    destination = local.proxy_stack_compose_file_target_location
  }
  commands = [
    "docker stack deploy -c ${local.proxy_stack_compose_file_target_location} --detach=false ${local.proxy_stack_name}"
  ]
}
resource "ssh_resource" "remove_proxy_stack" {
  when = "destroy"
  host = data.doppler_secrets.server.map.PUBLIC_IP
  user = data.doppler_secrets.server.map.SSH_USERNAME
  private_key = data.doppler_secrets.server.map.SSH_PRIVATE_KEY
  timeout = "15s"
  commands = [
    "(docker stack ls | grep -q ${local.proxy_stack_name}) && docker stack rm ${local.proxy_stack_name}",
    "sudo rm -r ${local.proxy_stack_target_location}"
  ]
}