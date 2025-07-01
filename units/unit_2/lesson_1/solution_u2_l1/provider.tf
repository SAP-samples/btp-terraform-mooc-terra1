
terraform {
  required_providers {
    btp = {
      source  = "SAP/btp"
      version = "~> 1.14.0"
    }
  }
}

# Please checkout documentation on how best to authenticate against SAP BTP
# via the Terraform provider for SAP BTP
provider "btp" {
  globalaccount = "<MY GLOBAL ACCOUNT SUBDOMAIN>"
}
