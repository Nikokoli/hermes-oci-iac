# Offline tests for the shape variable and the image compatibility check.
# Providers are mocked, so no OCI credentials or real image are needed.
# Run with: terraform init -backend=false && terraform test

mock_provider "oci" {
  mock_data "oci_core_image_shapes" {
    defaults = {
      image_shape_compatibilities = [
        { image_id = "ocid1.image.oc1..test", shape = "VM.Standard.E2.1.Micro", memory_constraints = [], ocpu_constraints = [] },
        { image_id = "ocid1.image.oc1..test", shape = "VM.Standard2.1", memory_constraints = [], ocpu_constraints = [] },
      ]
    }
  }
}

mock_provider "tls" {}

variables {
  tenancy_ocid        = "ocid1.tenancy.oc1..test"
  compartment_ocid    = "ocid1.compartment.oc1..test"
  user_ocid           = "ocid1.user.oc1..test"
  fingerprint         = "00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00"
  private_key_path    = "/tmp/none.pem"
  region              = "us-ashburn-1"
  availability_domain = "AD-1"
  image_ocid          = "ocid1.image.oc1..test"
}

run "default_shape_is_micro" {
  command = plan

  assert {
    condition     = var.shape == "VM.Standard.E2.1.Micro"
    error_message = "The default shape should be the Always Free Micro shape."
  }

  assert {
    condition     = oci_core_instance.hermes.shape == "VM.Standard.E2.1.Micro"
    error_message = "The instance should use the Micro shape by default."
  }
}

run "no_shape_config_for_fixed_shape" {
  command = plan

  assert {
    condition     = length(oci_core_instance.hermes.shape_config) == 0
    error_message = "A fixed shape must not set shape_config."
  }
}

run "compatible_larger_shape_is_accepted" {
  command = plan

  variables {
    shape = "VM.Standard2.1"
  }

  assert {
    condition     = oci_core_instance.hermes.shape == "VM.Standard2.1"
    error_message = "A compatible non-default shape should be accepted."
  }
}

run "incompatible_shape_is_rejected" {
  command = plan

  variables {
    shape = "VM.Standard.A1.Flex"
  }

  expect_failures = [oci_core_instance.hermes]
}
