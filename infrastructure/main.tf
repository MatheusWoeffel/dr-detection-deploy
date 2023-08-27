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
  region = "us-east-1"
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
  architectures     = ["amd64", "arm64v8"]
  about_text        = "TODO"
  name              = "dr-detection-deploy"
  description       = "Images compliant with Sagemaker Endpoint inference (BYOC). Used to execute Tensorflow based models for DR detection."
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
  name   = "dr-detection-deploy-images"
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
  name   = "dr-detection-models"
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
module "mobilenetv2_lite_sagemaker_model" {
  source = "./sagemaker_model"

  name           = "mobilenetv2-lite"
  image_url      = "${module.private_dr_detection_deploy_repository.url}:mobilenetv2-lite"
  model_data_url = "${module.dr_detection_models_bucket.url}/mobilenetv2-lite.tar.gz"
  role_arn       = module.sagemaker_execution_role.arn

  env_vars = {
    "MODEL_SERVER_WORKERS" = "1"
  }
}

module "mobilenet_x86_sagemaker_model" {
  source = "./sagemaker_model"

  name           = "mobilenet-x86"
  image_url      = "${module.private_dr_detection_deploy_repository.url}:latest"
  model_data_url = "${module.dr_detection_models_bucket.url}/mobilenet.tar.gz"
  role_arn       = module.sagemaker_execution_role.arn

  env_vars = {
    "MODEL_SERVER_WORKERS" = "1"
  }
}

module "vgg19_x86_sagemaker_model" {
  source = "./sagemaker_model"

  name           = "vgg19-x86"
  image_url      = "${module.private_dr_detection_deploy_repository.url}:latest"
  model_data_url = "${module.dr_detection_models_bucket.url}/vgg19.tar.gz"
  role_arn       = module.sagemaker_execution_role.arn

  env_vars = {
    "MODEL_SERVER_WORKERS" = "1"
  }
}

module "inceptionV3_x86_sagemaker_model" {
  source = "./sagemaker_model"

  name           = "inceptionV3-x86"
  image_url      = "${module.private_dr_detection_deploy_repository.url}:latest"
  model_data_url = "${module.dr_detection_models_bucket.url}/inceptionV3.tar.gz"
  role_arn       = module.sagemaker_execution_role.arn

  env_vars = {
    "MODEL_SERVER_WORKERS" = "1"
  }
}

module "mobilenet_arm_sagemaker_model" {
  source = "./sagemaker_model"

  name           = "mobilenet-arm"
  image_url      = "${module.private_dr_detection_deploy_repository.url}:arm64"
  model_data_url = "${module.dr_detection_models_bucket.url}/mobilenet.tar.gz"
  role_arn       = module.sagemaker_execution_role.arn

  env_vars = {
    "MODEL_SERVER_WORKERS" = "1"
  }
}

module "mobilenet_arm_4_workers_sagemaker_model" {
  source = "./sagemaker_model"

  name           = "mobilenet-arm-4-workers"
  image_url      = "${module.private_dr_detection_deploy_repository.url}:arm64"
  model_data_url = "${module.dr_detection_models_bucket.url}/mobilenet.tar.gz"
  role_arn       = module.sagemaker_execution_role.arn

  env_vars = {
    "MODEL_SERVER_WORKERS" = "4"
  }
}

module "mobilenet_arm_8_workers_sagemaker_model" {
  source = "./sagemaker_model"

  name           = "mobilenet-arm-8-workers"
  image_url      = "${module.private_dr_detection_deploy_repository.url}:arm64"
  model_data_url = "${module.dr_detection_models_bucket.url}/mobilenet.tar.gz"
  role_arn       = module.sagemaker_execution_role.arn

  env_vars = {
    "MODEL_SERVER_WORKERS" = "8"
  }
}

module "vgg19_arm_sagemaker_model" {
  source = "./sagemaker_model"

  name           = "vgg19-arm"
  image_url      = "${module.private_dr_detection_deploy_repository.url}:arm64"
  model_data_url = "${module.dr_detection_models_bucket.url}/vgg19.tar.gz"
  role_arn       = module.sagemaker_execution_role.arn

  env_vars = {
    "MODEL_SERVER_WORKERS" = "1"
  }
}

module "inceptionV3_arm_sagemaker_model" {
  source = "./sagemaker_model"

  name           = "inceptionV3-arm"
  image_url      = "${module.private_dr_detection_deploy_repository.url}:arm64"
  model_data_url = "${module.dr_detection_models_bucket.url}/inceptionV3.tar.gz"
  role_arn       = module.sagemaker_execution_role.arn

  env_vars = {
    "MODEL_SERVER_WORKERS" = "1"
  }
}


# ################################################################################
# ###
# ### Sagemaker realtime endpoints configurations
# ###
# ################################################################################

