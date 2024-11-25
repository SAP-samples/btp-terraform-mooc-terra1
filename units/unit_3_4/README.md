# Unit 3.4 - Setting up a Cloud Foundry environment via Terraform

## Goal 🎯

The goal of this unit is to add a *Cloud Foundry* environment to the setup. In addition we want to explicitly provide the Cloud Foundry specific data like the API endpoint as an output of our Terraform execution.

## Adding a runtime environment 🛠️

### Setting up Cloud Foundry

One central ingredient for the application development on SAP BTP is the availability of a runtime environment. In this unit we will add such an environment namely a Cloud Foundry environment to the configuration.

As before our first stop is the Terraform documentation namely the resource [btp_subaccount_environment_instance](https://registry.terraform.io/providers/SAP/btp/latest/docs/resources/subaccount_environment_instance). This generic resource enables us to create a Cloud Foundry or Kyma environment depending on the parameters provided.

Let us take a closer look at the parameters. It seems like the "usual suspects" that we would expect like `name`, `environment_type`, `service_name` and `plan_name` are expected as laid out in the [example usage](https://registry.terraform.io/providers/SAP/btp/latest/docs/resources/subaccount_environment_instance#example-usage) provided in the documentation.

But there seems to be one special parameter namely the landscape label. We can for sure make that a variable and let the user provide a value for that. But wouldn't it be nice to have some kind of fallback solution and get some default value for that in case nothing was provided.

Let's do that. According to the hint in the example usage we need the data source [btp_subaccount_environments](https://registry.terraform.io/providers/SAP/btp/latest/docs/data-sources/subaccount_environments). This data source gives us all available environments, so we must then filter out the desired one.

As an additional requirement, let us assume that the `name` and the `instance_name` will be provided as a local value namely a combination of `stage`-`project_name`.

With that in mind let us extend the `variables.tf` with the following code to provide the landscape label as an optional parameter

```terraform
variable "cf_landscape_label" {
  type        = string
  description = "The Cloud Foundry landscape (format example us10-001)."
  default     = ""
}
```

We added `default = ""` to make the parameter optional. We save the change and switch over to the `main.tf` file and add a new local. Add the following code to the `locals` section:

```terraform
locals {
  ...
  subaccount_cf_org    = "${var.subaccount_stage}-${var.project_name}"
}
```

Next we add the `btp_subaccount_environment_instance` resource:

```terraform
resource "btp_subaccount_environment_instance" "cloudfoundry" {
  subaccount_id    = btp_subaccount.project_subaccount.id
  name             = local.subaccount_cf_org
  environment_type = "cloudfoundry"
  service_name     = "cloudfoundry"
  plan_name        = "trial"
  landscape_label  = var.cf_landscape_label
  parameters = jsonencode({
    instance_name = local.subaccount_cf_org
  })
}
```

 [!NOTE]
> As the tutorial is intended for the trial landscape we used `trial` as value for `plan_name`. If you are executing the comfiguration you must switch the the value `standard`.

The open point is now: how can we handle the fallback logic regarding the landscape label. The logic would be:

- Fetch the information about the environments via the data source `btp_subaccount_environments`
- If there is no value provided via the variable, use the information from the data source. Sounds like a [ternary expression](https://developer.hashicorp.com/terraform/language/expressions/conditionals) that Terraform provides out of the box.

There is one more thing we need to consider: the data source might return multiple landscape labels for for the Cloud Foundry environment. We decide to use the first one returned by the data source. But can we rely on the sequence returned by the data source? Of course not, so we need to remember the value that we used. It is getting more complicated than expected, but Terraform has a dedicated resource to handle situations like this namely the resource [`terraform_data`](https://developer.hashicorp.com/terraform/language/resources/terraform-data).

Let's refine what we need to do:

- Fetch the information about the environments via the data source `btp_subaccount_environments`
- Determine the landscape label to use
- Use the `terraform_data` resource to store the used landscape label
- Configure the resource with the landscape label stored in the `terraform_data` resource

We are add the following code in the `main.tf` to get the available environments and their data for our subaccount:

```terraform
data "btp_subaccount_environments" "all" {
  subaccount_id = btp_subaccount.project_subaccount.id
}
```

Now we must implement the decision on which landscape label to use:

```terraform
resource "terraform_data" "cf_landscape_label" {
  input = length(var.cf_landscape_label) > 0 ? var.cf_landscape_label : [for env in data.btp_subaccount_environments.all.values : env if env.service_name == "cloudfoundry" && env.environment_type == "cloudfoundry"][0].landscape_label
}
```

Storing the value is achieved via the `input` variable of the `terraform_data` resource. As input we model the condition we described above. In addition, we make use of the [`for`](https://developer.hashicorp.com/terraform/language/expressions/for) expression using it as a [filter](https://developer.hashicorp.com/terraform/language/expressions/for#filtering-elements) to extract the first entry.


Having this in place we modify the resource configuration `btp_subaccount_environment_instance` to use the landscape label from the `terraform_data` resource:

```terraform
resource "btp_subaccount_environment_instance" "cloudfoundry" {
  subaccount_id    = btp_subaccount.project_subaccount.id
  name             = local.subaccount_cf_org
  environment_type = "cloudfoundry"
  service_name     = "cloudfoundry"
  plan_name        = "trial"
  landscape_label  = terraform_data.cf_landscape_label.output
  parameters = jsonencode({
    instance_name = local.subaccount_cf_org
  })
}
```

That was not an easy ride, but we made it. Congrats.

Having an environment instance in place, we would also explicitly return some data explicitly for later use like:

- the landscape label that was used
- The API URL of Cloud Foundry
- The ID of the Cloud Foundry organization

We do not want to inspect the state for that, so what option do we have. We can add [*output values*](https://developer.hashicorp.com/terraform/language/values/outputs)  or outputs which we will do in the next section.

### Adding output to the configuration

Besides input variables and local values, Terraform offers a third "value" category namely output values. These values are intended to make information available on the command line. We can think of them as return values in a programming language.

Technically they are defined by an `output` block  that similar attributes as variables:

- `value` - defines the value to be displayed as output
- `description` - the description for the output value
- `sensitive` - as for variables this marks the value as sensitive data and the Terraform CLI obfuscates the output of the value
- `depends_on` - defines the dependency to other resources. This could be useful in case of outputs from child modules in your configuration

You can also add a custom validation to the output in the form of a [`precondition`](https://developer.hashicorp.com/terraform/language/values/outputs#custom-condition-checks) to capture e.g., assumptions on the setup.

How could that look like in our scenario? The ID of the Cloud Foundry organization as well as the URL of the API endpoint are contained in the labels, while the landscape label can be directly fetched from the resource.

It is good practice to define the outputs in a dedicated file. We therefore add a file called `outputs.tf` to our setup and add the following code to it:

```terraform
output "cf_api_url" {
  value       = jsondecode(btp_subaccount_environment_instance.cloudfoundry.labels)["API Endpoint"]
  description = "The Cloud Foundry API URL"
}

output "cf_org_id" {
  value       = jsondecode(btp_subaccount_environment_instance.cloudfoundry.labels)["Org ID"]
  description = "The Cloud Foundry organization ID"
}

output "cf_landscape_label" {
  value       = btp_subaccount_environment_instance.cloudfoundry.landscape_label
  description = "The Cloud Foundry landscape label"
}

```

We save the changes. We have everything in place now and can execute the Terraform flow another time.

### Applying the change

According to our muscle memory we first do the usual homework namely:

```bash
terraform fmt
terraform validate
```

No errors in the validation, then let's move forward and execute the planning:

```bash
terraform plan -out=unit34.out
```

The result should look like this:

TODO picture

Looks as expected, let's apply the change then:

```bash
terraform plan 'unit34.out'
```

The result should look like this:

TODO picture

Looks good. It was a bit more work than we expected, but here we are having a Cloud Foundry environment in our subaccount.

## Summary 🪄

We added a Cloud Foundry environment to our setup. In the course of providing the environment we learned how to fetch and store environment-specific information in accordance to the Terraform lifecycle. In addition, we learned how to add explicit output values to our configuration.

With that let us continue with [Unit 4.1 - Moving to a multi-provider setup](../unit_4_1/README.md)

## Sample Solution 🛟

You find the sample solution in the folder `units/unit_3_4/solution_u34`.

## Further References 📝

- [Conditionals](https://developer.hashicorp.com/terraform/language/expressions/conditionals)
- [`terraform_data`](https://developer.hashicorp.com/terraform/language/resources/terraform-data)
- [`for` expression](https://developer.hashicorp.com/terraform/language/expressions/for)
