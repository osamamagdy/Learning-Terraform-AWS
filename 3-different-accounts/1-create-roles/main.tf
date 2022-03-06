#############################################################################
# VARIABLES
#############################################################################

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "peering_users" {
  type = list(string)
  #value will be overwritten by the terraform.tfvars file
}

#############################################################################
# PROVIDERS
#############################################################################

#This time, both providers are in the same region but with different profiles
#Different profiles -> different accounts and securrity credentials
provider "aws" {
  version = "~> 2.0"
  region  = var.region
  alias   = "infra"
  profile = "infra" #this profile will be created with "aws configure --profile infra" command 
}

provider "aws" {
  version = "~> 2.0"
  region  = var.region
  alias   = "sec"
  profile = "sec"  #this profile will be created with "aws configure --profile sec" command 
}

#############################################################################
# DATA SOURCES
#############################################################################

#This data source retrieves the identity information about the user creating this resource
#One thing we mainly need from this is the account ID which will be used in the policies and security roles
data "aws_caller_identity" "infra" {
  provider = aws.infra
}

data "aws_caller_identity" "sec" {
  provider = aws.sec
}

#############################################################################
# RESOURCES
############################################################################# 

# Create a policy to allow peering acceptance

resource "aws_iam_role_policy" "peering_policy" {
  name     = "vpc_peering_policy"
  role     = aws_iam_role.peer_role.id #this will be created down
  provider = aws.sec

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "ec2:AcceptVpcPeeringConnection",
          "ec2:DescribeVpcPeeringConnections"
        ],
        "Effect": "Allow",
        "Resource": "*"
      }
    ]
  }
  EOF
}

# Create a role that can be assumed by the infra account

resource "aws_iam_role" "peer_role" {
  name     = "peer_role"
  provider = aws.sec

  assume_role_policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.infra.account_id}:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {}
    }
  ]
}
  EOF
}
################################################################################################
################################################################################################
########################### Now for the infra provider ##########################################
################################################################################################
################################################################################################

# Create a group that can accept peering connections

resource "aws_iam_group" "peering" {

  name     = "VPCPeering"
  provider = aws.infra

}

# Add members to the group

resource "aws_iam_group_membership" "peering-members" {
  name     = "VPCPeeringMembers"
  provider = aws.infra

  users = var.peering_users

  group = aws_iam_group.peering.name
}

# Create a group policy that can assume the role in sec

resource "aws_iam_group_policy" "peering-policy" {
  name     = "peering-policy"
  group    = aws_iam_group.peering.id
  provider = aws.infra

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": "sts:AssumeRole",
    "Resource": "${aws_iam_role.peer_role.arn}"
  }
}
EOF
}

#############################################################################
# OUTPUTS
############################################################################# 

output "peer_role_arn" {
  value = aws_iam_role.peer_role.arn
}
