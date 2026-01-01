
[![REUSE status](https://api.reuse.software/badge/github.com/SAP-samples/btp-terraform-mooc-terra1)](https://api.reuse.software/info/github.com/SAP-samples/btp-terraform-mooc-terra1)

# Getting Started with Terraform on SAP BTP

## Description

This repository contains the code samples used throughout the course "Getting Started with Terraform on SAP BTP".

## Prerequisites

There are some requirements you must fulfill before being able to start with the coding exercises using the Terraform provider for SAP BTP. The prerequisites are:

- You have an SAP BTP Trial Account. If you don't have one yet, you can get one [here](https://developers.sap.com/tutorials/hcp-create-trial-account.html).
- Make sure that your SAP Universal ID is configured correctly. You can find the instructions in [SAP Note 3085908](https://me.sap.com/notes/3085908).
- The Terraform provider does not support 2FA. Make sure that this option is not enforced for your account.

Depending on the setup described in [unit 1 lesson 3](./units/unit_1/lesson_3/README.md) further prerequisites are required:

- If you intend to use the [recommended 'dev container' tools option](./units/unit_1/lesson_3/README.md) you must have [Docker Desktop](https://www.docker.com/products/docker-desktop/) and [Visual Studio Code](https://code.visualstudio.com/) including the [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension installed on your machine.
- You want to use A GitHub Codespace you must have a GitHub user. If you don't have one, [sign-up on GitHub](https://github.com/signup).

## Content Structure

The repository is structured in line with the layout of the course. The walkthrough of the code for every lesson is described in an extensive `README.md`. We also provide the solution for each lesson as part of the corresponding directory in this repository.

### Unit 1 - Getting Started with Infrastructure as Code

- [Lesson 3 - Preparing the setup for Terraform on SAP BTP](./units/unit_1/lesson_3/README.md)

### Unit 2 - Setting Up a First Terraform Configuration

- [Lesson 1 - Configuring the first basic Terraform setup ](./units/unit_2/lesson_1/README.md)
- [Lesson 2 - Applying the Terraform setup to SAP BTP](./units/unit_2/lesson_2/README.md)
- [Lesson 3 - Inspecting the Terraform state](./units/unit_2/lesson_3/README.md)

### Unit 3 - Enhancing the Terraform Configuration

- [Lesson 1 - Using Variables in a Terraform Configuration](./units/unit_3/lesson_1/README.md)
- [Lesson 2 - Using Locals in a Terraform Configuration](./units/unit_3/lesson_2/README.md)
- [Lesson 3 - Adding Multiple Resources to the Terraform Configuration](./units/unit_3/lesson_3/README.md)
- [Lesson 4 - Setting up a Cloud Foundry Environment via Terraform](./units/unit_3/lesson_4/README.md)

### Unit 4 - Applying Advanced Terraform Concepts

- [Lesson 1 - Enhancing the Setup with Additional Providers](./units/unit_4/lesson_1/README.md)
- [Lesson 2 - Handing over to the development team](./units/unit_4/lesson_2/README.md)
- [Lesson 3 - Extracting Reuseable Logic into Modules](./units/unit_4/lesson_3/README.md)
- [Lesson 4 - Iterating over Lists in Terraform](./units/unit_4/lesson_4/README.md)

## Support, Feedback, Contributing

❓ - If you have a *question* you can ask it here in [GitHub Discussions](https://github.com/SAP-samples/btp-terraform-mooc-terra1/discussions/) or in the [SAP Community](https://answers.sap.com/questions/ask.html).

🐞 - If you find a bug, feel free to create a [bug report](https://github.com/SAP-samples/btp-terraform-mooc-terra1/issues/new?assignees=&labels=bug&projects=&template=bug_report.yml&title=%5BBUG%5D).

## Contributing
If you wish to contribute code, offer fixes or improvements, please send a pull request. Due to legal reasons, contributors will be asked to accept a DCO when they create the first pull request to this project. This happens in an automated fashion during the submission process. SAP uses [the standard DCO text of the Linux Foundation](https://developercertificate.org/).

## License
Copyright (c) 2026 SAP SE or an SAP affiliate company. All rights reserved. This project is licensed under the Apache Software License, version 2.0 except as noted otherwise in the [LICENSE](LICENSE) file.
