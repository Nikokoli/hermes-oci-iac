# Hermes IaC on OCI

Terraform configuration to provision a compute instance in Oracle Cloud
Infrastructure (OCI) ready to run the [Hermes Agent](https://hermes-agent.nousresearch.com/).

## What it provisions

- VCN (10.0.0.0/16) with DNS label `hermesvcn`
- Internet gateway + route table (default route to IG)
- Security list allowing SSH (22), HTTP (80), HTTPS (443) inbound; all outbound
- Subnet (10.0.1.0/24) attached to the route table & security list
- ephemeral SSH keypair (private key shown as a sensitive output)
- Compute instance (`VM.Standard.E2.1.Micro` by default, the OCI Always Free shape)
  running Oracle Linux
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

## Choosing a shape

`shape` defaults to `VM.Standard.E2.1.Micro` (OCI Always Free: 1 OCPU, 1 GB RAM).
1 GB is tight for the Hermes Agent: expect to need swap, and use a larger fixed
shape such as `VM.Standard2.1` if it runs out of memory.

```hcl
shape = "VM.Standard2.1"
```

Only fixed shapes are supported (no `shape_config` is set), so flexible shapes
such as `VM.Standard.E4.Flex` will not work.

`terraform plan` checks the shape against the image in `image_ocid` and fails with
a message listing the shapes that image supports when they do not match. The check
covers the image only, not availability in your availability domain; Micro capacity
can be limited, so a different `availability_domain` may be needed.

## Tests

```bash
terraform init -backend=false
terraform test
```

The tests mock the OCI provider, so they need no credentials. `terraform plan` and
`apply` still need real OCI credentials and a valid image OCID.

## Cleanup

```bash
terraform destroy
```

## License

MIT
