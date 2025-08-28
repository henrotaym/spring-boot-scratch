resource "doppler_environment" "proxy" {
  project = "oci-${var.SERVER_NAME}"
  name = "proxy"
  slug = "proxy"
}

resource "doppler_secret" "proxy_address" {
  project = doppler_environment.proxy.project
  config = doppler_environment.proxy.name
  name = "PROXY_ADDRESS"
  value = "${var.SERVER_NAME}-proxy.${data.doppler_secrets.commons.map.DNS_DEFAULT_ZONE_ADDRESS}"
}

resource "doppler_secret" "acme_email" {
  project = doppler_environment.proxy.project
  config = doppler_environment.proxy.name
  name = "DNS_ACME_EMAIL"
  value = data.doppler_secrets.commons.map.DNS_DEFAULT_ZONE_EMAIL_ADDRESS
}

locals {
  proxy_stack_target_location = "/home/ubuntu/apps/proxy"
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

resource "doppler_service_token" "proxy" {
  project = doppler_environment.proxy.project
  config = "proxy"
  name = "proxy"
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
    content = file("stacks/proxy/docker-compose.yml")
    destination = local.proxy_stack_compose_file_target_location
  }
  commands = [
    "doppler run --token=${doppler_service_token.proxy.key} -- docker stack deploy -c ${local.proxy_stack_compose_file_target_location} --detach=false proxy"
  ]
}
