# Unit 4.1 - Moving to a multi-provider setup

## Goal 🎯

The goal of this unit is to add a *Cloud Foundry* space to the setup as well as assign different roles on space level. To achieve this we will make use of an additional Terraform provider

## Bringing in the Cloud Foundry provider 🛠️

### Multi-provider setup

Taking a look at the Terraform provider for SAP BTP, we see that the coverage of the provider is restricted to the SAP BTP resources. This is by intention to keep the responsibility of the provider well-defined. But SAP BTP offers more than pure SAP BTP resources, namely a Cloud Foundry environment with its specific resources as well as a Kyma environment based on Kubernetes. Can we cover the setup of these environments with Terraform. We can, Terraform enables a multi-provder setup enabling us to combine several providers in a configuration.

For SAP BTP the following two providers are of relevance for the runtimes:

- [The Terraform provider for Cloud Foundry](https://registry.terraform.io/providers/cloudfoundry/cloudfoundry/latest) provided by the Cloud Foundry Foundation
- [The Terraform provider for Kubernetes](https://registry.terraform.io/providers/hashicorp/kubernetes/latest) provided by Hashicorp

As we create a Cloud Foundry environment in the previous unit, we will focus on the Cloud Foundry provider in this course.

As we are starting from scratch, the first thing we need to do is set up the provider configuration.

### Cloud Foundry provider configuration

Following the [provider documentation](https://registry.terraform.io/providers/cloudfoundry/cloudfoundry/latest/docs) we see that we need the Cloud Foundry API URL for the provider configuration. We got this information from the environment instance we created in the previous unit. That is good.

However there is one downside of the provider configuration that comes into our way here: the configuration can only consist of static values that are known from the start. While we could provide this value as a variable there is currently no way to provide this value dynamically during Terraform execution. Consequently, we must split the configuration and add a dedicated new provider setup for the Cloud Foundry specifics.

> [!NOTE]
> This downside is not specific for the setup on SAP BTP, but is also the case for other cloud providers. In the case of Kubernetes it is even recommended to split the provisioning of the cluster from further action in the cluster to avoid unwanted side effects.



### Adding a Cloud Foundry space

### Adding Cloud Foundry space roles

### Applying the change

## Summary 🪄


## Sample Solution 🛟

You find the sample solution in the folder `units/unit_4_1/solution_u41`.

## Further References 📝

## Outline (to be deleted)

- Create a folder for BTP
- Move existing configuration there
- New folder with analog setup for CF space (`main.tf`, `provider.tf`, variables.tf)
- Create a Cloud Foundry space
- Add a user to the space manager and space developer role to user role


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
