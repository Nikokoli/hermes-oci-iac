# ---------------------------------------------------------------------------
# Hermes on OCI — Infrastructure as Code (Terraform)
#
# Provisions a compute instance in OCI ready to run the Hermes Agent,
# plus the networking required to reach it (VCN, subnet, internet gateway,
# route table, security list).
#
# Provide your values in terraform.tfvars (copy terraform.tfvars.example).
# ---------------------------------------------------------------------------

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = var.compartment_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

# ---------------------------------------------------------------- Network ---
resource "oci_core_vcn" "hermes" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = var.compartment_ocid
  display_name   = "hermes-vcn"
  dns_label      = "hermesvcn"

  tags = {
    Project = "hermes"
  }
}

resource "oci_core_internet_gateway" "hermes" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.hermes.id
  display_name   = "hermes-ig"
  is_enabled     = true

  tags = {
    Project = "hermes"
  }
}

resource "oci_core_route_table" "hermes" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.hermes.id
  display_name   = "hermes-rt"
  route_rules    = [
    {
      network_entity_id = oci_core_internet_gateway.hermes.id
      destination       = "0.0.0.0/0"
      destination_type  = "CIDR_BLOCK"
    },
  ]

  tags = {
    Project = "hermes"
  }
}

resource "oci_core_security_list" "hermes" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.hermes.id
  display_name   = "hermes-sl"

  ingress_security_rules = [
    # SSH
    {
      protocol    = "6"
      source      = "0.0.0.0/0"
      stateless   = false
      tcp_options = { min = 22, max = 22 }
      description = "SSH"
    },
    # Hermes web UI / API (adjust ports to your setup)
    {
      protocol    = "6"
      source      = "0.0.0.0/0"
      stateless   = false
      tcp_options = { min = 80, max = 80 }
      description = "HTTP"
    },
    {
      protocol    = "6"
      source      = "0.0.0.0/0"
      stateless   = false
      tcp_options = { min = 443, max = 443 }
      description = "HTTPS"
    },
  ]
  egress_security_rules = [
    {
      protocol    = "all"
      source      = "0.0.0.0/0"
      stateless   = false
      description = "All outbound"
    },
  ]

  tags = {
    Project = "hermes"
  }
}

resource "oci_core_subnet" "hermes" {
  compartment_id       = var.compartment_ocid
  vcn_id               = oci_core_vcn.hermes.id
  cidr_block           = "10.0.1.0/24"
  display_name         = "hermes-subnet"
  prohibition_ingress  = false
  prohibition_egress   = false
  route_table_id       = oci_core_route_table.hermes.id
  security_list_ids    = [oci_core_security_list.hermes.id]
  dns_label            = "hermessubnet"

  tags = {
    Project = "hermes"
  }
}

# ----------------------------------------------------------- SSH keypair ---
resource "tls_private_key" "hermes_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "oci_core_key" "hermes_ssh" {
  compartment_id = var.compartment_ocid
  display_name   = "hermes-ssh-key"
  public_key     = tls_private_key.hermes_ssh.public_key_openssh

  tags = {
    Project = "hermes"
  }
}

# ------------------------------------------------------------ Compute -----
resource "oci_core_instance" "hermes" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_ocid
  display_name        = "hermes-instance"
  shape               = var.shape

  source_details {
    source_type = "image"
    source_id   = var.image_ocid
  }

  create_vnic_details {
    subnet_id         = oci_core_subnet.hermes.id
    assign_public_ip  = true
    display_name      = "hermes-vnic"
    hostname_label    = "hermes"
    skip_source_dest_check = false
  }

  metadata = {
    ssh_authorized_keys = tls_private_key.hermes_ssh.public_key_openssh
    user_data           = <<-EOF
      #cloud-config
      packages:
        - git
        - curl
      runcmd:
        - mkdir -p /home/ubuntu/.hermes/.local/bin
        - curl -fsSL https://github.com/cli/cli/releases/download/v2.97.0/gh_2.97.0_linux_amd64.tar.gz -o /tmp/gh.tar.gz
        - tar -xzf /tmp/gh.tar.gz -C /tmp --strip-components=2 gh_2.97.0_linux_amd64/bin/gh
        - install -m 0755 /tmp/gh_2.97.0_linux_amd64/bin/gh /home/ubuntu/.hermes/.local/bin/gh
    EOF
  }

  tags = {
    Project = "hermes"
  }
}

# ----------------------------------------------------------------- Output --
