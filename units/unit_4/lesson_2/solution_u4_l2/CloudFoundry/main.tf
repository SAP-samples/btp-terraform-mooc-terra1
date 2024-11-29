resource "cloudfoundry_space" "project_space" {
  name = lower(replace("${var.subaccount_stage}-${var.project_name}", " ", "-"))
  org  = var.cf_org_id
}

resource "cloudfoundry_space_role" "space_manager" {
  username = var.cf_space_manager
  type     = "space_manager"
  space    = cloudfoundry_space.project_space.id
}

resource "cloudfoundry_space_role" "space_developer" {
  username = var.cf_space_developer
  type     = "space_developer"
  space    = cloudfoundry_space.project_space.id
}
