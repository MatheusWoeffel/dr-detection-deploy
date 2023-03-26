output "name" {
    value = aws_sagemaker_endpoint_configuration.serverless_endpoint_config.name
    description = "Endpoint's config name"
}