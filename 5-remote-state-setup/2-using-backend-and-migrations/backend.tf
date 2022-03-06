terraform {
    backend "s3" {
        key = "networking/dev-vpc/terraform.tfstate" //this is gonna be the name of the object and the path to the object that gets written to the S3 bucket
    }
}

//You can't use variables in here as the initialization process happens before terraform loads variables
//When you want to define values when you run terraform init --> terraform init -backend-config="{KEY}={Value}"