<h2>What to do</h2>
</br>In this module you will learn how to use remote terraform state in AWS
</br>
It simply works as a version control for your IaC to keep terraform always updated what is the state of the resources in your plans.
</br>
This is done by storing your state in a remote loaction(S3 bucket in our approach) where it will be updated every time.
</br>
If it is not used, you should always keep your terraform state file before any terraform plan, apply, or distroy.
</br>
<h2>Use Cases</h2>
</br>
Use cases that require using remote state:
</br>
1 - Different developers managing the infrastructure (state integrity is a must)
</br>
2 - Using remote state is safer as your local storage may be corrubted or data is lost. So, using remote state is more robust. 
</br>
<h2>Backend definition</h2>
</br>
What is a backend ?
</br>
--> In terraform, the location of your state data is referred to as a backend and there are two types of it.
</br>
-----> a) Standard : it means that the backend is used only for storage of your state so you can update it from the local backend and vice versa (the S3 remote we are using is Standard)
</br>
-----> b) Enhanced : the backend stores the state and also can run terraform processes (like terraform apply). Basically the local backend is enhanced and the only remote enhanced backends till now are `Terraform Cloud` and `Terraform Enterprise`
</br>
<h2>Backend Features</h2>
</br>
Special features of backends:
</br>
--> Locking : when using the backend and running terraform processes, you want to make sure that no one else is changing simultaneously.
</br>
--> Workspaces : They enable you to use the same configurations for multiple environments. Same Configuration, different state data.
</br>
<h2>Using AWS</h2>
</br>
Remote State with AWS Storage:
</br>
--> We will be using S3 to store the stater data remotely in a dedicated bucket, but as S3 doesn't support locking by itself, we will be using DynamoDB </br>
where terraform will put a locking entry when it's manipulating the state
</br>
Note : S3 natively supports workspaces and Encryption for sensitive data, so we don't need DynamoDB table for that.
</br>

<h2>Authentication Methods</h2>
</br>
----> 1) Instance profie : In some automation scenarios and pipelines, you may be running your terraform plan on an EC2 instance. So, you can give this specific instance an instance profile with permissions to access S3 bucket and DynamoDB
</br>
----> 2) Access & Secret Keys
</br>
----> 3) Credentials file & profile : Like we did before in module 2, we use profiles generated by the AWS CLI in the aws provider.
</br>
----> 4) Session Token
</br>
</br>
</br>
<h2>Demo</h2>
</br>
What we are doing in this example ?
</br>
<h3> Set up the needed tools for migrations</h3>
--> migrating our existing state of the dev-vpc we created in the first module. 
</br>
--> the approach for doing this is by creating Infra bucket to store our state and a DynamoDB table to enable locking
</br>
--> we will also add two IAM groups. First one that have Full Access over the S3 bucket and DynamoDB so they can modify the state. Second one will have Read-only access on the S3 bucket for developers who want to know the state of the infrastructure
</br>
<h3>How to actually migrate from the existing backend</h3>
---> Update backend configuration like done in the `backend.tf` file
</br>
---> Run `terraform init` that will initialize the backend and check if there is a state data to be migrated.
</br>
</br>