module "mobilenet_m6g_realtime_endpoint_config" {
  source = "./sagemaker_realtime_endpoint_config"

  name                   = "mobilenet-m6g"
  model_name             = module.mobilenet_arm_sagemaker_model.name
  instance_type          = "ml.m6g.xlarge"
  initial_instance_count = 1
}

module "mobilenet_m6g_realtime_4_workers_endpoint_config" {
  source = "./sagemaker_realtime_endpoint_config"

  name                   = "mobilenet-m6g-4-workers"
  model_name             = module.mobilenet_arm_4_workers_sagemaker_model.name
  instance_type          = "ml.m6g.xlarge"
  initial_instance_count = 1
}

module "mobilenet_m6g_realtime_8_workers_endpoint_config" {
  source = "./sagemaker_realtime_endpoint_config"

  name                   = "mobilenet-m6g-8-workers"
  model_name             = module.mobilenet_arm_8_workers_sagemaker_model.name
  instance_type          = "ml.m6g.xlarge"
  initial_instance_count = 1
}

module "mobilenet_c7g_realtime_endpoint_config" {
  source = "./sagemaker_realtime_endpoint_config"

  name                   = "mobilenet-c7g"
  model_name             = module.mobilenet_arm_sagemaker_model.name
  instance_type          = "ml.c7g.xlarge"
  initial_instance_count = 1
}


module "mobilenet_m4_realtime_endpoint_config" {
  source = "./sagemaker_realtime_endpoint_config"

  name                   = "mobilenet-m4"
  model_name             = module.mobilenet_x86_sagemaker_model.name
  instance_type          = "ml.m4.xlarge"
  initial_instance_count = 1
}

module "mobilenet_m5_realtime_endpoint_config" {
  source = "./sagemaker_realtime_endpoint_config"

  name                   = "mobilenet-m5"
  model_name             = module.mobilenet_x86_sagemaker_model.name
  instance_type          = "ml.m5.xlarge"
  initial_instance_count = 1
}

module "vgg19_m6g_realtime_endpoint_config" {
  source = "./sagemaker_realtime_endpoint_config"

  name                   = "vgg19-m6g"
  model_name             = module.vgg19_arm_sagemaker_model.name
  instance_type          = "ml.m6g.xlarge"
  initial_instance_count = 1
}

module "vgg19_c7g_realtime_endpoint_config" {
  source = "./sagemaker_realtime_endpoint_config"

  name                   = "vgg19-c7g"
  model_name             = module.vgg19_arm_sagemaker_model.name
  instance_type          = "ml.c7g.xlarge"
  initial_instance_count = 1
}

module "vgg19_m4_realtime_endpoint_config" {
  source = "./sagemaker_realtime_endpoint_config"

  name                   = "vgg19-m4"
  model_name             = module.vgg19_x86_sagemaker_model.name
  instance_type          = "ml.m4.xlarge"
  initial_instance_count = 1
}

module "vgg19_m5_realtime_endpoint_config" {
  source = "./sagemaker_realtime_endpoint_config"

  name                   = "vgg19-m5"
  model_name             = module.vgg19_x86_sagemaker_model.name
  instance_type          = "ml.m5.xlarge"
  initial_instance_count = 1
}


module "inceptionV3_m6g_realtime_endpoint_config" {
  source = "./sagemaker_realtime_endpoint_config"

  name                   = "inceptionV3-m6g"
  model_name             = module.inceptionV3_arm_sagemaker_model.name
  instance_type          = "ml.m6g.xlarge"
  initial_instance_count = 1
}

module "inceptionV3_c7g_realtime_endpoint_config" {
  source = "./sagemaker_realtime_endpoint_config"

  name                   = "inceptionV3-c7g"
  model_name             = module.inceptionV3_arm_sagemaker_model.name
  instance_type          = "ml.c7g.xlarge"
  initial_instance_count = 1
}


module "inceptionV3_m4_realtime_endpoint_config" {
  source = "./sagemaker_realtime_endpoint_config"

  name                   = "inceptionV3-m4"
  model_name             = module.inceptionV3_x86_sagemaker_model.name
  instance_type          = "ml.m4.xlarge"
  initial_instance_count = 1
}

module "inceptionV3_m5_realtime_endpoint_config" {
  source = "./sagemaker_realtime_endpoint_config"

  name                   = "inceptionV3-m5"
  model_name             = module.inceptionV3_x86_sagemaker_model.name
  instance_type          = "ml.m5.xlarge"
  initial_instance_count = 1
}

module "mobilenetv2_lite_m5_realtime_endpoint_config" {
  source = "./sagemaker_realtime_endpoint_config"

