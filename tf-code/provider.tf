provider "aws" {
  region     = var.aws-region
  version    = "~> 2.70.1"
}

terraform {
  backend "local" {
    path = "./state/terraform.tfstate"
  }
}

### TF backend if you need to keep it in S3 (you should)
#terraform {
#  backend "s3" {
#    bucket  = "<S3_bucket_name>"
#    encrypt = true
#    key     = "<project name>.tfstate"
#    region  = "<aws-region>"
#  }
#}

### ToDo DynamoDB Lock
