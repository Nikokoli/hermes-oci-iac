# ---------------------------------------------------------------------------
# Variables for Hermes on OCI
# ---------------------------------------------------------------------------

variable "tenancy_ocid" {
  type        = string
  description = "OCI tenancy OCID"
}

variable "compartment_ocid" {
  type        = string
  description = "OCI compartment OCID where resources will be created"
}

variable "user_ocid" {
  type        = string
  description = "OCI user OCID (API key owner)"
}

variable "fingerprint" {
  type        = string
  description = "Fingerprint of the OCI API public key"
}

variable "private_key_path" {
  type        = string
  description = "Path to the OCI API private key PEM file"
}

variable "region" {
  type        = string
  description = "OCI region (e.g. us-ashburn-1)"
}

variable "availability_domain" {
  type        = string
  description = "Availability domain to place the instance (e.g. HukT:PHX-AD-1)"
}

variable "shape" {
  type        = string
  default     = "VM.Standard.E2.1.Micro"
  description = <<-EOT
    Compute shape for the Hermes instance. The default, VM.Standard.E2.1.Micro,
    is the OCI Always Free AMD shape (1 OCPU, 1 GB RAM). Set another fixed shape
    (for example VM.Standard2.1) for more memory. Flexible shapes are not
    supported because no shape_config is set. The shape must be compatible with
    the image in image_ocid; this is checked when you run terraform plan.
  EOT
}

variable "image_ocid" {
  type        = string
  description = "OCID of the Oracle Linux image to use"
}

variable "ssh_public_key_path" {
  type        = string
  default     = "~/.ssh/id_rsa.pub"
  description = "Path to an SSH public key for instance access"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags applied to all resources"
}
