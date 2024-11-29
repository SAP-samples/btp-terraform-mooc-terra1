terraform {
  required_providers {
    cloudfoundry = {
      source  = "cloudfoundry/cloudfoundry"
      version = "1.1.0"
    }
  }
}

provider "cloudfoundry" {
  api_url = var.cf_api_url
}
