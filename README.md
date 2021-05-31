# AWS ECS Anywhere on Equinix Metal
This repository includes a set of Terraform configuration files to deploy [ECS Anywhere](https://aws.amazon.com/blogs/aws/getting-started-with-amazon-ecs-anywhere-now-generally-available/) in Equinix Metal. We've included all the resources you'll need to deploy and end-to-end solution where you can use a direct and private line to AWS from Equinix Metal using the Equinix Platform. You can even find a demo application to confirm that everything you deploy works and then adapt the configuration files to your needs. You can find more information about [ECS Anywhere and Equinix metal in the Equinix blog](https://blog.equinix.com/blog/2021/04/19/amazon-elastic-container-service-ecs-anywhere-accelerates-digital-business/).

## Pre-Requisites

Before you can start, you need to have the following:

* An AWS account
* An AWS secret and access key combo for a user with enough permissions (see what's being deployed below)
* Configure Terraform properly to provision infrastructure in your AWS account
* An Equinix Metal org-id and [API key](https://metal.equinix.com/developers/api/)
* An Equinix Fabric account to deploy Fabric and Network Edge resources
* An Equinix Metal connection, and include the ECX Token as the `eqx_metal_token` variable

## What's Being Deployed?

If you decide to use the Terraform configuration files from this repository, you'll create the following:

* An SSM activation pair to properly connect the ECS agent(s)
* An ECS cluster that we'll use to register the ECS agent(s) running in a Metal server
* An EC2 instance that we can use for connectivity tests from Metal to AWS and viceversa
* An SQS queue for our demo application that we'll deploy to confirm everything is working
* VPC endpoints to interact privately from Metal servers with any AWS service (primarily ECS and SQS)
* IAM roles and policies that we need to create an ECS task and register the ECS agent(s)
* A Network Edge device in Equinix Platform
* Two Equinix Fabric connections, one for AWS and another one for Metal
* Equinix Metal servers where we'll deploy the ECS agent

Feel free to adapt the configuration files at your need, you might not need to deploy all the resources defined here but we suggest you first deploy the infrastructure as it is, confirm that everything works, then adapt it.

## How to Deploy?
The first step is to provision the Equinix Network Edge device and the Fabric connections to Equinix Metal and AWS.

You also need to generate a Client ID and Secret Key in the Developer Equinix portal, [you can follow the official instructions from the documentation](https://developer.equinix.com/docs/ecp-getting-started).

Then, you need to go to your Equinix Metal console and create `Connection` to Fabric, make sure you save the token because you'll use it to fulfil the `eqx_metal_token` variable. You can [see the official docs](https://metal.equinix.com/developers/docs/networking/fabric/) for the instructions for requesting a Fabric connection*. 

**&ast;_The Equinix Metal support team needs to approve the connection request to Fabric, this could take up to 48 hours._**

Then, you need create a `terraform.tfvars` file like the one below, and fill all the missing values:

```
worker_count            = 0
cluster_name            = "cm-ecs-any"
metro                   = "am"
facility                = "AM6"
worker_plan             = "c3.small.x86"
cluster_private_network = "192.168.48"
metal_asn               = "65000"

eqx_seller_ne_metro_code    = "AM"
eqx_seller_aws_metro_code   = "AM"
eqx_seller_metal_metro_code = "AM"
eqx_fabric_speed            = "200"
eqx_fabric_speed_unit       = "MB"
eqx_ne_throughput           = 500
eqx_ne_throughput_unit      = "Mbps"
eqx_account                 = "133002"
eqx_device_hostname         = "ecsany"
eqx_ne_acl_template_name    = "ecsanymet"
eqx_ne_ssh_user             = "ecsany9"
eqx_ne_ssh_pwd              = "ecsanymet"

aws_region                      = "eu-central-1"
aws_network_cidr                = "172.16.0.0/16"
aws_subnet1_cidr                = "172.16.0.0/24"
aws_dx_bgp_equinix_side_asn     = 65432
aws_dx_bgp_authkey              = "Vz8PmPjOvq"
aws_dx_bgp_amazon_address       = "169.254.235.17/30"
aws_dx_bgp_equinix_side_address = "169.254.235.18/30"

project_id                        = "EQUINIX METAL PROJECT ID"
auth_token                        = "EQUINIX METAL TOKEN API"
aws_account                       = "AWS ACCOUNT NUMBER"
aws_access_key                    = "AWS ACCESS KEY TO APPROVE DX CONNECTIONS"
aws_secret_key                    = "AWS SECRET KEY TO APPROVE DX CONNECTIONS"
eqx_consumer_key                  = "EQUINIX PLATFORM KEY"
eqx_consumer_secret               = "EQUINIX PLATFORM SECRET"
eqx_notification_users            = ["YOUR EMAIL ADDRESS"]
eqx_metal_token                   = "EQUINIX METAL TOKEN CONNECTION"
```

Feel free to change any of the values above like the location or CIDRs.

Finally, you run next commands to initialize terraform project and to create the resources.

```sh
terraform init
terraform apply
```

Once you've received a notification from the Equinix Metal support team that the connection request has been approved, you should manually associate the VLAN that Terraform has created in the previous step to the connection. Go to your Equinix Metal console and identify the VLAN number at `IP & Networks => Layer 2` or take it from the terraform output of the previous step. Then, you need to associate that VLAN to the Fabric connection you created manually.[All the details are in the official docs site](https://metal.equinix.com/developers/docs/networking/fabric/#finalizing-the-connections-and-adding-a-vlan).

***DO NOT PROCEED UNTIL THE CONNECTION HAS THE VLAN ATTACHED!***

To notify terraform that the VLAN is already attached you should update your `terraform.tfvars` file including the variable described below:

```
metal_connection_is_vlan_attached = true // WE CAN'T CREATE ALL RESOURCES FROM SCRATCH AS THERE ARE SOME MANUAL STEPS WE NEED TO PERFORM. SET TRUE ONLY ONCE THE EQUINIX FABRIC CONNECTION FOR EQUINIX METAL IS APPROVED AND HAS THE VLAN ATTACHED, AS DESCRIBED IN STEP 2
```

Now, run the following commmand:

```sh
terraform apply
```

You should have now everything you need to run ECS Anywhere in Equinix Metal.

## Deploy a Demo Application

We're going to be using the same application that the AWS team used to demonstrate ECS Anywhere. But first, you need to build the Docker image and push it to the ECR you created previously with Terraform. To do so, simply run the following commands:

```
aws ecr get-login-password --region $(terraform output -raw aws-region) | docker login --password-stdin --username AWS $(terraform output -raw ecr-url)
docker build -t $(terraform output -raw ecr-url) ./app
docker push $(terraform output -raw ecr-url)
```

Now you need to deploy the ECS task and a service to deploy the application in ECS. To do so, run the following commands:

```
sed -e s#CHANGEME_IMAGE#$(terraform output -raw ecr-url)# \
    -e s#CHANGEME_EXECUTION_ROLE_ARN#$(terraform output -raw iam-exec-role)# \
    -e s#CHANGEME_TASK_ROLE_ARN#$(terraform output -raw iam-task-role)# \
    -e s#CHANGEME_AWSLOGS_GROUP#"ecs-external-"$(terraform output -raw ecs-cluster)# \
    -e s#CHANGEME_REGION#$(terraform output -raw aws-region)# \
    -e s#CHANGEME_SQS_QUEUE_URL#$(terraform output -raw sqs-url)# \
    templates/ecs_task_definition-template.json > ecs_task_definition.json
aws ecs register-task-definition --cli-input-json file://ecs_task_definition.json --region $(terraform output -raw aws-region)
aws ecs create-service --service-name ecsworker-external-service --cluster $(terraform output -raw ecs-cluster) --launch-type EXTERNAL --desired-count 1 --task-definition ecsworker-external --region $(terraform output -raw aws-region)
```

You can verify now in the AWS console that the ECS task is running.

## Testing

Once the application is running, you can test the application by SSHing into the Metal servers. You need to start by creating some files that the application will process in the `/data/sourcefolder`. Run the following command:

```
for i in `seq 10 20`; do touch /data/sourcefolder/0$i; done
```

Let's keep an eye open to watch what happens in the `/data/sourcefolder` folder:

```
watch ls -la /data/sourcefolder/
```

Open a new terminal tab (or Window) to watch the `/data/destinationfolder` folder:

```
watch ls -la /data/destinationfolder/
```

Now send some messages to the SQS queue, like this:

```
for i in `seq 10 20`; do aws sqs send-message --queue-url $(terraform output -raw sqs-url-public) --region $(terraform output -raw aws-region) --message-body "0$i"; done
```

You should see how the files are moving from the source folder to the destination folder.

## Cleanup

After you've finished with your tests, you can delete all the resources by running the following commands:

```
aws ecs delete-service --cluster $(terraform output -raw ecs-cluster) --service ecsworker-external-service --region $(terraform output -raw aws-region) --force
aws ecs deregister-task-definition --cli-input-json file://ecs_task_definition.json --region $(terraform output -raw aws-region)
terraform destroy
```