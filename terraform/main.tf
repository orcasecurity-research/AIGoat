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
    profile = "allie-vt"
    shared_config_files = ["/Users/ahowe/.aws/config"]
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
    when    = "destroy"
    command = <<EOT
      chmod +x scripts/cleanup_sagemaker.sh
      scripts/cleanup_sagemaker.sh
    EOT
  }

  triggers = {
    always_run = timestamp()
  }
}
