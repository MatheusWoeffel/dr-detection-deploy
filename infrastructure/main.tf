terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
}

################################################################################
###
### Public ECR 
###
### Used to host sagemaker inference docker images used in experiments.
### For reproducibility purposes
###
################################################################################

module "public_dr_detection_deploy_repository" {
  source = "./public_ecr"

  operating_systems = ["linux"]
  architectures = ["amd64", "arm64v8"]
  about_text = "TODO"
  name="dr-detection-deploy"
  description="Images compliant with Sagemaker Endpoint inference (BYOC). Used to execute Tensorflow based models for DR detection."
}


################################################################################
###
### Private ECR 
###
### Used to host sagemaker inference docker images.
### For serverless/realtime inference
###
################################################################################

module "private_dr_detection_deploy_repository" {
  source = "./private_ecr"
  name="dr-detection-deploy-images"
}


################################################################################
###
### S3 Bucket
###
### Used to host sagemaker inference docker images.
### For serverless/realtime inference
###
################################################################################

module "dr_detection_models_bucket" {
  source = "./s3_bucket"
  name="dr-detection-models"
}



################################################################################
###
### Sagemaker execution role
###
### Used to configure IAM role policies needed
### to create sagemaker models (s3/sagemaker permissions)
###
################################################################################

module "sagemaker_execution_role" {
  source = "./sagemaker_execution_role"
}


################################################################################
###
### Sagemaker Models
###
### Used to create Sagemaker Endpoint Configs
###
################################################################################

module "mobilenet_x86_sagemaker_model" {
  source = "./sagemaker_model"

  name = "mobilenet-x86"
  image_url = "${module.private_dr_detection_deploy_repository.url}:latest"
  model_data_url = "${module.dr_detection_models_bucket.url}/mobilenet.tar.gz"
  role_arn = module.sagemaker_execution_role.arn
}

module "vgg19_x86_sagemaker_model" {
  source = "./sagemaker_model"

  name = "vgg19-x86"
  image_url = "${module.private_dr_detection_deploy_repository.url}:latest"
  model_data_url = "${module.dr_detection_models_bucket.url}/vgg19.tar.gz"
  role_arn = module.sagemaker_execution_role.arn
}

module "mobilenet_arm_sagemaker_model" {
  source = "./sagemaker_model"

  name = "mobilenet-arm"
  image_url = "${module.private_dr_detection_deploy_repository.url}:arm64"
  model_data_url = "${module.dr_detection_models_bucket.url}/mobilenet.tar.gz"
  role_arn = module.sagemaker_execution_role.arn
}

module "vgg19_arm_sagemaker_model" {
  source = "./sagemaker_model"

  name = "vgg19-arm"
  image_url = "${module.private_dr_detection_deploy_repository.url}:arm64"
  model_data_url = "${module.dr_detection_models_bucket.url}/vgg19.tar.gz"
  role_arn = module.sagemaker_execution_role.arn
}

# ################################################################################
# ###
# ### Sagemaker endpoints configurations
# ###
# ################################################################################

module "mobilenet_1gb_serverless_endpoint_config" {
  source = "./sagemaker_serverless_endpoint_config"
  
  name = "mobilenet-1gb"
  model_name = module.mobilenet_x86_sagemaker_model.name
  max_concurrency = 1
  memory_size_in_mb = "1024"
}

module "mobilenet_2gb_serverless_endpoint_config" {
  source = "./sagemaker_serverless_endpoint_config"
  
  name = "mobilenet-2gb"
  model_name = module.mobilenet_x86_sagemaker_model.name
  max_concurrency = 1
  memory_size_in_mb = "2048"
}

module "mobilenet_3gb_serverless_endpoint_config" {
  source = "./sagemaker_serverless_endpoint_config"
  
  name = "mobilenet-3gb"
  model_name = module.mobilenet_x86_sagemaker_model.name
  max_concurrency = 1
  memory_size_in_mb = "3072"
}


module "vgg19_1gb_serverless_endpoint_config" {
  source = "./sagemaker_serverless_endpoint_config"
  
  name = "vgg19-1gb"
  model_name = module.vgg19_x86_sagemaker_model.name
  max_concurrency = 1
  memory_size_in_mb = "1024"
}

module "vgg19_2gb_serverless_endpoint_config" {
  source = "./sagemaker_serverless_endpoint_config"
  
  name = "vgg19-2gb"
  model_name = module.vgg19_x86_sagemaker_model.name
  max_concurrency = 1
  memory_size_in_mb = "2048"
}

module "vgg19_3gb_serverless_endpoint_config" {
  source = "./sagemaker_serverless_endpoint_config"
  
  name = "vgg19-3gb"
  model_name = module.vgg19_x86_sagemaker_model.name
  max_concurrency = 1
  memory_size_in_mb = "3072"
}

# resource "aws_sagemaker_endpoint_configuration" "mobilenet-1gb-serverless" {
#   name = "mobilenet-1gb-serverless-memory"

#   production_variants {
#     variant_name           = "variant-1"
#     model_name             = aws_sagemaker_model.mobilenet-x86.name
    
#     serverless_config {
#       max_concurrency   = 5
#       memory_size_in_mb = 1024
#     }
#   }
# }

# resource "aws_sagemaker_endpoint_configuration" "mobilenet-2gb-serverless" {
#   name = "mobilenet-2gb-serverless"

