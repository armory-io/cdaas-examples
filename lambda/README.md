# AWS Lambda

This is a work in progress. 

Before starting, make sure you have updated your `armory` CLI to at least v1.15.0.

## Create a deployment role

Armory will use the generated role to deploy Lambda functions to your AWS account.

Using the `armory` CLI, run the following command and follow the instructions in the prompt:

```shell
armory aws create-role
```

In the "Resources" tab of the generated CloudFormation stack, click on `ArmoryRole`. Copy the role's ARN.

## Create a Lambda role

Navigate to the IAM section of the AWS console. Under "Roles", click "Create Role". Click on "Lambda" under "Common use cases", follow the instructions,
then copy the role's ARN.

## Push function code to S3

The file [`resources/index.js`](./resources/index.js) contains code for a NodeJS lambda function.

Run the following to upload the code to your S3 bucket:

```shell
zip resources/function.zip resources/index.js
aws s3 cp resources/function.zip s3://$USER-$(date +'%m-%d-%Y')/node/v0.0.1.zip
```

## Deploy

In [lambda-deployment.yaml](./lambda-deployment.yaml), fill in your role ARNs and S3 bucket.

Run `armory deploy start -f ./lambda.yaml` to start your deployment.