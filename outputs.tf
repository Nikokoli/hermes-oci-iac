# ---------------------------------------------------------------------------
# Outputs for Hermes on OCI
# ---------------------------------------------------------------------------

output "vcn_id" {
  value       = oci_core_vcn.hermes.id
  description = "OCID of the VCN"
}

output "subnet_id" {
  value       = oci_core_subnet.hermes.id
  description = "OCID of the subnet"
}

output "instance_id" {
  value       = oci_core_instance.hermes.id
  description = "OCID of the Hermes compute instance"
}

output "instance_public_ip" {
  value       = oci_core_instance.hermes.public_ip
  description = "Public IP address of the Hermes instance"
}

output "ssh_private_key_pem" {
  value       = tls_private_key.hermes_ssh.private_key_pem
  description = "Private key (PEM) for SSH access to the instance — save this securely"
  sensitive   = true
}

output "gh_config_path" {
  value       = "/home/ubuntu/.config/gh"
  description = "Directory where the gh CLI stores its auth config on the instance"
}

output "swap_created" {
  value       = var.create_swap
  description = "Whether a swap file was configured on the instance"
}

output "swap_size_gb" {
  value       = var.swap_size_gb
  description = "Swap file size in GiB configured on the instance"
}