  name                   = "mobilenetv2-lite-m5-large"
  model_name             = module.mobilenetv2_lite_sagemaker_model.name
  instance_type          = "ml.m5.large"
  initial_instance_count = 1
}

module "mobilenetv2_lite_m6g_realtime_endpoint_config" {
  source = "./sagemaker_realtime_endpoint_config"

  name                   = "mobilenetv2-lite-m6g-large"
  model_name             = module.mobilenetv2_lite_sagemaker_model.name
  instance_type          = "ml.m6g.large"
  initial_instance_count = 1
}

# ################################################################################
# ###
# ### Sagemaker serverless endpoints configurations
# ###
# ################################################################################

module "mobilenet_serverless_endpoint_1gb_config" {
  source = "./sagemaker_serverless_endpoint_config"

  name = "mobilenet-1gb"
  model_name = module.mobilenet_x86_sagemaker_model.name
  memory_size_in_mb = 1024
  max_concurrency = 50
}

################################################################################
###
### Sagemaker endpoints
###
### Here we define the actual endpoints
### using the configs defined above
###
################################################################################

resource "aws_sagemaker_endpoint" "mobilenet_serverless" {
  name                 = "mobilenet"
  endpoint_config_name = module.mobilenet_serverless_endpoint_1gb_config.name
}

# resource "aws_sagemaker_endpoint" "mobilenetv2_lite_m6g_large" {
#   name                 = "mobilenetv2-lite-m6g-large"
#   endpoint_config_name = module.mobilenetv2_lite_m6g_realtime_endpoint_config.name
# }

# resource "aws_sagemaker_endpoint" "mobilenetv2-lite-serverless" {
#   name                 = "mobilenetv2-lite-serverless"
#   endpoint_config_name = module.mobilenetv2_lite_serverless_endpoint_config.name
# }

# resource "aws_sagemaker_endpoint" "mobilenet-m6g-4-workers" {
#   name                 = "mobilenet-m6g-4-workers"
#   endpoint_config_name = module.mobilenet_m6g_realtime_4_workers_endpoint_config.name
# }

# resource "aws_sagemaker_endpoint" "mobilenet-m6g-8-workers" {
#   name                 = "mobilenet-m6g-8-workers"
#   endpoint_config_name = module.mobilenet_m6g_realtime_8_workers_endpoint_config.name
# }

# resource "aws_sagemaker_endpoint" "vgg19-m6g" {
#   name                 = "vgg19-m6g-1-worker"
#   endpoint_config_name = module.vgg19_m6g_realtime_endpoint_config.name
# }

# resource "aws_sagemaker_endpoint" "inceptionV3-m6g" {
#   name                 = "inceptionV3-m6g-1-worker"
#   endpoint_config_name = module.inceptionV3_m6g_realtime_endpoint_config.name
# }


# resource "aws_sagemaker_endpoint" "mobilenet-c7g" {
#   name                 = "mobilenet-c7g-1-worker"
#   endpoint_config_name = module.mobilenet_c7g_realtime_endpoint_config.name
# }

# resource "aws_sagemaker_endpoint" "vgg19-c7g" {
#   name                 = "vgg19-c7g-1-worker"
#   endpoint_config_name = module.vgg19_c7g_realtime_endpoint_config.name
# }

# resource "aws_sagemaker_endpoint" "inceptionV3-c7g" {
#   name                 = "inceptionV3-c7g-1-worker"
#   endpoint_config_name = module.inceptionV3_c7g_realtime_endpoint_config.name
# }


# resource "aws_sagemaker_endpoint" "mobilenet-m4" {
#   name                 = "mobilenet-m4-1-worker"
#   endpoint_config_name = module.mobilenet_m4_realtime_endpoint_config.name
# }

# resource "aws_sagemaker_endpoint" "vgg19-m4" {
#   name                 = "vgg19-m4-1-worker"
#   endpoint_config_name = module.vgg19_m4_realtime_endpoint_config.name
# }

# resource "aws_sagemaker_endpoint" "inceptionV3-m4" {
#   name                 = "inceptionV3-m4-1-worker"
#   endpoint_config_name = module.inceptionV3_m4_realtime_endpoint_config.name
# }


# resource "aws_sagemaker_endpoint" "mobilenet-m5" {
#   name                 = "mobilenet-m5-1-worker"
#   endpoint_config_name = module.mobilenet_m5_realtime_endpoint_config.name
# }

# resource "aws_sagemaker_endpoint" "vgg19-m5" {
#   name                 = "vgg19-m5-1-worker"
#   endpoint_config_name = module.vgg19_m5_realtime_endpoint_config.name
# }

# resource "aws_sagemaker_endpoint" "inceptionV3-m5" {
#   name                 = "inceptionV3-m5-1-worker"
#   endpoint_config_name = module.inceptionV3_m5_realtime_endpoint_config.name
# }
