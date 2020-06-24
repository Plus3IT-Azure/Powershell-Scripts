# App Registration Creation/Service Principal Assignment

This Powershell Script creates an App Registration and assigns it's Service Principal the Owner role on a Management Group. This Service Principal can be used as a hook in one's application/software to create, destroy, and modify resources in any Azure subscription assigned to the Management Group. Below are the attributes of the App Registration:

- Client Secret (Never expires)
- Redirect URL (Passed into the script as a parameter)
- API Permissions (Microsoft Graph) 
  - Delegated - User.Read
  - Delegated - Directory.Read.All
  - Application - User.Read.All
  - Application - Groups.ReadWrite.All

Before the Powershell script provisions Azure resources it checks to verify Azure CLI is installed. If Azure CLI is not installed it will stop and exit the script; the script will not work if **Azure CLI version 2.8.0 or above** isn't installed on the host running the script.

This script can work in Azure commercial or Azure Government; this is addressed by setting the `-CloudEnv` parameter to AzureCloud or AzureUSGovernment.

Three parameters are passed into the script as input:

- **Redirect URL** (Location the user is sent to once authorized)

- **Management Group** (Containers that manage access, policies, and compliance across subscriptions)

- **CloudEnv** (Whether the resources are being created in AzureCloud or AzureUSGovernment)

See below for example of passing input parameters into a Powershell script.  


## Install Azure CLI

In order to run this powershell script one must have Azure CLI installed on the host machine.

1. Install the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)


## Execute Powershell Script

`.\az-appregistration-mg.ps1 -ManagementGroup <Name of Management Group to assign the Service Principal> -RedirectURL <ReplyURL of the App Registration> -CloudEnv <AzureCloud or AzureUSGovernment>`
