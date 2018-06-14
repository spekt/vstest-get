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
.PARAMETER Version
    Specifies a version to install. Use -l to list available versions.
.PARAMETER List
    Lists available vstest runner versions.
.EXAMPLE
    C:\PS> install.ps1 -l
    This command will list available test runner versions.
.EXAMPLE
    C:\PS> install.ps1 .\trial
    This command will install vstest.console to .\trial\ directory.
    Specifically the desktop build of runner is installed to .\trial\net451 and .NET core version is
    installed to .\trial\netcoreapp2.0.
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
    [string] $Directory="~/.vstest"
)

$ErrorActionPreference = "Stop"

$action = "install"
$install_dir = $Directory
$install_version = $Version
$verbosity = $Verbose

function Verify-Parameters() {
    if ($List) {
        $script:action = "list"
    }
}

function Get-VSTestVersions() {
    Write-Host "Available versions:"
    $info_url = "https://api.nuget.org/v3-flatcontainer/Microsoft.TestPlatform.Portable/index.json"
    $json = Invoke-WebRequest $info_url

    $versions = $(ConvertFrom-Json $json).versions

    foreach ($ver in $versions) {
        Write-Host "  $ver"
    }
}

function Install-VSTestRunner() {
    Write-Verbose "Installing vstest"

    $url = "https://www.nuget.org/api/v2/package/Microsoft.TestPlatform.Portable"
    $tmpdir = $(New-TemporaryFile | % { Remove-Item $_; New-Item -ItemType Directory -Path $_ })
    $nupkg = $(Join-Path "$tmpdir" "Microsoft.TestPlatform.Portable.nupkg.zip")

    if (-not (Test-Path -PathType Container $install_dir)) {
        New-Item -ItemType Directory -Path $install_dir | Out-Null
        Write-Verbose "Created install directory at '$install_dir'"
    }

    if (-not [String]::IsNullOrEmpty($install_version)) {
        Write-Verbose "Version is not supported yet. Will download latest."
    }

    Write-Host "Downloading package to '$tmpdir'..."
    Invoke-WebRequest "$url" -OutFile "$nupkg"

    Write-Verbose "Extracting nuget package in '$tmpdir'..."
    Expand-Archive "$nupkg" -DestinationPath "$tmpdir"

    Write-Host "Installing test runner to '$install_dir'..."
    Copy-Item -Recurse -Force "$tmpdir/tools/*" "$install_dir"

    Write-Host "Installation complete"
}

function Verify-Install() {
    Write-Verbose "Verifying vstest install"

    $console_runner=Join-Path "$install_dir" "net451\vstest.console.exe"
    $console_runner_core=Join-Path "$install_dir" "netcoreapp2.0\vstest.console.dll"
    if (Test-Path "$console_runner" -and Test-Path "$console_runner_core") {
        Write-Host "You can invoke the test runner based on target runtime..."
        Write-Host "  # .NET 4.x desktop framework"
        Write-Host "  > $console_runner <\path\to\test.dll>"
        Write-Host "  # .NET core framework"
        Write-Host "  > dotnet $console_runner_core <\path\to\test.dll>"
    }
    else {
        Write-Host "Error: unable to find test runners at (all or any of) following locations..."
        Write-Host "  $console_runner"
        Write-Host "  $console_runner_core"
    }
}

function Invoke-VSTestAction() {
    if ($action -eq "install") {
        Install-VSTestRunner; Verify-Install
    }
    else {
        Get-VSTestVersions
    }
}

Verify-Parameters
Invoke-VSTestAction
