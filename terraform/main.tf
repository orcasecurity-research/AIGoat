terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = "~> 1.3"
}

provider "aws" {
#  profile = var.profile
  region = var.region
}

provider "aws" {
#  profile = var.profile
  alias = "tfstate"
  region = "eu-central-1"
}

resource "aws_dynamodb_table" "terraform_locks" {
  provider = aws.tfstate
  name         = "mycomponents_tf_lockid"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_iam_policy" "terraform_s3_policy" {
  name        = "TerraformS3DynamoDBPolicy"
  description = "Policy for Terraform to access S3 and DynamoDB"
  policy      = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        "Resource": [
          "arn:aws:s3:::mycomponents-tfstate",
          "arn:aws:s3:::mycomponents-tfstate/*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:UpdateItem"
        ],
        "Resource": "arn:aws:dynamodb:eu-central-1:YOUR_ACCOUNT_ID:table/mycomponents_tf_lockid"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = "YOUR_IAM_ROLE_NAME"
  policy_arn = aws_iam_policy.terraform_s3_policy.arn
}

resource "aws_s3_bucket" "terraform_state" {
  provider = aws.tfstate
  bucket = "mycomponents-tfstate"
 
  # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  provider = aws.tfstate
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  provider = aws.tfstate
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  provider = aws.tfstate
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
}

module "data_poisoning" {
  source          = "./modules/data_poisoning"
  region          = var.region
  vpc_id          = module.vpc.vpc_id
  subd_public     = module.vpc.subd_public
}

module "supply_chain" {
  source          = "./modules/supply_chain"
  region          = var.region
  vpc_id          = module.vpc.vpc_id
  subd_public     = module.vpc.subd_public
}

module "output_integrity" {
  source          = "./modules/output_integrity"
  region          = var.region
  vpc_id          = module.vpc.vpc_id
  subd_public     = module.vpc.subd_public
}

module "webserver" {
  source                            = "./modules/webserver"
  vpc_id                            = module.vpc.vpc_id
  subnet_group_id                   = module.vpc.subnet_group_id
  subd_public                       = module.vpc.subd_public
  output_integrity_api_endpoint     = module.output_integrity.api_invoke_url
  supply_chain_api_endpoint         = module.supply_chain.api_invoke_url
  supply_chain_bucket_name          = module.supply_chain.sagemaker_similar_images_bucket_name
  data_poisoning_api_endpoint       = module.data_poisoning.api_invoke_url
  data_poisoning_bucket_name        = module.data_poisoning.sagemaker_recommendation_bucket_name
}

module "front" {
  source          = "./modules/front"
  vpc_id          = module.vpc.vpc_id
  backend_url     = module.webserver.backend_url
}


resource "null_resource" "sleep_after_modules" {
  provisioner "local-exec" {
    command = "sleep 500"
  }

  depends_on = [
    module.vpc,
    module.data_poisoning,
    module.supply_chain,
    module.output_integrity,
    module.webserver,
    module.front
  ]
}

resource "null_resource" "cleanup_sagemaker_resources" {
  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      chmod +x scripts/cleanup_sagemaker.sh
      scripts/cleanup_sagemaker.sh
    EOT
  }

  triggers = {
    always_run = timestamp()
  }
}
