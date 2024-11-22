resource "random_uuid" "uuid" {}

locals {
  subaccount_name      = "${var.subaccount_stage} ${var.project_name}"
  subaccount_subdomain = join("-", [lower(replace("${var.subaccount_stage}-${var.project_name}", " ", "-")), random_uuid.uuid.result])
  beta_enabled         = var.subaccount_stage == "PROD" ? false : true
  service_name_prefix  = lower(replace("${var.subaccount_stage}-${var.project_name}", " ", "-"))
}

resource "btp_subaccount" "project_subaccount" {
  name         = local.subaccount_name
  subdomain    = local.subaccount_subdomain
  region       = var.subaccount_region
  beta_enabled = local.beta_enabled
  labels = {
    "stage"      = [var.subaccount_stage]
    "costcenter" = [var.project_costcenter]
  }
}

resource "btp_subaccount_entitlement" "alert_notification_service_standard" {
  subaccount_id = btp_subaccount.project_subaccount.id
  service_name  = "alert-notification"
  plan_name     = "standard"
}

resource "btp_subaccount_entitlement" "feature_flags_service_lite" {
  subaccount_id = btp_subaccount.project_subaccount.id
  service_name  = "feature-flags"
  plan_name     = "lite"
}

resource "btp_subaccount_entitlement" "feature_flags_dashboard_app_lite" {
  subaccount_id = btp_subaccount.project_subaccount.id
  service_name  = "feature-flags-dashboard"
  plan_name     = "dashboard"
}

data "btp_subaccount_service_plan" "alert_notification_service_standard" {
  subaccount_id = btp_subaccount.project_subaccount.id
  name          = "standard"
  offering_name = "alert-notification"
  depends_on    = [btp_subaccount_entitlement.alert_notification_service_standard]
}

resource "btp_subaccount_service_instance" "alert_notification_service_standard" {
  subaccount_id  = btp_subaccount.project_subaccount.id
  serviceplan_id = data.btp_subaccount_service_plan.alert_notification_service_standard.id
  name           = "${local.service_name_prefix}-alert-notification"
}

resource "btp_subaccount_subscription" "feature_flags_dashboard_app_lite" {
  subaccount_id = btp_subaccount.project_subaccount.id
  app_name      = "feature-flags-dashboard"
  plan_name     = "lite"
  depends_on    = [btp_subaccount_entitlement.feature_flags_dashboard_app_lite]
}
