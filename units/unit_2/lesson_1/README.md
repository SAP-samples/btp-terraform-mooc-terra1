# Unit 2 Lesson 1 - Configuring the first basic Terraform setup

## Goal 🎯

The goal of this unit is to have a basic configuration of a Terraform provider in place. This is the prerequisite for any Terraform configuration.

## Setting up the provider configuration 🛠️

### The Terraform provider configuration

As we are starting from scratch, create a new directory called `learning-terraform-on-sapbtp`. If you have cloned the repository you can place it in the root directory of the cloned repository.

Navigate into the newly created directory and create an empty file called `provider.tf`. This file will contain the configuration of the Terraform provider for SAP BTP.

Open the file and add the following code:

```terraform
terraform {
  required_providers {
    btp = {
      source  = "SAP/btp"
      version = "~> 1.13.0"
    }
  }
}
```

This code block tells Terraform what providers are required for the application of the configuration that we will build during the course of this learning. As we will need the Terraform provider for SAP BTP we specify:

- The `source` attribute tells Terraform where to fetch the provider from. We set `SAP/btp` as value. This will advice Terraform to look for this provider in the [public Terraform registry](https://registry.terraform.io/).
- The `version` attribute lets us define a version constraint for the provider. This constraint is especially useful to avoid unwanted upgrades of the provider version. We set it to the latest available version and make sure that only patch versions are considered in upgrades by specifying `~>` as operator.

In addition to telling Terraform which provider to use, the provider usually also needs a provider-specific configuration. This configuration mainly comprises the authentication information needed for Terraform to communicate with the platform. You find the required information in the documentation of the specific provider. In case of the Terraform provider for SAP BTP you find it in the [main section of the documentation](https://registry.terraform.io/providers/SAP/btp/latest/docs).

We see that the only required parameter is the *subdomain* of the global account we are using. Therefore we add the following code at the end of the `provider.tf` file:

```terraform
provider "btp" {
  globalaccount = "<MY GLOBAL ACCOUNT SUBDOMAIN>"
}
```
Replace the `<MY GLOBAL ACCOUNT SUBDOMAIN>` with the subdomain of your global account. For a trial account the subdomain has the format `123abc456trial-ga`. Save the changes in the `provider.tf` file.

With this configuration we told Terraform which provider and provider version to use as well as how to configure the provider. However, how does Terraform know how to do the authentication to SAP BTP? Let us take a look at this in the next section.

### Setting of environment variables

In general the Terraform provider for SAP BTP provides several ways to do the authentication. You find the list in the documentation of the [optional parameters](https://registry.terraform.io/providers/SAP/btp/latest/docs#optional) of the Terraform provider. In this tutorial we will use the authentication via username and password. As a good practice we provide this values via environment variables that will be fetched by the provider during execution. As described in the documentation we must set values for `BTP_USERNAME` and `BTP_PASSWORD`.

Setting the values depends on the operating system you are using:

- On Windows:

   ```pwsh
   $env:BTP_USERNAME=<MY SAP BTP USERNAME>
   $env:BTP_PASSWORD=<MY SAP BTP PASSWORD>
   ```
- On MacOS and Linux:

   ```bash
   export BTP_USERNAME=<MY SAP BTP USERNAME>
   export BTP_PASSWORD=<MY SAP BTP PASSWORD>
   ```

> [!IMPORTANT]
> Usually the value for the username is your email. If you have several S- or P-Users in your SAP Universal ID that belong to the same email, use the S- or P-User you use when logging into SAP BTP as username.

As an alternative on MacOS and Linux you can also create a new file called `.env` with the following content

```text
BTP_USERNAME='MY SAP BTP USERNAME'
BTP_PASSWORD='MY SAP BTP PASSWORD'
```

You can then export the two values in one go via:

```bash
export $(xargs < .env)
```

With that the necessary information that enables the provider to execute the authentication is in place.

> [!NOTE]
> Make sure that you followed along the prerequisites with respect to configuring the SAP Universal ID.

## Summary 🪄

We laid the foundation for our Terraform journey, namely the basic configuration of the Terraform provider fro SAP BTP as well as the provisioning of the information needed for authentication.

With that let us continue with [Unit 2 Lesson 2 - Applying the Terraform setup to SAP BTP](../lesson_2/README.md)

## Sample Solution 🛟

You find the sample solution in the directory `units/unit_2/lesson_1/solution_u2_l1`.

## Further References 📝

- [Terraform provider overview](https://developer.hashicorp.com/terraform/language/providers)
- [Terraform provider configuration](https://developer.hashicorp.com/terraform/language/providers/configuration)
- [Terraform block reference](https://developer.hashicorp.com/terraform/language/terraform)
- [Terraform provider for SAP BTP - configuration](https://registry.terraform.io/providers/SAP/btp/latest/docs)
