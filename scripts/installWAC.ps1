<#
.SYNOPSIS
Downloads and Installs Windows Administration Center (WAC)

.DESCRIPTION
This Configuration creates a directory on a Windows Server and downloads the MSI for WAC using a Uri. Once downloaded, the MSI will be installed.

.PARAMETER Uri
The Uri to download the WAC MSI e.g. http://aka.ms/WACDownload

.PARAMETER ProductName
The ProductName of the WAC MSI. The Product Name can change. You can obtain the Project Name of the MSI by downloading the WAC MSI and then using the script from here: http://www.integrationtrench.com/2014/12/mini-orca-getting-product-name-and-code.html 

.PARAMETER ProductCode
The ProductCode of the WAC MSI. The Product Code changes for each release. This can be obtained by downloading the WAC MSI and then using the script from here: http://www.integrationtrench.com/2014/12/mini-orca-getting-product-name-and-code.html 

.PARAMETER Thumbprint
The Thumbprint of the Certificate Installed on the Virtual Server

.EXAMPLE
Install Windows Administration Center using a custom certificate

installHonolulu `
	-Uri "http://aka.ms/WACDownload" `
	-ProductName "Windows Admin Center" `
	-ProductCode "{21CF99D0-E1EE-4883-BC0E-DBFF7A092685}" `
	-Thumbprint "D8CA1DAA466C40686B2405F4509E5E4422F58789"

.EXAMPLE
Install Windows Administration Center using an auto generated self-signed certificate

installHonolulu `
	-Uri "http://aka.ms/WACDownload" `
	-ProductName "Windows Admin Center"
	-ProductCode "{21CF99D0-E1EE-4883-BC0E-DBFF7A092685}"
#>

Configuration installWAC
{
	param
    (
        [Parameter(Mandatory=$True)]
        [String]$Uri,

		[Parameter(Mandatory=$True)]
        [String]$ProductName,	

		[Parameter(Mandatory=$True)]
        [String]$ProductCode,
		
		[Parameter(Mandatory=$False)]
        [String]$ThumbPrint
    )
	
	$log = "${env:SystemDrive}" + "\wac.log"

	if (!$ThumbPrint)
	{
		$WACArgs = "ALLUSERS=1 /liewa $log SME_PORT=443 SSL_CERTIFICATE_OPTION=generate"
	} else
	{
		$WACArgs = "ALLUSERS=1 /liewa $log SME_PORT=443 SME_THUMBPRINT=$ThumbPrint SSL_CERTIFICATE_OPTION=installed"
	}

	Import-DscResource -ModuleName PSDesiredStateConfiguration

	Node localhost
	{
		WindowsFeature DnsTools
        {
            Ensure = "Present"
            Name = "RSAT-DNS-Server"
        }

        WindowsFeature ADAdminCenter
        {
            Ensure = "Present"
            Name = "RSAT-AD-AdminCenter"
        }

        WindowsFeature ADDSTools
        {
            Ensure = "Present"
            Name = "RSAT-ADDS-Tools"
        }

		WindowsFeature RSAT_AD_PowerShell 
        {
            Ensure = 'Present'
            Name   = 'RSAT-AD-PowerShell'
        }
		
		File WindowsAdminCenter {
            Type = "Directory"
            DestinationPath = "C:\apps"
            Ensure = "Present"
        }

		Script DownloadWindowsAdminCenter
		{
			TestScript = {
				Test-Path "C:\apps\WindowsAdminCenter.msi"
			}			
			SetScript = {
	            Invoke-WebRequest -Uri $using:Uri -OutFile "C:\wac\WindowsAdminCenter.msi"
			}			
			GetScript = {@{Result = "DownloadWAC"}}
			DependsOn = "[File]WindowsAdminCenter"			
		}
				
		Package InstallHonolulu
		{
			Ensure = "Present"
			Path  = "C:\apps\WindowsAdminCenter.msi"
			Name = $ProductName
			ProductId = $ProductCode
			Arguments = $WACArgs
			DependsOn = "[Script]DownloadWindowsAdminCenter"
		}

	}
}