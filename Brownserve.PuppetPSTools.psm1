<#
.DESCRIPTION
    Tooling used for interacting with Puppet
.NOTES
    !!! THIS FILE IS MAINTAINED BY A TOOL !!!
    !!! MANUAL CHANGES WILL BE LOST UNLESS ADDED TO THE "user defined module steps" SECTION BELOW !!!
#>
#Requires -Version 6.0
#Requires -Module Brownserve.PSTools

[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'

$PublicCmdlets = @()

# Dot source our private functions so they are available for our public functions to use (but only if we have some private functions!)
$PrivatePath = Join-Path $PSScriptRoot -ChildPath 'Private'
if (Test-Path $PrivatePath)
{
    $PrivatePath |
        Resolve-Path |
            Get-ChildItem -Filter *.ps1 -Recurse |
                ForEach-Object {
                    . $_.FullName
                }
}

# We should always have public functions, so we'll dot source those and export them
Join-Path $PSScriptRoot -ChildPath 'Public' |
    Resolve-Path |
        Get-ChildItem -Filter *.ps1 -Recurse |
            ForEach-Object {
                . $_.FullName

                $PublicCmdlets += Get-Help $_.BaseName
            }
<#
    "BrownserveCmdlets" is a special variable that can be used to store the cmdlets that have been made available from this module (and indeed _all_ Brownserve modules).
    This allows us to output a summary of the cmdlets that are available in the module from things like repo _init scripts.
    Unfortunately just checking for the existence of the variable isn't enough as if it's blank PowerShell seems to treat it as null so we test for it being an array.
#>
if ($Global:BrownserveCmdlets -is 'System.Array')
{
    $Global:BrownserveCmdlets += @{
        Module  = "$($MyInvocation.MyCommand)"
        Cmdlets = $PublicCmdlets
    }
}
<#
    Some cmdlets will need to make use of temporary files so we need somewhere to store them.
    _If_ we're in a repository then store them in the repositories temp location, otherwise use the system temp drive.
    (This allows us to easily get at temp files created during builds etc and means we don't have to override them in each cmdlet)
#>
$script:BrownserveTempLocation = (Get-PSDrive Temp).Root
if ($Global:BrownserveRepoTempDirectory)
{
    # Only set the path if it's valid, we don't want to set a duff path!
    if ((Test-Path $Global:BrownserveRepoTempDirectory))
    {
        $script:BrownserveTempLocation = $Global:BrownserveRepoTempDirectory
    }
    else
    {
        Write-Warning "The `$global:sBrownserveRepoTempDirectory path '$($global:BrownserveRepoTempDirectory)' does not appear to be a valid path and therefore will be ignored."
    }
}

# Place any custom code for your module ONLY in the space below
# this will ensure it is preserved when the module is updated using Update-BrownservePowerShellModule
### Start user defined module steps

### End user defined module steps
