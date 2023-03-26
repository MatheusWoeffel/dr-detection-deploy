variable "name" {
    description = "Model's name"
}

variable "image_url" {
    description = "URL of Docker image which must be compliant with sagemaker inference (BYOC)"
}

variable "model_data_url" {
    description = "S3 URL of model artifacts object"
}

variable "role_arn" {
    description = "Models execution role ARN"
}