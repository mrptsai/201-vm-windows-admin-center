#Requires -Modules Pester
<#
.SYNOPSIS
    Contains specific Pester Tests

.DESCRIPTION
    Depending in the Test selected, the appropriate Pester test will be invoked

.PARAMETER Parameters
    A string Array of Parameters that are expected in the Parent ARM Template 

.PARAMETER Resources
    A string Array of Resources that the Parent ARM Template is expected to deploy/create

.PARAMETER SourceDir
    The Source Directory containing the files" 
#>
[CmdLetBinding()]
param (

    [Parameter(Mandatory=$true)]
    [string[]]$Parameters,

    [Parameter(Mandatory=$true)]
    [string[]]$Resources,

	[Parameter(Mandatory=$true)]
    [string[]]$SourceDir
)

#region variables
$templateFile = "$($SourceDir)\azuredeploy.json"
$templateMetadataFile = "$($SourceDir)\metadata.json"
$templateParameterFile = "$($SourceDir)\azuredeploy.parameters.json"
#endregion

#region pester tests
Describe 'ARM Templates Test : Validation & Test Deployment' {

    Context 'Template Validation' {

        It 'Has a JSON template' {
            $templateFile | Should Exist
        }

        It 'Has a parameter file' {
            $templateParameterFile | Should Exist
        }      

        It 'Has a metadata file' {
            $templateMetadataFile | Should Exist
        }

        It 'Converts from JSON and has the expected properties' {
            $expectedProperties = '$schema',
                                  'contentVersion',
								  'outputs',
                                  'parameters',
                                  'resources',
                                  'variables'
            $templateProperties = (get-content $templateFile | ConvertFrom-Json -ErrorAction SilentlyContinue) | Get-Member -MemberType NoteProperty | % Name
            $templateProperties | Should Be $expectedProperties
        }

        It 'Creates the expected Azure resources' {
            $expectedResources = $Resources
            $templateResources = (get-content $templateFile | ConvertFrom-Json -ErrorAction SilentlyContinue).Resources.type
            $templateResources | Should Be $expectedResources
        }

        It 'Contains the expected parameters' {
            $templateParameters = (get-content $templateFile | ConvertFrom-Json -ErrorAction SilentlyContinue).Parameters | Get-Member -MemberType NoteProperty | % Name | Sort-Object
            $templateParameters | Should Be ($Parameters | Sort-Object)
        }

    }

}
#endregion