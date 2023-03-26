resource "aws_sagemaker_endpoint_configuration" "realtime_endpoint_config" {
  name = "${var.name}-realtime"

  production_variants {
    variant_name           = "variant-1"
    model_name             = var.model_name
    instance_type = var.instance_type
    initial_instance_count = var.initial_instance_count
  }
}