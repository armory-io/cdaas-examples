# Hello Armory

Welcome to Armory CDaaS! In this tutorial for CDaaS beginners, you'll accomplish the following:

- Deploy Armory's sample application `potato-facts` to two environments: `staging` and `prod`.
- Use Armory's Cloud Console to approve an environment promotion.
- Observe a traffic split between two application versions.
- Learn CDaaS deployment YAML syntax.

### Before you begin

Before you begin, make sure you've completed these steps:

1. **Install:**

   Install `armory` on Mac OS using [Homebrew](https://brew.sh/):

    ```shell
   brew tap armory-io/armory
   brew install armory-cli
   ```

   To install `armory` on Windows or Linux, run the following command:

    ```shell
    curl -sL go.armory.io/get-cli | bash
    ```

   The script will install `armory` and `avm`. You can use `avm` (**A**rmory **V**ersion **M**anager) to manage your `armory` version.


3. **Log In**
    
    Log in with the CLI:

    ```shell
    armory login
    ```
    
    Confirm the device code in your browser when prompted, then return to this guide. 

    If you've arrived at this tutorial without an Armory CDaaS account, that's OK! You can sign up for a free account when you run `armory login`.


5. **Connect your cluster:**

   CDaaS uses an agent to execute deployments in your Kubernetes cluster. Your cluster's API endpoint does not need
   to be publicly accessible to use CDaaS. 

   The installation process will use credentials from your `~/.kube/config` file to install the CDaaS agent. If you
   do not have access to a Kubernetes cluster, consider installing a 
   local [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/) or [Minikube](https://minikube.sigs.k8s.io/docs/start/) cluster.

   Run the following command to install an agent in your Kubernetes cluster:

    ```shell
    armory agent create
    ```

   You will name your agent during the installation process. That name will be referenced as `<my-agent-identifier>` throughout this tutorial.

## First Deployment

Armory's sample application `potato-facts` is a [simple web application](https://github.com/armory-io/potato-facts-go). 
The UI polls the API backend for facts about potatoes and renders them for users.

Your first deployment will deploy the following resources into your Kubernetes cluster:
- Two namespaces: `potato-facts-staging` and `potato-facts-prod`.
- In each namespace, the `potato-facts` application, a Kubernetes `Service`, and a proxy pod that you will use to preview `potato-facts` during a deployment.

### Deploy

Run the following command:

```shell
armory deploy start -f https://go.armory.io/hello-armory-first-deployment --account <my-agent-identifier>
```

Congratulations, you've just started your first deployment with CDaaS! 

You can use the link provided by the CLI to observe your deployment's progression in [Cloud Console](https://console.cloud.armory.io/deployments). 
Your resources will be deployed to `staging`. Once those resources have deployed successfully, CDaaS will deploy to `prod`.

## Second Deployment

CDaaS is designed to help you build safety into your application deployment process. It does so by giving you 
declarative levers to control the scope of your deployment. 

CDaaS has four kinds of constraints that you can use to control your deployment:

- Manual Approvals
- Timed Pauses
- [Webhooks](https://docs.armory.io/cd-as-a-service/tasks/webhook-approval/)
- [Automated Canary Analysis](https://docs.armory.io/cd-as-a-service/setup/canary/)

You can use these constraints _between_ environments and _within_ environments:

- During your next deployment, you will need to issue a manual approval between `staging` and `prod`. 
- Within the `prod` deployment, CDaaS will create a 25/75% traffic split between your application versions. CDaaS will wait for your approval before continuing the deployment.

### Deploy

Before you deploy, use `kubectl` to port-forward `potato-facts` locally:

```shell
kubectl port-forward -n potato-facts-prod proxy 9001:9001
```

_Why do we need to use a proxy `Pod`?_ `kubectl` only port-forwards to individual `Pod`s, 
even when the forwarding target is a `Service`. This makes it impossible to observe a traffic split locally without
a layer of indirection.  

Open `potato-facts` at [http://localhost:9001/ui](http://localhost:9001/ui). The graph plots the ratio of
potato facts served by a given Kubernetes `ReplicaSet`. This ratio will change as your deployment progresses.

Start your second deployment:

```shell

armory deploy start -f https://go.armory.io/hello-armory-second-deployment --account <my-agent-identifier>
```

Use the link provided by the CLI to navigate to your deployment in Cloud Console. Once you're ready, click the "Approve" button
to allow the `prod` deployment to continue.

Return to the [`potato-facts` UI](http://localhost:9001/ui). CDaaS will deploy a new `ReplicaSet` with only one pod
to achieve a 25/75% traffic split between application versions. The ratio of facts served by `ReplicaSet` backends in the graph 
should begin to approach this 25/75% split.

Once you're ready to continue, return to Cloud Console to approve the `prod` deployment. CDaaS will fully shift traffic to the new
application version and tear down the previous application version.

## Deployment YAML

Now that you've used CDaaS to deploy to two environments, let's break down CDaaS's deployment YAML. You can find 
the [full specification on our docs site](https://docs.armory.io/cd-as-a-service/reference/ref-deployment-file/#sections).

### `targets`

In CDaaS, a `target` is an `(account, namespace)` pair where `account` is the name of your agent identifier.

When deploying to multiple targets, you can specify dependencies between targets
using the `constraints.dependsOn` field. In the case of this tutorial, the `prod` deployment will start only when the `staging`
deployment has completed successfully.

```yaml
targets:
  staging:
    # Account is optional when passed as a CLI flag (--account).
    # It's also required if you'd like to deploy to multiple Kubernetes clusters.
    # account: <my-agent-identifier> 
    namespace: potato-facts-staging
    strategy: rolling
  prod:
    namespace: potato-facts-prod
    strategy: trafficSplit
    constraints:
      dependsOn: ["staging"]
      beforeDeployment:
        - pause:
            untilApproved: true
```

### `manifests`

CDaaS can deploy any Kubernetes manifest. You do not need to alter your manifests or apply any special annotations to use CDaaS.

By default, the manifests defined in `path` will be deployed to all of your `targets`. If you want to restrict the targets where a manifest
should be deployed, use the `manifests.targets` field.

A `path` can be a path to an individual file or a directory. Each file can contain one or more Kubernetes manifests.

```yaml
manifests:
  - path: ./manifests/potato-facts-v1.yaml
  - path: ./manifests/potato-facts-service.yaml
  - path: ./manifests/staging-namespace.yaml
    targets: ["staging"]
  - path: ./manifests/prod-namespace.yaml
    targets: ["prod"]
```

### `strategies`

A `strategy` defines how manifests are deployed to a target.

A `canary`-type strategy is a linear sequence of steps. The `setWeight` step defines the ratio of traffic
between application versions. This tutorial will introduce other step types later on.

CDaaS integrates with service meshes like [Istio](https://docs.armory.io/cd-as-a-service/tasks/deploy/traffic-management/istio/) 
and [Linkerd](https://docs.armory.io/cd-as-a-service/tasks/deploy/traffic-management/linkerd/), 
but you do not need to use a service mesh to use a CDaaS `canary` strategy.

```yaml
strategies:
  rolling:
    canary:
      steps:
        # This strategy immediately flips all traffic to the new application version.
        - setWeight:
            weight: 100
  trafficSplit:
    canary:
      steps:
        - setWeight:
            weight: 25
        - pause:
            untilApproved: true
        - setWeight:
            weight: 100
```

## Clean Up

You can clean up the resources created by this tutorial with `kubectl`:

```shell
kubectl delete ns potato-facts-staging potato-facts-prod
```

