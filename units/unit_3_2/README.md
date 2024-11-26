# Unit 3.2 - Using Locals

## Goal 🎯

The goal of this unit is to enhance the Terraform configuration with locals and to combine several variables into locals by using functions.


## Transforming values with local variables 🛠️

In our company the creation of BTP subaccounts is triggered by teams, that work in projects along the 3 stages DEV, TEST and PROD.

We want to reflect this in our Terraform script and we want to reduce the necessary input from us to a minimum in order to create a subaccount.
Therefore, we have the following requirements for creating a BTP subaccount:
- the only input we want to make is the input of the `stage` and the `project name`.
- the `subaccount domain` should be derived from the `subaccount name` and be unique in our BTP landscape
- the `beta` flag for our BTP subaccount should only be set, if the stage was not set to `PROD`.

### Building the subaccount name

We want the Terraform script to create subaccounts that should be named according to this pattern: <stage> <project name> (e.g. "DEV interstellar").

To achieve this, we will now open the `main.tf` file and add the following section:

```terraform
locals {
  subaccount_name      = "${var.subaccount_stage} ${var.project_name}"
}  
```

The section `locals` defines all variables that can be used in the script via the `local.` prefix (instead of the `var.` prefix for the variables defined in the `variables` file).
The code also shows, how the variable `subaccount_stage` and `project_name` are joined.

Now we need to substitute in the section for the subaccount creation the `var.subaccount_name` with `local.subaccount_name` so that our `main.tf` file looks like this:

```terraform
locals {
  subaccount_name      = "${var.subaccount_stage} ${var.project_name}"
}

resource "btp_subaccount" "project_subaccount" {
  name         = local.subaccount_name
  subdomain    = var.subaccount_subdomain
  region       = var.subaccount_region
  beta_enabled = var.subaccount_beta_enabled
  labels = {
    "stage"      = [var.subaccount_stage]
    "costcenter" = [var.project_costcenter]
  }
}
```

Now that the `subaccount_name` variable is not needed, and we instead use a `project_name`, we need to adapt our `variables.tf` file accordingly. 
Let's simpy rename the variable `subaccount_name` to `project_name`:

```terraform
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "Project ABC"
}
```

Now let's tackle the creation of the subaccount domain.

### Creating the subaccount domain

The BTP subaccount domain is a unique name with the BTP  landscape in a specific region. To make our BTP subaccount domain unique we will use one Terraform resource called `random_uuid`. So, let's add in the `main.tf` file at the top the following line:

```terraform
resource "random_uuid" "uuid" {}
```

This will call the Terraform resource `random_uuid` and create a random uuid, that can be used in another local variable for building the subaccount domain.

So, we will add another code line into the locals section to build the `subaccount_domain`.

```terraform
locals {
  subaccount_name      = "${var.subaccount_stage} ${var.project_name}"
  subaccount_subdomain = join("-", [lower(replace("${var.subaccount_stage}-${var.project_name}", " ", "-")), random_uuid.uuid.result])
}
```

We use the `join` function, to combine two strings with a `-`. 

The first string takes the `subaccount_stage` and the `project_name` variable that are connected via a `-`. In addition the `replace` function ensures, that all spaces (` `) are replaced with a `-`. As a last part of the first string, the resulting string will be converted with the function `lower` to lower case.

The second string is the result of the `random_uuid.uuid`.

With this improvement, we no longer need to define our unique subaccount domain. Our Terraform script is doing that for us along the requirements we have defined.

Let's quickly replace `var.subaccount_subdomain` with `local.subaccount_subdomain` in the resource section for  `btp_subaccount`.

Now there is one last thing we need to do. 

### Setting the beta flag of the subaccount

We want the script to setup the beta flag automatically, depending on the stage. We do that in three steps. 

In the first step we add the following line into the `locals` section of the `main.tf` file.

```terraform
  beta_enabled         = var.subaccount_stage == "PROD" ? false : true
```

This line defines the `beta_enabled` local variable, that is set to `false` if the `subaccount_stage` is `PROD`. For all other stages, it is set to `true`.

Now we replace the respective line for setting up the `beta_enabled` flag with the local variable for `beta_enabled`, so that our `main.tf` file looks like this now:

```terraform
resource "random_uuid" "uuid" {}

locals {
  subaccount_name      = "${var.subaccount_stage} ${var.project_name}"
  subaccount_subdomain = join("-", [lower(replace("${var.subaccount_stage}-${var.project_name}", " ", "-")), random_uuid.uuid.result])
  beta_enabled         = var.subaccount_stage == "PROD" ? false : true
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
```

Finally, we can now remove the definition of the variable `subaccount_beta_enabled` from our `variables.tf` file, as that variable is no longer needed.

### Applying all our changes

Now that we made the changes, let's see what happens. 

As we have introduced a new resource for the `rando_uuid`, we need to run first:

```terraform
terraform init
```

Now let's see that happens if we let Terraform plan the changes:

```terraform
terraform plan
```

We see that the subaccount will be deleted and created again, as we have assigned a different subdomain to it.

> [!IMPORTANT]
> Always the cautios, when the Terraform plan tells you it will detroy something. This can have serious impact on your landscape and may result in loss of important data or services within a subaccount!

As we are sure, that this is what we want, we will now apply the changes:

```terraform
terraform apply
```

If you now switch back to your SAP BTP cockpit, checkout the subaccount and you will see, that the `Subdomain` domain was created according to the definition in our locals section.
The same is true as well for the subaccount name.


## Summary 🪄

Locals are a great way to make your Terraform configuration rock-solid and use them to apply naming conventions to your BTP landscape.


## Sample Solution 🛟

You find the sample solution in the folder `units/unit_3_2/solution_u32`.

## Further References 📝


## Outline (to be deleted)

- Some variables are a bit redundant
- Naming conventions
- create a local variable deriving beta enabled
- subaccount name with naming convention (DEV_subaccount name)

For subdomain

- Step 1 construct it
- Step 2 introduce UUID

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
