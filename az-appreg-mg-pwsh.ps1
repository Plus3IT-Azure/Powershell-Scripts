# This powershell script creates an app registration and assigns it the owner role to a management group

 # Command used to run script .\CT-AppReg.ps1 -ManagementGroupID "<ManagementGroupID>" -RedirectURL "<ReplyURL(s)> -CloudEnv "<AzureCloud or AzureUSGovernment>"

 # Azure Powershell 3.8.0 must be installed in order for this powershell script to run successfully

# Input Variable(s)
param($ManagementGroupName, $RedirectURL, $CloudEnv)
Write-Host "The Management Group Name is $ManagementGroupName, the Redirect URL is $RedirectURL, and the Cloud Environment is $CloudEnv"
Start-Sleep -s 5

# Confirming AZ CLI is installed on localhost
Write-Host "Verifying AZ CLI is installed..."
 $azpowershell = Get-InstalledModule -Name Az | Select-Object Version

if($null -eq $azpowershell){
  throw "Azure Powershell not installed. Please install the Azure CLI and try again"
    Write-Host "AZ Powershell not installed; aborting script execution."
     Exit    
}
else{
  Write-Host "Azure Powershell version $azpowershell is installed on localhost; moving forward with script execution"
}
Start-Sleep -s 3

# Variables
$AppRegName = "CT-MG-AppRegistration"

# Get Commercial or Government Domain(s)
Write-Host "Retrieving Domain(s) for $CloudEnv Environment"
  $domain = (Get-AzureADDomain).Name
    Start-Sleep -s 3

# App Registration Creation 
$appId = (New-AzureADApplication -DisplayName $AppRegName -ReplyUrls $RedirectURL).appID
  Write-Host "App Registration $AppRegName created with Client Id $appId"
    Start-Sleep -s 10

# Setting Microsoft Graph API Permissions for Application Registration
$MSGraphId = (Get-AzureADServicePrincipal -Filter "DisplayName eq 'Microsoft Graph'").AppId

$req = New-Object -TypeName "Microsoft.Open.AzureAD.Model.RequiredResourceAccess"
$UserRead = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "06da0dbc-49e2-44d2-8312-53f166ab848a","Scope"
$DirectoryReadAll = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "e1fe6dd8-ba31-4d61-89e7-88639da4683d","Scope"
$UserReadAll = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "62a82d76-70ea-41e2-9197-370581804d09","Role"
$GroupsReadWriteAll = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "df021288-bdef-4463-88db-98f22de89214","Role"

$req.ResourceAccess = $UserRead, $DirectoryReadAll, $UserReadAll, $GroupsReadWriteAll
$req.ResourceAppId = $MsGraphId

$AppObjectId = (Get-AzADApplication -Filter "AppId eq '$appId'").ObjectId
Update-AzADApplication -ObjectId $AppObjectId -RequiredResourceAccess $req

Write-Host "Microsoft Graph Permissions with Id $MSGraphId added to App Registration"
  Start-Sleep -s 10

# Grants Admin Consent to App Registration
#az ad app permission admin-consent --id $appId 
#  Write-Host "App Registration $AppRegName granted API permissions & Admin Consent"
#    Start-Sleep -s 15

# Password Credential Added to App Registration
$PwCred = (New-AzureADApplicationPasswordCredential -ObjectId $AppObjectId -CustomKeyIdentifier "CT Secret" -EndDate '2299-12-12').Value
  Write-Host "Password Credential with value $PwCred being added to $appId"
    Start-Sleep -s 2

# Create Service Principal for App Registration
$AppObjectId = (New-AzADServicePrincipal -ApplicationId $appId).Id
  Write-Host "Service Principal with Id $AppObjectId created for $AppRegName"
    Start-Sleep -s 2

# Gets Management Group and assigns the Service Principal the Owner role on Management Group
New-AzRoleAssignment -RoleDefinitionName "Owner" -ObjectId $AppObjectId -Scope "/providers/Microsoft.Management/managementGroups/$ManagementGroupID"
  Write-Host "$AppRegName assigned Owner permissions to Management Group $ManagementGroupID"
    Start-Sleep -s 5

# Gets Required Output from Script
Write-Output `n "Domain name(s) for Azure AD Tenant is/are $domain"
Write-Output `n "App Registration Client Id = $appId" 
Write-Output `n "Client Secret of App Registration = $PwCred"