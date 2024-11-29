resource "btp_subaccount" "project_subaccount" {
  name         = "DEV Project ABC"
  subdomain    = "dev-project-abc"
  region       = "us10"
  beta_enabled = true
  labels = {
    "stage"      = ["DEV"]
    "costcenter" = ["12345"]
  }
}
