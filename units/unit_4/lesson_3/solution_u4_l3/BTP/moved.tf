moved {
  from = btp_subaccount_entitlement.alert_notification_service_standard
  to   = module.srvc_baseline.btp_subaccount_entitlement.alert_notification_service_standard
}

moved {
  from = btp_subaccount_entitlement.feature_flags_service_lite
  to   = module.srvc_baseline.btp_subaccount_entitlement.feature_flags_service_lite
}

moved {
  from = btp_subaccount_entitlement.feature_flags_dashboard_app
  to   = module.srvc_baseline.btp_subaccount_entitlement.feature_flags_dashboard_app
}


moved {
  from = btp_subaccount_service_instance.alert_notification_service_standard
  to   = module.srvc_baseline.btp_subaccount_service_instance.alert_notification_service_standard
}

moved {
  from = btp_subaccount_subscription.feature_flags_dashboard_app
  to   = module.srvc_baseline.btp_subaccount_subscription.feature_flags_dashboard_app
}
