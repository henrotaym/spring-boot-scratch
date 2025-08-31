locals {
  app_target_location = "/home/ubuntu/apps/${local.full_app_name}"
}

locals {
  app_stack_target_location = "${local.app_target_location}/app"
  kafka_target_location = "${local.app_target_location}/kafka"
}

resource "ssh_resource" "create_stack_folders" {
  when = "create"
  host = data.doppler_secrets.server.map.PUBLIC_IP
  user = data.doppler_secrets.server.map.SSH_USERNAME
  private_key = data.doppler_secrets.server.map.SSH_PRIVATE_KEY
  timeout = "15s"
  commands = [
    "mkdir -p ${local.app_stack_target_location}",
    "mkdir -p ${local.kafka_target_location}",
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
      traefik_db_port = "${var.DB_TRAEFIK_PORT}"
    })
    destination = "${local.app_stack_target_location}/docker-compose.yml"
  }
  file {
    content = templatefile("kafka/server.properties.custom.tmpl", {
      kafka_host = nonsensitive(doppler_secret.kafka_host.value)
    })
    destination = "${local.kafka_target_location}/server.properties.custom"
  }
  file {
    content = file("kafka/start.sh")
    destination = "${local.kafka_target_location}/start.sh"
    permissions = "0755"
  }
}

resource "ssh_resource" "remove_stack" {
  when = "destroy"
  host = data.doppler_secrets.server.map.PUBLIC_IP
  user = data.doppler_secrets.server.map.SSH_USERNAME
  private_key = data.doppler_secrets.server.map.SSH_PRIVATE_KEY
  timeout = "15s"
  commands = [
    "sudo rm -r /home/ubuntu/apps/${local.full_app_name}",
    "docker stack ls | grep -q ${local.full_app_name} && docker stack rm ${local.full_app_name}"
  ]
}
