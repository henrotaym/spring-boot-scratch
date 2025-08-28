data "oci_identity_availability_domains" "domains" {
  compartment_id = oci_identity_compartment.app.id
}

data "oci_core_images" "images" {
  compartment_id           = oci_identity_compartment.app.id
  operating_system         = var.SERVER_OPERATING_SYSTEM_NAME
  operating_system_version = var.SERVER_OPERATING_SYSTEM_VERSION
  shape                    = var.SERVER_SHAPE_NAME
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

resource "oci_core_instance" "instance" {
  display_name        = var.SERVER_NAME
  compartment_id      = oci_identity_compartment.app.id
  availability_domain = data.oci_identity_availability_domains.domains.availability_domains[0].name

  shape = var.SERVER_SHAPE_NAME
  shape_config {
    ocpus         = var.SERVER_CPU_COUNT
    memory_in_gbs = var.SERVER_RAM_IN_GBS
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.images.images[0].id
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.subnet.id
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = chomp(tls_private_key.instance_ssh_key.public_key_openssh)
  }

  timeouts {
    create = "15m"
  }
}