#   production_variants {
#     variant_name           = "variant-1"
#     model_name             = aws_sagemaker_model.mobilenet-x86.name
    
#     serverless_config {
#       max_concurrency   = 5
#       memory_size_in_mb = 2048
#     }
#   }

#   tags = {
#     Name = "MobileNet serverless with 2GB serverless endpoint"
#   }
# }

# resource "aws_sagemaker_endpoint_configuration" "mobilenet-3gb-serverless" {
#   name = "mobilenet-3gb-serverless"

#   production_variants {
#     variant_name           = "variant-1"
#     model_name             = aws_sagemaker_model.mobilenet-x86.name
    
#     serverless_config {
#       max_concurrency   = 5
#       memory_size_in_mb = 3072
#     }
#   }

#   tags = {
#     Name = "MobileNet serverless with 3GB serverless endpoint"
#   }
# }

# resource "aws_sagemaker_endpoint_configuration" "mobilenet-4gb-serverless" {
#   name = "mobilenet-4gb-serverless"

#   production_variants {
#     variant_name           = "variant-1"
#     model_name             = aws_sagemaker_model.mobilenet-x86.name
    
#     serverless_config {
#       max_concurrency   = 5
#       memory_size_in_mb = 4096
#     }
#   }

#   tags = {
#     Name = "MobileNet serverless with 4GB serverless endpoint"
#   }
# }

# resource "aws_sagemaker_endpoint_configuration" "vgg19-3gb-serverless" {
#   name = "vgg19-3gb-serverless-memory"

#   production_variants {
#     variant_name           = "variant-1"
#     model_name             = aws_sagemaker_model.vgg19-x86.name
    
#     serverless_config {
#       max_concurrency   = 5
#       memory_size_in_mb = 3072
#     }
#   }
# }

# resource "aws_sagemaker_endpoint_configuration" "vgg19-1gb-serverless" {
#   name = "vgg19-1gb-serverless-memory"

#   production_variants {
#     variant_name           = "variant-1"
#     model_name             = aws_sagemaker_model.vgg19-x86.name
    
#     serverless_config {
#       max_concurrency   = 5
#       memory_size_in_mb = 1024
#     }
#   }

#   tags = {
#     Name = "VGG19 serverless with 1GB serverless endpoint"
#   }
# }

# resource "aws_sagemaker_endpoint_configuration" "vgg19-2gb-serverless" {
#   name = "vgg19-2gb-serverless-memory"

#   production_variants {
#     variant_name           = "variant-1"
#     model_name             = aws_sagemaker_model.vgg19-x86.name
    
#     serverless_config {
#       max_concurrency   = 5
#       memory_size_in_mb = 2048
#     }
#   }

#   tags = {
#     Name = "VGG19 serverless with 2GB serverless endpoint"
#   }
# }

# resource "aws_sagemaker_endpoint_configuration" "mobilenet-c7g" {
#   name = "mobilenet-c7g"

#   production_variants {
#     variant_name           = "variant-1"
#     model_name             = aws_sagemaker_model.mobilenet-arm.name
#     instance_type = "ml.c7g.xlarge"
#     initial_instance_count = 1
#   }

#   tags = {
#     Name = "Mobilenet c7g endpoint"
#   }
# }

# resource "aws_sagemaker_endpoint" "mobilenet-1gb-serverless" {
#   name                 = "mobilenet-1gb-serverless"
#   endpoint_config_name = aws_sagemaker_endpoint_configuration.mobilenet-1gb-serverless.name

#   tags = {
#     Name = "MobileNet serverless with 1GB endpoint"
#   }
# }

# resource "aws_sagemaker_endpoint" "vgg19-1gb-serverless" {
#   name                 = "vgg19-1gb-serverless"
#   endpoint_config_name = aws_sagemaker_endpoint_configuration.vgg19-1gb-serverless.name

#   tags = {
#     Name = "VGG19 serverless with 1GB endpoint"
#   }
# }

# resource "aws_sagemaker_endpoint" "vgg19-2gb-serverless" {
#   name                 = "vgg19-2gb-serverless-memory"
#   endpoint_config_name = aws_sagemaker_endpoint_configuration.vgg19-2gb-serverless.name

#   tags = {
#     Name = "Vgg19 serverless with 2GB endpoint"
#   }
# }

# resource "aws_sagemaker_endpoint" "mobilenet-3gb-serverless" {
#   name                 = "mobilenet-3gb-serverless-memory"
#   endpoint_config_name = aws_sagemaker_endpoint_configuration.mobilenet-3gb-serverless.name

#   tags = {
#     Name = "MobileNet serverless with 3GB endpoint"
#   }
# }


# resource "aws_sagemaker_endpoint" "vgg19-3gb-serverless" {
#   name                 = "vgg19-3gb-serverless-memory"
#   endpoint_config_name = aws_sagemaker_endpoint_configuration.vgg19-3gb-serverless.name

#   tags = {
#     Name = "VGG19 serverless with 3GB endpoint"
#   }
# }


# resource "aws_sagemaker_endpoint" "mobilenet-c7g" {
#   name                 = "mobilenet-c7g"
#   endpoint_config_name = aws_sagemaker_endpoint_configuration.mobilenet-c7g.name

#   tags = {
#     Name = "MobileNet c7g endpoint"
#   }
# }