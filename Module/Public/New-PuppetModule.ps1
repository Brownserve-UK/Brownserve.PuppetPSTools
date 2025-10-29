function New-PuppetModule
{
    <#
    .SYNOPSIS
        Creates a new Puppet module with the appropriate directory structure and files.

    .DESCRIPTION
        Creates a new Puppet module with the specified name, description, and type.
        For private modules, creates the standard directory structure and manifest files.
        Public modules are not yet implemented.

    .PARAMETER Name
        The name of the Puppet module to create.

    .PARAMETER Description
        A description of what the Puppet module does.

    .PARAMETER ModuleType
        The type of module to create. Valid values are 'Public' or 'Private'.

    .PARAMETER Path
        The path where the module should be created. Defaults to the current working directory.

    .EXAMPLE
        New-PuppetModule -Name 'mymodule' -Description 'My custom module' -ModuleType 'Private'

        Creates a new private Puppet module in the current directory.

    .EXAMPLE
        New-PuppetModule -Name 'mymodule' -Description 'My custom module' -ModuleType 'Private' -Path '/etc/puppetlabs/code/environments/production/modules'

        Creates a new private Puppet module in the specified path.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        [Parameter(Mandatory = $true)]
        [string]
        $Description,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Public', 'Private')]
        [string]
        $ModuleType,

        [Parameter(Mandatory = $false)]
        [string]
        $Path = (Get-Location).Path
    )

    begin
    {
        $ErrorActionPreference = 'Stop'
    }

    process
    {
        if ($ModuleType -eq 'Private')
        {
            # Define the module root path
            $moduleRoot = Join-Path -Path $Path -ChildPath $Name

            # Check if the module already exists
            if (Test-Path -Path $moduleRoot)
            {
                throw "Module directory '$moduleRoot' already exists."
            }

            # Create directory structure
            $directories = @(
                $moduleRoot,
                (Join-Path -Path $moduleRoot -ChildPath 'manifests'),
                (Join-Path -Path $moduleRoot -ChildPath 'types'),
                (Join-Path -Path $moduleRoot -ChildPath 'functions')
            )

            foreach ($directory in $directories)
            {
                if ($PSCmdlet.ShouldProcess($directory, 'Create directory'))
                {
                    Write-Verbose "Creating directory: $directory"
                    New-Item -Path $directory -ItemType Directory -Force | Out-Null
                }
            }

            # Define template paths
            $templateBasePath = Join-Path -Path $PSScriptRoot -ChildPath '..' | Join-Path -ChildPath 'Private' | Join-Path -ChildPath 'Templates'

            # Define manifest files to create from templates
            $manifestFiles = @(
                @{
                    TemplateName = 'init.pp.template'
                    OutputName   = 'init.pp'
                },
                @{
                    TemplateName = 'dependencies.pp.template'
                    OutputName   = 'dependencies.pp'
                },
                @{
                    TemplateName = 'params.pp.template'
                    OutputName   = 'params.pp'
                }
            )

            # Create manifest files from templates
            foreach ($manifestFile in $manifestFiles)
            {
                $templatePath = Join-Path -Path $templateBasePath -ChildPath $manifestFile.TemplateName
                $outputPath = Join-Path -Path $moduleRoot -ChildPath 'manifests' | Join-Path -ChildPath $manifestFile.OutputName

                if (-not (Test-Path -Path $templatePath))
                {
                    throw "Template file '$templatePath' not found."
                }

                # Read template and replace placeholders
                $content = Get-Content -Path $templatePath -Raw
                $content = $content -replace '__MODULENAME__', $Name
                $content = $content -replace '__DESCRIPTION__', $Description

                if ($PSCmdlet.ShouldProcess($outputPath, 'Create file from template'))
                {
                    Write-Verbose "Creating file from template: $outputPath"
                    Set-Content -Path $outputPath -Value $content -NoNewline
                }
            }

            Write-Host "Successfully created private Puppet module '$Name' at '$moduleRoot'" -ForegroundColor Green
        }
        elseif ($ModuleType -eq 'Public')
        {
            # TODO: Implement public module creation
            Write-Warning 'Public module creation is not yet implemented.'
        }
    }
}
