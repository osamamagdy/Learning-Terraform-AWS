#############################################################################
# VARIABLES (another way of using this is the .tfvars file)
# here we define variables to be used in the configuration
# the syntax for defining variables is independent on which cloud provider we use
# the values "default" used inside each variable can be overwritten by the .tfvars files (but it must be of the same type)
#############################################################################

variable "region" {
  type    = string
  default = "us-east-1"
}


variable "vpc_cidr_range" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  type    = list(string)  #like array of strings     
  default = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "database_subnets" {
  type = list(string)
  default = ["10.0.8.0/24", "10.0.9.0/24"]
}


#############################################################################
# PROVIDERS
#############################################################################

provider "aws" {
  version = "~> 2.0" #allow for minor changes (like 2.6 , 2.7 ) but not major ones (like 3.0 4.0)
  region  = var.region
  profile = "infra"
}

#############################################################################
# DATA SOURCES
#############################################################################

data "aws_availability_zones" "azs" {} #data sources is values or variables you pull from the provider itself
#here we pull the full list of availability zones available in the selected region (will be used further)
# and it will be named "data.aws_availability_zones.azs"

#############################################################################
# RESOURCES (the actual resources we provision on the cloud)
#############################################################################  

module "vpc" {
#modules in terraform are pre-defined modules to create a group of resources only by tunning some values

  source  = "terraform-aws-modules/vpc/aws" #refer to the terraform registry at {https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest}
  name = "dev-vpc"
  cidr = var.vpc_cidr_range #you should understand what is a cidr block

  azs            = slice(data.aws_availability_zones.azs.names, 0, 2) #this will slice the list of availability zones and take list[0],list[1], but doesn't inlude list[2]
  public_subnets = var.public_subnets

  # Database subnets
  database_subnets  = var.database_subnets
  database_subnet_group_tags = {
    subnet_type = "database"
  }

  tags = {
    Environment = "dev"
    Team        = "infra"
  }

}

#############################################################################
# OUTPUTS (these are parameters that you will be able to use in future modules or can be printed in the terminal after creating the resources)
#############################################################################

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "db_subnet_group" {
  value = module.vpc.database_subnet_group
}

output "public_subnets" {
  value = module.vpc.public_subnets
}


