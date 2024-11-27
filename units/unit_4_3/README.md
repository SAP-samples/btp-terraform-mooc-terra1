# Unit 4.3 - Extracting reuseable logic into modules

## Goal 🎯

The goal of this unit is to make the code better maintainable and re-usable by moving some of our code into modules.

## Refactoring with modules 🛠️

Our project code has grown and we want to re-factor it, so that we can better re-use and maintain the code.
For that we  will move out some of out code into a module.

According to the [official Terraform documentations for modules](https://developer.hashicorp.com/terraform/language/modules): "*Modules are containers for multiple resources that are used together. A module consists of a collection of .tf and/or .tf.json files kept together in a directory. Modules are the main way to package and reuse resource configurations with Terraform.*".

And we will take advantage of this concept by moving all of the code into a module that contains a baseline with those BTP services we want to have in subaccounts. 

We will do this in three steps:
- create a module folder and move the code to that folder which takes care of the app/service entitlements, service instances and app subscriptions.
- create a set of variables in that module to trigger the provisioning of the services/apps in the module
- change the `main.tf` file to call the module
- ensure that our state information remains stable after the changes

### Creating a module folder for the service baseline

In a first step we create a folder `modules` and a subfolder called `srvc-baseline`.

In the `srvc-baseline` we create two new files:
- `srvc-baseline_variables.tf`: this file will create the variables for our module
- `srvc-baseline.tf`: this file contains the main script of the module

Now we copy-and-paste the code from our `main.tf` file that takes care of the entitlements, service instance creation and the app subscriptions into the `srvc-baseline.tf` file (and save it), so that the `srvc-baseline.tf` file looks like this:

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

resource "btp_subaccount_entitlement" "feature_flags_dashboard_app" {
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

resource "btp_subaccount_subscription" "feature_flags_dashboard_app" {
  subaccount_id = btp_subaccount.project_subaccount.id
  app_name      = "feature-flags-dashboard"
  plan_name     = "dashboard"
  depends_on    = [btp_subaccount_entitlement.feature_flags_dashboard_app]
}
```

Now please delete the section in the `main.tf` file (and save the changes) that we just copied over to the `srvc-baseline.tf` file in the `modules/srvc-baseline` folder.

> [!IMPORTANT]
> Please don't forget to delete the code in `main.tf` that you have copied over!

As the module is a self-contained asset, we need to ensure that it contains all information needed, to be executed. Therefore, we will have to add a section for the provider information as well. For that, please add the following lines into the `srvc-baseline.tf` file:

```terraform
terraform {
  required_providers {
    btp = {
      source = "SAP/btp"
    }
  }
}
```
> [!TIP]
> We could have created a separate provider.tf for that purpose as well within the folder. But as we don't have to provide the provider configuration (this is something we already do in our main terraform script), we can at it to the `srvc-baseline.tf` file.

Now we have to move the definition of the local variable `service_name_prefix` from the  `main.tf` file to the `srvc-baseline.tf` file, so that the file looks like this:

```terraform
terraform {
  required_providers {
    btp = {
      source = "SAP/btp"
    }
  }
}

locals {
  service_name_prefix = lower(replace("${var.project_stage}-${var.project_name}", " ", "-"))
}

resource "btp_subaccount_entitlement" "alert_notification_service_standard" {
  subaccount_id = var.subaccount_id
  service_name  = "alert-notification"
  plan_name     = "standard"
}
...
...
...
```

Please delete the `service_name_prefix` variable from the `main.tf` file, so that the `locals` section in the `main.tf` file looks like this:

```terraform
locals {
  subaccount_name      = "${var.subaccount_stage} ${var.project_name}"
  subaccount_subdomain = join("-", [lower(replace("${var.subaccount_stage}-${var.project_name}", " ", "-")), random_uuid.uuid.result])
  beta_enabled         = var.subaccount_stage == "PROD" ? false : true
  subaccount_cf_org    = lower(replace("${var.subaccount_stage}-${var.project_name}", " ", "-"))
}
```

That was a big piece of work here. Now let's tackle the next step.

### Create a variables file for the module

To make the module self contained, we need to provide it with those variables, that it needs to work. 

To accomplish this, take the following code and paste it into the `srvc-baseline_variables.tf` file (and save it), that we created before:

```terraform
variable "subaccount_id" {
  description = "The subaccount ID"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "Project ABC"
}

variable "project_stage" {
  description = "Stage of the project"
  type        = string
  default     = "DEV"
  validation {
    condition     = contains(["DEV", "TEST", "PROD"], var.project_stage)
    error_message = "Stage must be one of DEV, TEST or PROD"
  }
}
```

That's all. These three variables are now the parameters, that we will need to provide, when calling this module.

Our work in the module is done. Now we need to call the module from our `main.tf` file.

### Integrating the module into our code

To call our module that will handle the entitlements and provisioning of our BTP services and apps, please add this section into the `main.tf` file:

```terraform
module "srvc_baseline" {
  source        = "./modules/srvc-baseline"
  subaccount_id = btp_subaccount.project_subaccount.id
  project_name  = var.project_name
  project_stage = var.subaccount_stage
}
```

The `module` section has the name `srvc_baseline`, that you can use to work with it later on if needed.
The `source` attribute tells Terraform where to find the module.

And after the that we see the three variables `subaccount_id`, `project_name` and `project_stage` that we have defined before in our module. These variables are assigned with the variables that are known to the `main.tf` file.

So, you might be asking yourself, whether the code would be working now immediately. But that won't happen. Why?

By creating the module, the state file would no longer be able to tell what was changed.

TODO:
Show terraform plan??

Therefore, there is one last step we need to make, so that the state file knows what we've changed.

## Ensure that our state information remains stable

To tell our state that we have moved certain assets in our code, we need to create a `moved.tf` file in the same folder like the `main.tf` file.

Into that file please copy the following code:

```terraform
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
```

You can see that we are listing up all the resources that we have moved from the `main.tf` to the module `srvc_baseline`.

With this information the state information won't break as we are telling that we have moved certain resources to a different place.

### Test our code

Done. Let's see if things still work. Let's switch to our `learning-terraform-on-sapbtp` folder and run these steps:

```bash
terraform fmt
terraform validate
```

Looks good, the let's apply the change:

```bash
terraform apply
```

The result should look like this:

TODO screenshot

Success, we successfully restructured our code and have now a re-usable module to setup our BTP services and apps!

## Summary 🪄

You have learned now the concept of modules to encapsulate reusable configurations. 

## Sample Solution 🛟

You find the sample solution in the folder `units/unit_4_3/solution_u43`.

## Further References 📝

## Outline (to be deleted)

- Extract Entitlements, service instance creation and app subscription into a module
- Use module in `main.tf`
- Add `moved` block (just copy&paste)
- Execute terraform get and terraform apply to execute move in state


More info on refactoring: https://developer.hashicorp.com/terraform/language/modules/develop/refactoring

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
