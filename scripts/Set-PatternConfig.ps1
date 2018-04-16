<#
.SYNOPSIS
    Configures and compiles PowerShell DSC Configurations for an Automation Account

.DESCRIPTION
    Configures and compiles PowerShell DSC Configurations for an Automation Account

.PARAMETER DscConfig
    A string containing the name of the DSC to compile

.PARAMETER DscPath
    A string containing the Path to the PowerShell Configuration File

.PARAMETER Parameters
    A hashtable containing parameters required to complile the DSC Configuration

.PARAMETER Validate
    A Booleen Paramater to switch on Validation Mode. (Default is False)
#>

[CmdLetBinding()]
param (

    [Parameter(Mandatory=$true)]
    [string]$dscConfig,

	[Parameter(Mandatory=$true)]
    [string]$dscPath,

    [Parameter(Mandatory=$true)]
    [Hashtable]$Parameters,

	[Parameter(Mandatory = $false)]
	[bool]$Validate = $false

)

#region functions
function Set-DSCConfiguration {
	param
	(
		[Parameter(Mandatory=$true)]
        [Object]$AutomationAccount,
        
        [Parameter(Mandatory=$true)]
        [String]$Name,
        
        [Parameter(Mandatory=$true)]
        [String]$DscConfigPath,

        [Parameter(Mandatory=$true)]
        [Object]$ConfigData,
        
        [Parameter(Mandatory=$true)]
		[Object]$Parameters,

		[Parameter(Mandatory = $false)]
		[bool]$Validate = $false
    )
    
    if ($AutomationAccount | Get-AzureRmAutomationDscConfiguration -Name $Name -Erroraction SilentlyContinue)
    {   Write-Output " PowerShell DSC Configuration '$($Name)' already exists"    } else
    {   
        if ($Validate)
		{ Write-Output " VALIDATION MODE! a PowerShell DSC Configuration called '$($Name)' would have been imported!" } else
		{
			Write-Output " Importing PowerShell DSC Configuration......"
			$AutomationAccount | Import-AzureRmAutomationDscConfiguration -SourcePath $DscConfigPath -Published -Force -ErrorVariable _Err -ErrorAction SilentlyContinue | Out-Null
            if (!$_Err)
            {	Write-Output " SUCCCESS! PowerShell DSC Configuration '$($Name)' was imported successfully" } else
            {	throw " ERROR! $($_Err.Exception.Message)"	}
		}
    }
    
    if ($AutomationAccount | Get-AzureRmAutomationDscCompilationJob -Name $Name -Erroraction SilentlyContinue)
    {   Write-Output " PowerShell DSC Compilation Job '$($Name)' already exists"    } else
    {   
        if ($Validate)
		{ Write-Output " VALIDATION MODE! a PowerShell DSC Compilation Job called '$($Name)' would have been started!" } else
		{
			Write-Output " Compiling PowerShell DSC Configuration......"
			$AutomationAccount | Start-AzureRmAutomationDscCompilationJob -ConfigurationName $Name -Parameters $Parameters -ConfigurationData $ConfigData -ErrorVariable _Err -ErrorAction SilentlyContinue | Out-Null
            if (!$_Err)
            {	Write-Output " SUCCCESS! PowerShell DSC Compilation Job '$($Name)' was started successfully" } else
            {	throw " ERROR! $($_Err.Exception.Message)"	}
		}
    }

	if ($Validate)
	{ Write-Output " VALIDATION MODE! a PowerShell DSC Compilation Job called '$($Name)' would have been compiled!" } else
	{
        Do 
		{
			$result = $automationAccount | Get-AzureRmAutomationDscCompilationJob -ConfigurationName $Name | Select-Object -Last 1; 
			Write-Output " Status: $($result.status)"
			if($result.status -ne $result.status) 
			{ $result.status  }
		} until ($result.status -eq "Completed" -or $result.status -eq "Suspended")

		if ($result.status -eq "Suspended")
		{	throw " ERROR! PowerShell Compilation Job failed!"  } else
        {	Write-Output " SUCCESS! PowerShell DSC Configuration '$($Name)' was compiled successfully" }
	}
}
#endregion

#region common variables
$Context = Get-AzureRmContext
$SubscriptionId = if ($Context.Subscription.SubscriptionId) {$Context.Subscription.SubscriptionId} else {$Context.Subscription.id}
$automationAccount = Get-AzureRmAutomationAccount | Where-Object AutomationAccountName -eq "aa-ss1-oms"

Write-Output " SubscriptionId: $($SubscriptionId)"
Write-Output " Automation Account: $($automationAccount.AutomationAccountName)"
Write-Output " Automation Account Rg: $($automationAccount.ResourceGroupName)"
#endregion

#region main code
#Create ConfigData
$configData = @{ 
    AllNodes = @(
        @{
           NodeName = "*"
           RetryCount = 20
           RetryIntervalSec = 30
           PSDscAllowPlainTextPassword = $true
           PSDscAllowDomainUser = $true
       },
       @{
           Nodename = "localhost"
       }
   )
}

Set-DSCConfiguration -AutomationAccount $automationAccount -Name $DscConfig -DSCConfigPath $DscPath -ConfigData $configData -Parameters $Parameters -Validate $Validate

#endregion
