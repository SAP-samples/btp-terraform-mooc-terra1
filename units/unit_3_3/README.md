# Unit 3.3 - Adding additional resources to the Terraform Configuration

## Goal 🎯

The goal of this unit is to make add additional resources to out configuration. In addition we will see how to make use of *data sources* and manage *explicit depenendcies* between resources.

## Adding entitlements, subscriptions and service instances 🛠️

### The backlog of resources

Up to now we have configured a new subaccount. Now we want to add some more resources to it namely:

- Entitlements for the alert-notfication service, the feature-flag service as well as the feature-flag dashboard application
- A service instance of the alert-notfication service
- A subscription of the feature-flag dashboard application

Some stuff to do, but we can manage that step by step. We already know that we find these resources in the Terraform documentation, so let us get started

### Adding entitlements

As we want to add entitlements in our newly created subaccount, the fitting resource is [`btp_subaccount_entitlement`](https://registry.terraform.io/providers/SAP/btp/latest/docs/resources/subaccount_entitlement).

Looking at the required attributes we see that we basically need the `subaccount_id`, the `service_name` and the `plan_name`. The list of services does not have a numerical quota, so that's all we need.

However, one question is where we get the ID of the subaccount from. The answer to that one is directly from the resource that we defined as it contains all fields including the computed ones as we see in the documentation of the resource [btp_subaccount](https://registry.terraform.io/providers/SAP/btp/latest/docs/resources/subaccount).

> [!TIP]
> You can also do a check via `terraform show` to see what is available in the state.

Let us add the entitlements by adding the following code to our `main.tf` file:

```terraform
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
  plan_name     = "lite"
}
```

This should give us the entitlements that we need. Let us apply this change to our subaccount. First we do the planning

```bash
terraform plan -out=unit31.out
```

The output should look like this:

TODO picture

Three resources to be added, that is what we expected. We can apply the plan via:

```bash
terraform apply 'unit31.out'
```

The output should look like this:

TODO picture

That worked like a charm. We can of course inspect the state and jump to the cockpit to verify that everything is place.

> [!TIP]
> If you make changes to a configuration, we recommend to avoid big bang approaches but move forward in smaller chunks. This makes it easier to analyze and fix potential errors.

Let us move on to the service instance.

### Adding a service instance

We already know the drill: first we take a look at the documentation to find the fitting resource, in this case [`btp_subaccount_service_instance`](https://registry.terraform.io/providers/SAP/btp/latest/docs/resources/subaccount_service_instance).

Taking acloser look at the [example usage](https://registry.terraform.io/providers/SAP/btp/latest/docs/resources/subaccount_service_instance#example-usage) section, we see that we need a service plan ID to create a service instance. That makes sense, but where to we get this from?

Maybe the entitlements already contain this field, at least there is something promising mentioned in the [documentation](https://registry.terraform.io/providers/SAP/btp/latest/docs/resources/subaccount_entitlement) namely the field `plan_id`. Let us check what is in the state by executing:

```bash
terraform state show btp_subaccount_entitlement.alert_notification_service_standard
```

The result is:

```bash
# btp_subaccount_entitlement.alert_notification_service_standard:
resource "btp_subaccount_entitlement" "alert_notification_service_standard" {
    amount        = 1
    category      = "ELASTIC_SERVICE"
    created_date  = "some date"
    id            = "alertnotificationservicecf"
    last_modified = "some date"
    plan_id       = "alertnotificationservicecf"
    plan_name     = "standard"
    service_name  = "alert-notification"
    state         = "OK"
    subaccount_id = "..."
}
```

That does not look like the technical ID that we need for the service instance creation. What other options do we have?

The Terrafork provider offers besides the resources also so called [*data sources*](https://developer.hashicorp.com/terraform/language/data-sources). Data sources are provided to read data from real-world resources on the platform and use the data in the Terraform configuration.

Indeed there is a data source that should help us namely [`btp_subaccount_service_plan`](https://registry.terraform.io/providers/SAP/btp/latest/docs/data-sources/subaccount_service_plan) which allows us to read the data for a service plan by plan name and offering name.

> [!TIP]
> The real-word resources read via data sources do not need to be managed via Terraform. This is alos the reason why the Terraform provider for SAP BTP has data sources for parts of the SAP BTP that cannot be managed via the resources e.g., entitlements on global account level.

With these two ingredients we can implement the configuration by adding the following code to the `main.tf` file:

```terraform
data "btp_subaccount_service_plan" "alert_notification_service_standard" {
  subaccount_id = btp_subaccount.project_subaccount.id
  name          = "standard"
  offering_name = "alert-notification"
}

resource "btp_subaccount_service_instance" "alert_notification_service_standard" {
  subaccount_id  = btp_subaccount.project_subaccount.id
  serviceplan_id = data.btp_subaccount_service_plan.alert_notification_service_standard.id
  name           = "${local.service_name_prefix}-alert-notification"
}
```

First we read the service plan ID via the data source specified with the `data` block. We use this information in the corresponding `resource` block that provisions the service instance. To have a consistent naming of the service instances we want to use a prefix that we define in the `locals` block. We add the following code to this block:

```terraform
service_name_prefix  = lower(replace("${var.subaccount_stage}-${var.project_name}", " ", "-"))
```

### Handling of explicit dependencies

### Adding a subscription

## Summary 🪄


## Sample Solution 🛟

You find the sample solution in the folder `units/unit_3_3/solution_u33`.

## Further References 📝

## Outline (to be deleted)

- Add new resources to `main.tf`
- add local service-name-prefix
- Entitlements for 2 services (`alert-notification`, `feature-flags`) and 1 app subscription (`feature-flags-dashboard`)
- data source for service plan => depends on entitlement
- Resources for service instance creation alert notification (feature flag only possible with CF)
- Resource for app subscription


> [!NOTE]
> Highlights information that users should take into account, even when skimming.

> [!TIP]
> Optional information to help a user be more successful.

> [!IMPORTANT]
> Crucial information necessary for users to succeed.

> [!WARNING]
> Critical content demanding immediate user attention due to potential risks.

> [!CAUTION]
> Negative potential consequences of an action.
