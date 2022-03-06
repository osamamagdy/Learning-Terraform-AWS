#############################################################################
# VARIABLES
#############################################################################

variable "region_1" {
  type    = string
  default = "us-east-1"
}

variable "region_2" {
  type    = string
  default = "us-west-1"
}

variable "vpc_cidr_range_east" {
  type    = string
  default = "10.10.0.0/16"
}

variable "public_subnets_east" {
  type    = list(string)
  default = ["10.10.0.0/24", "10.10.1.0/24"]
}

variable "database_subnets_east" {
  type = list(string)
  default = ["10.10.8.0/24", "10.10.9.0/24"]
}

variable "vpc_cidr_range_west" {
  type    = string
  default = "10.11.0.0/16"
}

variable "public_subnets_west" {
  type    = list(string)
  default = ["10.11.0.0/24", "10.11.1.0/24"]
}

variable "database_subnets_west" {
  type = list(string)
  default = ["10.11.8.0/24", "10.11.9.0/24"]
}

#############################################################################
# PROVIDERS
#############################################################################

provider "aws" {
  version = "~> 2.0"
  region  = var.region_1
  alias = "east" #it is like the name of this provider to be used in the sources below 
  # profile = "aws_east_security" # this will be the security credentials we want to use for this specific provider (needed if we used different accounts with terraform)
                                  # when not set, it will use the defualt credentials from aws-configure 
}

provider "aws" {
  version = "~> 2.0"
  region  = var.region_2
  alias = "west"
  # profile = "aws_west_security" #this will be the security credentials we want to use for this specific provider (needed if we used different accounts with terraform)

}

#############################################################################
# DATA SOURCES
#############################################################################

data "aws_availability_zones" "azs_east" {
    provider = aws.east
}

data "aws_availability_zones" "azs_west" {
    provider = aws.west
}

#############################################################################
# RESOURCES
#############################################################################  

module "vpc_east" {

  providers = {
      aws = aws.east
  }


  source  = "terraform-aws-modules/vpc/aws"
  version = "2.33.0"

  name = "prod-vpc-east"
  cidr = var.vpc_cidr_range_east

  azs            = slice(data.aws_availability_zones.azs_east.names, 0, 2)
  public_subnets = var.public_subnets_east

  # Database subnets
  database_subnets  = var.database_subnets_east
  database_subnet_group_tags = {
    subnet_type = "database"
  }

  tags = {
    Environment = "prod"
    Region = "east"
    Team        = "infra"
  }

}

module "vpc_west" {

  providers = {
      aws = aws.west
  }


  source  = "terraform-aws-modules/vpc/aws"
  version = "2.33.0"

  name = "prod-vpc-west"
  cidr = var.vpc_cidr_range_west

  azs            = slice(data.aws_availability_zones.azs_west.names, 0, 2)
  public_subnets = var.public_subnets_west

  # Database subnets
  database_subnets  = var.database_subnets_west
  database_subnet_group_tags = {
    subnet_type = "database"
  }


  tags = {
    Environment = "prod"
    Region = "west"
    Team        = "infra"
  }

}

#############################################################################
# OUTPUTS
#############################################################################

output "vpc_id_east" {
  value = module.vpc_east.vpc_id
}

output "vpc_id_west" {
  value = module.vpc_west.vpc_id
}
