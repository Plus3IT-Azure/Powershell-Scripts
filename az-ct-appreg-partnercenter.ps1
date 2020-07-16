# Input Variable(s)
param($RedirectURL)
Write-Host "The Redirect URL is $RedirectURL"
Start-Sleep -s 5

# Confirming Azure Powershell is installed on localhost
Write-Host "Verifying Azure Powershell is installed..."
 $azmodule = Get-InstalledModule -Name Az

if($null -eq $azmodule.Name){
  throw "Azure Powershell not installed. Please install the Azure Powershell and try again"
    Write-Host "Azure Powershell not installed; aborting script execution."
     Exit    
}
else{
  Write-Host "Azure Powershell version "$azmodule.Version" is installed on localhost; moving forward with script execution"
}
Start-Sleep -s 3

# Confirming Partner Center Module is installed on localhost
Write-Host "Verifying Partner Center Module is installed..."
 $pcmodule = Get-InstalledModule -Name PartnerCenter

if($null -eq $pcmodule.Name){
  throw "Partner Center Module not installed. Please install the Partner Center Module and try again"
    Write-Host "Partner Center Module not installed; aborting script execution."
     Exit    
}
else{
  Write-Host "Partner Center Module version "$pcmodule.Version" is installed on localhost; moving forward with script execution"
}
Start-Sleep -s 3

# Log in to Azure
Write-Host "Authenticate into AzureAD"
$TenantID = (Connect-AzureAD).TenantId

# Variables
$AppRegName = "MS Partner Center"
$AADGraphId = "00000002-0000-0000-c000-000000000000"
$PartnerCenterId = "fa3d9a0c-3fb0-42cc-9193-47c7ecd2edbd"

# API Permission IDs for Azure Active Directory Graph 
$UserRead = "a42657d6-7f20-40e3-b6f0-cee03008a62a=Scope"
$DirectoryReadAll = "311a71cc-e848-46a1-bdf8-97ff7156d8e6=Scope"

# API Permissions ID(s) for Partner Center
$UserImpersonation = "1cebfa2a-fb4d-419e-b5f9-839b4383e05a"

# App Registration Creation 
$appreg = New-AzureADApplication -DisplayName $AppRegName -ReplyUrls $RedirectURL
  Write-Host "App Registration $AppRegName created with Client Id "$appreg.AppId""
    Start-Sleep -s 10
$AppId = (Get-AzureADApplication -ObjectId $appreg.ObjectId).AppId

# Password Credential Added to App Registration
$PwCred = (New-AzureADApplicationPasswordCredential -ObjectId $appreg.ObjectId -CustomKeyIdentifier "My Client Secret" -EndDate '2299-12-12').Value
  Write-Host "Password Credential with value $PwCred being added to "$appreg.ObjectId""
    Start-Sleep -s 2

# Setting Microsoft Windows Azure Active Directory for Application Registration
$req = New-Object -TypeName "Microsoft.Open.AzureAD.Model.RequiredResourceAccess"
$UserRead = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "a42657d6-7f20-40e3-b6f0-cee03008a62a","Scope"
$DirectoryUserAccessAll = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "311a71cc-e848-46a1-bdf8-97ff7156d8e6","Scope"
  $req.ResourceAccess = $UserRead, $DirectoryUserAccessAll
  $req.ResourceAppId = $AADGraphId

# Setting Microsoft Partner Center Permissions for Application Registration
$req1 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.RequiredResourceAccess"
$UserImpersonation = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "1cebfa2a-fb4d-419e-b5f9-839b4383e05a","Scope"
  $req1.ResourceAccess = $UserImpersonation
  $req1.ResourceAppId = $PartnerCenterId

Set-AzureADApplication -ObjectId $appreg.ObjectId -RequiredResourceAccess $req,$req1

# Grant Admin Consent on Application Registration
Write-Host "Accessing $AppRegName URL to Grant Admin Consent.."
Start-Sleep -s 2
Start "https://login.microsoftonline.com/$TenantID/adminconsent?client_id=$AppId"
