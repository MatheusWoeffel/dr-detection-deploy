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
### Sagemaker role
###
################################################################################

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["sagemaker.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "sagemaker-role" {
  name = "sagemaker-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "role-policy-attachment" {
    for_each = toset([
        "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess", 
        "${aws_iam_policy.s3-full-access.arn}"
    ])
  role       = aws_iam_role.sagemaker-role.name
  policy_arn = each.value
}

resource "aws_iam_policy" "s3-full-access" {
  name        = "s3-full-access"
  path        = "/"
  description = "Policy which gives access to all s3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
            "s3:GetObject",
            "s3:PutObject",
            "s3:DeleteObject",
            "s3:ListBucket"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::*"
      },
    ]
  })
}

################################################################################
###
### Sagemaker model
###
################################################################################

resource "aws_sagemaker_model" "mobilenet-x86" {
  name               = "mobilenet-x86"
  execution_role_arn = aws_iam_role.sagemaker-role.arn

  primary_container {
    image = "${module.private_dr_detection_deploy_repository.url}:latest"
    model_data_url = "${module.dr_detection_models_bucket.url}/mobilenet.tar.gz"
  }
}

resource "aws_sagemaker_model" "vgg19-x86" {
  name               = "vgg19-x86"
  execution_role_arn = aws_iam_role.sagemaker-role.arn

  primary_container {
    image = "${module.private_dr_detection_deploy_repository.url}:latest"
    model_data_url = "${module.dr_detection_models_bucket.url}/vgg19.tar.gz"
  }
}

resource "aws_sagemaker_model" "mobilenet-arm" {
  name               = "mobilenet-arm64"
  execution_role_arn = aws_iam_role.sagemaker-role.arn

  primary_container {
    image = "${module.private_dr_detection_deploy_repository.url}:arm64"
    model_data_url = "${module.dr_detection_models_bucket.url}/mobilenet.tar.gz"
  }
}

################################################################################
###
### Sagemaker endpoint
###
################################################################################

resource "aws_sagemaker_endpoint_configuration" "mobilenet-1gb-serverless" {
  name = "mobilenet-1gb-serverless-memory"

  production_variants {
    variant_name           = "variant-1"
    model_name             = aws_sagemaker_model.mobilenet-x86.name
    
    serverless_config {
      max_concurrency   = 5
      memory_size_in_mb = 1024
    }
  }
}

resource "aws_sagemaker_endpoint_configuration" "mobilenet-2gb-serverless" {
  name = "mobilenet-2gb-serverless"

  production_variants {
    variant_name           = "variant-1"
    model_name             = aws_sagemaker_model.mobilenet-x86.name
    
    serverless_config {
      max_concurrency   = 5
      memory_size_in_mb = 2048
    }
  }

  tags = {
    Name = "MobileNet serverless with 2GB serverless endpoint"
  }
}

resource "aws_sagemaker_endpoint_configuration" "mobilenet-3gb-serverless" {
  name = "mobilenet-3gb-serverless"

  production_variants {
    variant_name           = "variant-1"
    model_name             = aws_sagemaker_model.mobilenet-x86.name
    
    serverless_config {
      max_concurrency   = 5
      memory_size_in_mb = 3072
    }
  }

  tags = {
    Name = "MobileNet serverless with 3GB serverless endpoint"
  }
}

resource "aws_sagemaker_endpoint_configuration" "mobilenet-4gb-serverless" {
  name = "mobilenet-4gb-serverless"

  production_variants {
    variant_name           = "variant-1"
    model_name             = aws_sagemaker_model.mobilenet-x86.name
    
    serverless_config {
      max_concurrency   = 5
      memory_size_in_mb = 4096
    }
  }

  tags = {
    Name = "MobileNet serverless with 4GB serverless endpoint"
  }
}

resource "aws_sagemaker_endpoint_configuration" "vgg19-3gb-serverless" {
  name = "vgg19-3gb-serverless-memory"

  production_variants {
    variant_name           = "variant-1"
    model_name             = aws_sagemaker_model.vgg19-x86.name
    
    serverless_config {
      max_concurrency   = 5
      memory_size_in_mb = 3072
    }
  }
}

resource "aws_sagemaker_endpoint_configuration" "vgg19-1gb-serverless" {
  name = "vgg19-1gb-serverless-memory"

  production_variants {
    variant_name           = "variant-1"
    model_name             = aws_sagemaker_model.vgg19-x86.name
    
    serverless_config {
      max_concurrency   = 5
      memory_size_in_mb = 1024
    }
  }

  tags = {
    Name = "VGG19 serverless with 1GB serverless endpoint"
  }
}

resource "aws_sagemaker_endpoint_configuration" "vgg19-2gb-serverless" {
  name = "vgg19-2gb-serverless-memory"

  production_variants {
    variant_name           = "variant-1"
    model_name             = aws_sagemaker_model.vgg19-x86.name
    
    serverless_config {
      max_concurrency   = 5
      memory_size_in_mb = 2048
    }
  }

  tags = {
    Name = "VGG19 serverless with 2GB serverless endpoint"
  }
}

resource "aws_sagemaker_endpoint_configuration" "mobilenet-c7g" {
  name = "mobilenet-c7g"

  production_variants {
    variant_name           = "variant-1"
    model_name             = aws_sagemaker_model.mobilenet-arm.name
    instance_type = "ml.c7g.xlarge"
    initial_instance_count = 1
  }

  tags = {
    Name = "Mobilenet c7g endpoint"
  }
}

resource "aws_sagemaker_endpoint" "mobilenet-1gb-serverless" {
  name                 = "mobilenet-1gb-serverless"
  endpoint_config_name = aws_sagemaker_endpoint_configuration.mobilenet-1gb-serverless.name

  tags = {
    Name = "MobileNet serverless with 1GB endpoint"
  }
}

resource "aws_sagemaker_endpoint" "vgg19-1gb-serverless" {
  name                 = "vgg19-1gb-serverless"
  endpoint_config_name = aws_sagemaker_endpoint_configuration.vgg19-1gb-serverless.name

  tags = {
    Name = "VGG19 serverless with 1GB endpoint"
  }
}

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