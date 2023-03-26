resource "aws_sagemaker_model" "model" {
  name               = var.name
  execution_role_arn = var.role_arn

  primary_container {
    image = var.image_url
    model_data_url = var.model_data_url
  }
}