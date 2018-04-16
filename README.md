# Install Windows Admin Center with a custom or self-signed certificate 

Windows Admin Center is an evolution of Windows Server in-box management tools; it’s a single pane of glass that consolidates all aspects of local and remote server management. As a locally deployed, browser-based management experience, an Internet connection and Azure aren’t required. Windows Admin Center gives you full control of all aspects of your deployment, including private networks that aren’t Internet-connected.

This Template **201-vm-windows-admin-center** builds the following:
 * Creates 1 Availability Set
 * Creates a Public IP Address
 * Creates a Load Balancer 
 * Creates a Virtual Network
 * Creates upto 8 NICs for Virtual Machines
 * Creates upto 8 Virtual Machines with OS Disk with Windows 2016.
 * Installs and configures Windows Admin Center
 * Installs either a custom certificate fron a Key Vault or a self-signed certificate

## Usage

Click on the **Deploy to Azure** button below. This will open the Azure Portal (login if necessary) and start a Custom Deployment. The following Parameters will be shown and must be updated / selected accordingly. 

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmrptsai%2F201-vm-windows-admin-center%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fmrptsai%2F201-vm-windows-admin-center%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

## Parameters

- dscKeySecret
  The Automation Account Key for PowerShell DSC Configuration. This is found under the Automatation Account Blade for Keys. Select the value for the Primary or Secondary Access Key 
   
- dscKeyUrl
  The Automation Account Url for PowerShell DSC Configuration. This is found under the Automatation Account Blade for Keys. Select the value for URL

- dscNodeConfiguration
  The name of the PowerShell DSC Node Configuration.
  Default is **installWAC** unless overridden.

- keyVaultName
  The name of the Key Vault containing the Certificate required to install on the Virtual Machines

- keyVaultRg
  The name of Key Vault Resource Group

- keyVaultCertUrl
  The url for Certificate in the Key Vault.

- vmAdminPassword
  The password for the Admin Account. Must be at least 12 characters long.

- vmAdminUser
  The name of the Administrator Account to be created.

- vmCount
  How many Virtual Machine to deploy
  Allowed values are **2, 4, 6, 8**
  Default is **2** unless overridden.
  
- vmSize
  The size of VM required.
  Default is Standard_D1_v2 unless overridden.

- _artifactsLocation
  Storage account name to receive post-build staging folder upload.
  Default is **https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/201-vm-windows-admin-center** unless overridden.

- _artifactsLocationSasToken
  SAS token to access Storage account name
  Default is **""** unless overridden

## Prerequisites

Access to Azure
## Versioning

We use [Github](https://github.com/) for version control.

## Authors

**Paul Towler** - *Initial work* - [201-vm-windows-admin-center](https://github.com/mrptsai/201-vm-windows-admin-center)