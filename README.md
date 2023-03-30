# dr-detection-deploy

Diabetic Retinopathy detection with Deep Learning on AWS, using containers and IaC.


## About
This repository presents a solution to deploy deep learning models capable of detecting diabetic retinopathy on AWS. For this purpose, we use both the serverless inference and real-time inference services, from the Sagemaker platform. All the infrastructure is described with Terraform, so the solution can be replicated at ease. Optimizations and experiments have been made to enhance both the performance and cost of the proposed infrastructure. It can be used with any tensorflow based model without any modification.


## Repository structure
The repository is organized as follows:
- experiments: contains scripts to perform experiments about provisioned endpoints and the results obtained. The scripts used to generate
- infrastructure: contains terraform code used to provision the required infrastructure to perform inference
- src: contains Python code used to provide an API capable of serving deep learning models inferences. The code implements the sagemaker BYOC (Bring Your Own Container) [interface](https://docs.aws.amazon.com/sagemaker/latest/dg/your-algorithms-inference-code.html), needed for both serverless and real-time inference.
- models: contains the models used in experiments
- images: contains some images from the [APTOS dataset](https://kaggle.com/competitions/aptos2019-blindness-detection), used to perform inferences when testing.

## How to run the container locally?

First, you need to build the image, by issuing the following command on root folder: ```docker build -t dr-detection-deploy .```. Then, you can run the container using the same command that sagemaker runs: ```docker run dr-detection-deploy serve```. This will initialize the container, so that inference is available by the ```POST /invocation``` endpoint.

## How to create infrastructure/deploy the solution?

First, you need to configure AWS keys, so Terraform can make API calls to AWS on your behalf. To do this, you can follow the tutorial: [How can I create Access Keys](https://repost.aws/knowledge-center/create-access-key), then, these keys needed to be configured for the aws sdk, the tutorial is available [here] (https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html).

All the infrastructure code is defined in the infrastructure directory, so all the next commands assume that the current dir is ./infrastructure. To provision the infrastructure we need to:
1. ```Terraform init```: This will initialize terraform state and install all the needed providers, with all the modules referenced in main.tf.
2. ```Terraform apply```: This will generate a plan, to match configuration and AWS resources. After reading it, you must accept and wait until the changes are applied.

After uploading some new model artifact (in this case, tensorflow SavedModel) to S3, or uploading a new image version to ECR, a new endpoint must be created to reflect new changes. To do this, new endpoints can be created in main.tf, followed by ```terraform apply```.

## How can I upload a new Docker image to ECR?
To do this, the ./build-and-push.sh script can be used. It builds a image, gains authorization to upload to the private ECR described with terraform and then uploads the recently built image.
