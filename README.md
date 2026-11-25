# Hermes IaC on OCI

Terraform configuration to provision a compute instance in Oracle Cloud
Infrastructure (OCI) ready to run the [Hermes Agent](https://hermes-agent.nousresearch.com/).

## What it provisions

- VCN (10.0.0.0/16) with DNS label `hermesvcn`
- Internet gateway + route table (default route to IG)
- Security list allowing SSH (22), HTTP (80), HTTPS (443) inbound; all outbound
- Subnet (10.0.1.0/24) attached to the route table & security list
- ephemeral SSH keypair (private key shown as a sensitive output)
- Compute instance (`VM.Standard2.1` by default) running Oracle Linux
  - Cloud-init installs `git`, `curl`, and the GitHub CLI (`gh` 2.97.0)
- Public IP on the instance

## Prerequisites

1. [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) (>= 1.5)
2. OCI API key configured for your user (`private_key_path`, `fingerprint`)
3. `gh` authenticated (`gh auth login`) if you want to create the GitHub repo from here

## Quick start

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your OCIDs, region, AD, image OCID, etc.

terraform init
terraform plan
terraform apply
```

After `apply`, note the `instance_public_ip` output and the sensitive
`ssh_private_key_pem` output — save the private key to a file and chmod 600 it.

SSH into the instance:

```bash
ssh -i hermes_key.pem ubuntu@<instance_public_ip>
```

Then on the instance, authenticate gh and configure git:

```bash
/home/ubuntu/.hermes/.local/bin/gh auth login --hostname github.com --git-protocol https --web --insecure-storage
/home/ubuntu/.hermes/.local/bin/gh auth setup-git
git config --global user.name "$(gh api user --jq '.name')"
git config --global user.email "$(gh api user --jq '.email')"
```

## Variables

See `variables.tf` for the full list. Required:
- `tenancy_ocid`, `compartment_ocid`, `user_ocid`, `fingerprint`, `private_key_path`, `region`
- `availability_domain`, `image_ocid`

## Cleanup

```bash
terraform destroy
```

## License

MIT
