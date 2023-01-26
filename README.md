# Armory CDaaS Examples

This repository contains example deployments and walkthroughs for [Armory Continuous Deployments-as-a-Service](https://docs.armory.io/cd-as-a-service/).
CDaaS is a tool for safely deploying artifacts like Docker images and Kubernetes manifests into application environments.

## Getting Started

1. **Install:**

    To install `armory`, run the following:

    ```shell
    curl -sL go.armory.io/get-cli | bash
    ```

    The script will install `armory` and `avm`. You can use `avm` (**A**rmory **V**ersion **M**anager) to manage your `armory` version. 

2. **Sign up:**

    It's free to try Armory CDaaS. Run the following command to sign up:

    ```shell
    armory login
    ```

    Confirm the device code in your browser when prompted, then sign up for an Armory CDaaS account.

3. **Deploy:**

    The [hello-world](/hello-world/README.md) tutorial is a great place to start. Happy deploying!
