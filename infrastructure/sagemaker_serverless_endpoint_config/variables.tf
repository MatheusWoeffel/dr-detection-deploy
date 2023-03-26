variable "model_name" {
    description = "Model's name to be used in the endpoint config."
}

variable "name" {
    description = "Endpoint's config name"
}

variable "memory_size_in_mb" {
    description = "Endpoint's config memory size in MB."
}

variable "max_concurrency" {
    description = "Endpoint's config maximum concurrency. It describes how much containers the sagemaker endpoint will be able to spin up"
}