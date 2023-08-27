output "name" {
    value = aws_sagemaker_endpoint_configuration.realtime_endpoint_config.name
    description = "Endpoint's config name"
}