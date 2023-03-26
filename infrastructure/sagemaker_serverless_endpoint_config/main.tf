resource "aws_sagemaker_endpoint_configuration" "serverless_endpoint_config" {
  name = "${var.name}-serverless"

  production_variants {
    variant_name           = "variant-1"
    model_name             = var.model_name
    
    serverless_config {
      max_concurrency   = var.max_concurrency
      memory_size_in_mb = var.memory_size_in_mb
    }
  }
}