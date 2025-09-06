locals {
  app_target_location = "/home/ubuntu/apps/${local.full_app_name}"
}

locals {
  app_stack_target_location = "${local.app_target_location}/app"
}

resource "ssh_resource" "create_stack_folders" {
  when = "create"
  host = data.doppler_secrets.server.map.PUBLIC_IP
  user = data.doppler_secrets.server.map.SSH_USERNAME
  private_key = data.doppler_secrets.server.map.SSH_PRIVATE_KEY
  timeout = "15s"
  commands = [
    "mkdir -p ${local.app_stack_target_location}",
  ]
}

resource "ssh_resource" "transfer_stack_files" {
  depends_on = [ ssh_resource.create_stack_folders ]
  triggers = {
    always_run = "${timestamp()}"
  }
  host = data.doppler_secrets.server.map.PUBLIC_IP
  user = data.doppler_secrets.server.map.SSH_USERNAME
  private_key = data.doppler_secrets.server.map.SSH_PRIVATE_KEY
  timeout = "15s"
  file {
    content = templatefile("stacks/app/docker-compose.yml.tmpl", {
      full_app_name = local.full_app_name,
      traefik_db_port = "${var.TRAEFIK_DB_PORT}"
    })
    destination = "${local.app_stack_target_location}/docker-compose.yml"
  }
}

resource "ssh_resource" "remove_stack" {
  when = "destroy"
  host = data.doppler_secrets.server.map.PUBLIC_IP
  user = data.doppler_secrets.server.map.SSH_USERNAME
  private_key = data.doppler_secrets.server.map.SSH_PRIVATE_KEY
  timeout = "15s"
  commands = [
    "(docker stack ls | grep -q ${local.full_app_name}) && docker stack rm ${local.full_app_name}",
    "sudo rm -r /home/ubuntu/apps/${local.full_app_name}"
  ]
}
