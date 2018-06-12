# Script to install vstest runner locally.
# This script uses a portable vstest runner, so external dependencies including VS etc. are required.

<#
.SYNOPSIS
    Installer for portable vstest.console test runner.
.DESCRIPTION
    Script installs a portable vstest.console runner to specified directory. Use the list option
    to print available versions.

    Full documentation at <https://spekt.github.io/vstest-get>.
    Please report any issues at <https://github.com/spekt/vstest-get/issues>.
.PARAMETER DIRECTORY
    Target directory for installing the runner.
.PARAMETER LiteralPath
    Specifies a path to one or more locations. Unlike Path, the value of 
    LiteralPath is used exactly as it is typed. No characters are interpreted 
    as wildcards. If the path includes escape characters, enclose it in single
    quotation marks. Single quotation marks tell Windows PowerShell not to 
    interpret any characters as escape sequences.
.EXAMPLE
    C:\PS> 
    <Description of example>
.NOTES
    Author: Spekt Developers
#>

[CmdletBinding(DefaultParameterSetName="Path")]
param(
    [Alias("v")]
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $Version,

    [Alias("l")]
    [Parameter()]
    [switch] $List,

    [Parameter(Mandatory=$false, Position=0)]
    [ValidateNotNullOrEmpty()]
    [string] $Directory
)

$action="install"
$install_dir=$Directory
$install_version=$Version
$verbosity=$Verbose

function Verify-Parameters() {
    if ($List) {
        $script:action="list"
    }
}

function Get-VSTestVersions() {
    Write-Host "Available versions:"
    $info_url="https://api.nuget.org/v3-flatcontainer/Microsoft.TestPlatform.Portable/index.json"
    $json=Invoke-WebRequest $info_url

    $versions = $(ConvertFrom-Json $json).versions

    foreach ($ver in $versions) {
        Write-Host "  $ver"
    }
}

function Install-VSTestRunner() {
}

function Invoke-VSTestAction() {
    if ($action -eq "install") {
        Install-VSTestRunner
    }

    Get-VSTestVersions
}

Verify-Parameters
Invoke-VSTestAction
