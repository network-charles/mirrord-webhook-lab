terraform {
  backend "s3" {
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.9.0"
    }
  }
}

# Configure the AWS provider
provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      Provisioned = "Terraform"
    }
  }
}

# Configure the Helm provider
provider "helm" {
  kubernetes = {
    host                   = aws_eks_cluster.staging.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.staging.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.staging.token
  }
}

provider "kubernetes" {
  host                   = aws_eks_cluster.staging.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.staging.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.staging.token
}
