In this module you will learn how to use multiple providers in AWS
</br>
Use cases that require multiple providers:
</br>
1 - Different regions for increasing availability (done in previous module )
</br>
2 - Different accounts and security credentials (done here)
</br>
What we are doing in this example ?
</br>
--> creating to VPCs from different accounts and activating VPC peering between them 
</br>
the approach for doing this is by creating a policy and peering role for each vpc that refernces the id of the other vpc's user.
</br>
For more illustration we created the roles and the VPCs in different terraform configurations