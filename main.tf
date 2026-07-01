# =============================================================================
# AUY1105 — Evaluación Parcial 2 — Repositorio Principal
# -----------------------------------------------------------------------------
# Orquesta los módulos desacoplados de redes, cómputo y almacenamiento.
# =============================================================================

terraform {
  required_version = ">= 1.2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# =============================================================================
# Módulo de Redes
# Fuente: https://github.com/recouma/terraform-aws-vpc-auy1105-grupo-3
# =============================================================================
module "red" {
  source = "github.com/recouma/terraform-aws-vpc-auy1105-grupo-3?ref=v1.0.0"

  vpc_cidr     = var.vpc_cidr
  project_name = var.project_name

  public_subnets   = var.public_subnets
  sg_ingress_rules = var.sg_ingress_rules

  common_tags = local.common_tags
}

# =============================================================================
# Módulo de Cómputo
# Fuente: https://github.com/recouma/terraform-aws-ec2-auy1105-grupo-3
# =============================================================================
module "computo" {
  source = "github.com/recouma/terraform-aws-ec2-auy1105-grupo-3?ref=v1.0.0"

  instance_type      = var.instance_type
  subnet_id          = module.red.subnet_ids[0]
  security_group_ids = [module.red.security_group_id]
  project_name       = var.project_name

  common_tags = local.common_tags
}

# =============================================================================
# Módulo de Almacenamiento
# Fuente: https://github.com/recouma/terraform-aws-s3-auy1105-grupo-3
# =============================================================================
module "almacenamiento" {
  source = "github.com/recouma/terraform-aws-s3-auy1105-grupo-3?ref=v1.0.0"

  bucket_name  = "auy1105-grupo3-proyecto2-datos-carlos"
  project_name = var.project_name

  common_tags = local.common_tags
}

locals {
  common_tags = {
    Project   = var.project_name
    ManagedBy = "Terraform"
  }
}
