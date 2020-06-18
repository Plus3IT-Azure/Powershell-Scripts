# App Registration Creation/Service Principal Assignment

This Powershell Script creates an App Registration and assigns it's Service Principal the Owner role on a Management Group. This Service Principal can be used as a hook in one's application/software to create, destroy, and modify resources in any Azure subscription assigned to the Management Group. Below are the attributes of the App Registration:

- Client Secret (Never expires)
- Redirect URL (Passed into the script as a parameter)
- API Permissions (Microsoft Graph) 
  - Delegated - User.Read
  - Delegated - Directory.Read.All
  - Application - User.Read.All
  - Application - Groups.ReadWrite.All

Two parameters are passed into the script as input:

- Redirect URL
- Management Group

See below for example of passing input parameters into a Powershell script.  

## Install Azure CLI & Azure Powershell

In order to run this powershell script one must have Azure CLI & Azure Powershell installed on the host machine.

1. Install the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)

2. Install the [Az Powershell Module](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-3.6.1)

## Execute Powershell Script

`.\az-appregistration-mg.ps1 -ManagementGroup <Name of Management Group to assign the Service Principal> -RedirectURL <ReplyURL of the App Registration>`
