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

We want the Terraform script to create subaccounts that should be named according to this pattern: <stage> <project name> (e.g. "DEV interstellar")

To achieve this, we will now open the `main.tf` file and add the following section:

```terraform
locals {
  subaccount_name      = "${var.subaccount_stage} ${var.project_name}"
}  
```

The section `locals` defines all variables that can be used in the script via the `local.` prefix (instead of the `var.` prefix for the variables defined in the `variables` file).
The code also shows, how the variable `subaccount_stage` and `project_name` are joined.

Now let's tackle the creation of the subaccount domain.

### Creating the subaccount domain

The BTP subaccount domain is a unique name with the BPT landscape in a specific region. To make our BTP subaccount domain unique we will use one Terraform ressource called `random_uuid`. So, let's add at the top 



### Setting the beta flag of the subaccount


Let's now 


- the subaccount domain should be unique and be named according to this pattern <stage>-


locals {
  subaccount_name      = "${var.subaccount_stage} ${var.project_name}"
  subaccount_subdomain = join("-", [lower(replace("${var.subaccount_stage}-${var.project_name}", " ", "-")), random_uuid.uuid.result])
  beta_enabled         = var.subaccount_stage == "PROD" ? false : true
}

Therefore, we want to adapt our Terraform scripts accordingly, so that the subaccount name




```bash
terraform plan
```

## Summary 🪄


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
