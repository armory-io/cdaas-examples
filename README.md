![Armory Logo](./assets/armory.svg)

# Armory CDaaS Examples

This repository contains example deployments and walkthroughs for [Armory Continuous Deployments-as-a-Service](https://docs.armory.io/cd-as-a-service/).
CDaaS is a tool for safely deploying artifacts like Docker images and Kubernetes manifests into application environments.

## Getting Started

1. **Install:**
    
    Install `armory` on Mac OS using [Homebrew](https://brew.sh/):

    ```shell
   brew tap armory-io/armory
   brew install armory-cli
   ```

    To install `armory` on Linux, run the following:

    ```shell
    curl -sL go.armory.io/get-cli | bash
    ```

    The script will install `armory` and `avm`. You can use `avm` (**A**rmory **V**ersion **M**anager) to manage your `armory` version. 


3. **Sign up:**

    It's free to try Armory CDaaS:

    ```shell
    armory login
    ```

    Confirm the device code in your browser when prompted, sign up for an Armory CDaaS account, then return to this guide.


5. **Connect your cluster:**
    
    CDaaS uses an agent to execute deployments in your Kubernetes cluster. Your cluster's API endpoint does not need
    to be publicly accessible to use CDaaS. Learn more about CDaaS [architecture](https://docs.armory.io/cd-as-a-service/concepts/architecture).

    Run the following command to install an agent in your Kubernetes cluster:

    ```shell
    armory agent create
    ```

6. **Deploy:**

    The [Hello Armory](/hello-armory) tutorial is a great place to start. Happy deploying!
