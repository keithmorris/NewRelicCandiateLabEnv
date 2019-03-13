# New Relic Candidate Lab Setup
## Terraform on Azure

### Prerequisites

1. [Terraform](https://www.terraform.io/downloads.html) installed
2. [Azure command line](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) (i.e. `az`) installed
3. [Logged into your azure account](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli?view=azure-cli-latest) in the cli:  `az login`
4. Valid default SSH key pair for your **myadmin** account (i.e. `id_rsa` and `id_rsa.pub`) located in your user ssh directory (i.e. `~/.ssh`).  If these don't exist, simply use `ssh-keygen -A` to generate default keys.



### Setup

1. Clone this directory into a new folder for each candidate: `git clone https://github.com/davemurphysf/NewRelicCandiateLabEnv.git <CandidateName>`
2. Go into the directory `cd <CandidateName>`
3. Generate a SSH keypair for the **candidate** to use with the following command: `ssh-keygen -f ese_rsa -N '' -b 4096`
4. Get your Azure Subscription `id` and `tenantId` via: `az account show`
```
@Azure:~$ az account show
{
  "environmentName": "AzureCloud",
  "id": "9ffe9512-f4a2-42dd-1230-518aec34be21",
  "isDefault": true,
  "name": "Beyond Team Sandbox",
  "registeredProviders": [],
  "state": "Enabled",
  "tenantId": "ac6692da-1231-422f-22a8-9eed6dbe83f1",
  "user": {
    "name": "agomez@datanerd.us",
    "type": "user"
}
```
5. Create a file titled `terraform.tfvars` with the following contents
```
subscription_id = "<Azure Subscription ID>"
tenant_id = "<Azure Tenant ID"
expiration = "YYYY-MM-DD"
username = "<NameWithNoSpaces>"

// Expiration is the date you want the candidates user account on the VM to expire
// No spaces allowed in username; used to namespace Azure resources from other candidates
```
6. Run `terraform init` to install the Terraform providers
7. Run `terraform plan -out tf.plan`.  
8. Once the plan is created, run `terraform apply tf.plan` to apply the scripts.  It should take 5-10 minutes to create the entire environment, and another 10-20 minutes for the Shopizer app to build
9. Once complete, there should be 2 Outputs listed for the candidate to access the VM
```
app_dns = <prefix>.westus.cloudapp.azure.com
username = <username>
```
9. Give the candiate the `ese_rsa` key file, and the candiate can then log into the VM using `ssh -i ese_rsa <username>@<app_dns>`
10. You can login yourself under the default admin account (`myadmin`) using your existing SSH key: `ssh myadmin@<app_dns>`
11. To destroy the environment after the lab is complete, use `terraform destroy -auto-approve`
