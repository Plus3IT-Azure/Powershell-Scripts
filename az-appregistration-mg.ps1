# This powershell script creates an App Registration for Cloudtamer.io and assigns it the Owner role to a Management Group
# Command used to run script .\az-appregistration-mg.ps1 -ManagementGroupName <Management Group Name> -RedirectURL <Redirect URL>

# Input Variable(s)
param($ManagementGroupName, $RedirectURL)
Write-Host "The Management Group Name is $ManagementGroupName while the Redirect URL is $RedirectURL"
Start-Sleep -s 5

# Log in to Azure (Have to authenticate with two cmdlets as some cmdlets are used with AZ Cli and some aren't)
Write-Host "Authenticate into AzureAD"
az login 
$AzureContext = az account show --query '[tenantId,user.name]' -o tsv
Connect-AzureAD -TenantId $AzureContext[0] -AccountId $AzureContext[1]

# Variables
$AppRegName = "CT-MG-AppRegistration"
$MSGraphId = "00000003-0000-0000-c000-000000000000"
$domain = (Get-AzureADDomain).Name

# Creation of Random Password for App Registration
Add-Type -AssemblyName System.Web
$minLength = 15 ## characters
$maxLength = 20 ## characters
$Length = Get-Random -Minimum $minLength -Maximum $maxLength
$nonAlphaChars = 5
$Password = [System.Web.Security.Membership]::GeneratePassword($Length, $nonAlphaChars)
$secPw = ConvertTo-SecureString -String $Password -AsPlainText -Force

# App Registration Creation 
$appId = az ad app create --display-name $AppRegName --reply-urls $RedirectURL --password $secPw --credential-description "CT Secret" --end-date '2299-12-12' --query "appId" -o tsv
Write-Host "App Registration $AppRegName created with Client Id $appId"
Start-Sleep -s 10

# Add API Permissions to App Registration
az ad app permission add --id $appId --api $MSGraphId `
   --api-permissions "06da0dbc-49e2-44d2-8312-53f166ab848a=Scope", "e1fe6dd8-ba31-4d61-89e7-88639da4683d=Scope", "62a82d76-70ea-41e2-9197-370581804d09=Role", "df021288-bdef-4463-88db-98f22de89214=Role"
Write-Host "Microsoft Graph Permissions with Id $MSGraphId added to App Registration"
Start-Sleep -s 10

# Grants Admin Consent to App Registration
az ad app permission admin-consent --id $appId 
Write-Host "App Registration $AppRegName granted API permissions & Admin Consent"
Start-Sleep -s 15

# Retrieve Object Id from Service Principal
$spId = az ad sp show --id $appId --query "objectId" -o tsv
Write-Host "$AppRegName Service Principal Object Id is $spId"
Start-Sleep -s 5

# Gets Management Group and assigns the Service Principal the Owner role on Management Group
az role assignment create --role "Owner" --assignee-object-id $spId --scope "/providers/Microsoft.Management/managementGroups/$ManagementGroupName"
Write-Host "$AppRegName assigned Owner permissions to Management Group $ManagementGroupName"
Start-Sleep -s 5

# Gets Required Output from Script
Write-Output `n "Domain name(s) for Azure AD Tenant is/are $domain"
Write-Output `n "App Registration Client Id = $appId" 
Write-Output `n "Client Secret of App Registration = $Password" 

        
  