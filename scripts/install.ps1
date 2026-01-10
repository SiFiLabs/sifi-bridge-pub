#!/usr/bin/env pwsh

# SiFi Bridge Windows Installer
# This script downloads and installs the latest version of SiFi Bridge

param(
    [string]$InstallDir = "$env:LOCALAPPDATA\Programs\SiFiBridge"
)

$ErrorActionPreference = "Stop"

# Repository information
$RepoOwner = "SiFiLabs"
$RepoName = "sifi-bridge-pub"
$BinaryName = "sifibridge"

# Colors for output
function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Green
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Function to detect architecture
function Get-Platform {
    $arch = $env:PROCESSOR_ARCHITECTURE

    switch ($arch) {
        "AMD64" {
            return "x86_64-pc-windows-msvc"
        }
        "ARM64" {
            Write-Error-Custom "ARM64 architecture is not currently supported for Windows"
            exit 1
        }
        default {
            Write-Error-Custom "Unsupported architecture: $arch"
            exit 1
        }
    }
}

# Function to fetch latest release version
function Get-LatestVersion {
    Write-Info "Fetching latest release version..."

    try {
        $response = Invoke-RestMethod -Uri "https://api.github.com/repos/$RepoOwner/$RepoName/releases/latest"
        $version = $response.tag_name

        if ([string]::IsNullOrEmpty($version)) {
            Write-Error-Custom "Failed to fetch latest version"
            exit 1
        }

        return $version
    }
    catch {
        Write-Error-Custom "Failed to fetch latest version: $_"
        exit 1
    }
}

# Function to download and install binary
function Install-Binary {
    param(
        [string]$Platform,
        [string]$Version
    )

    $assetName = "${BinaryName}-${Version}-${Platform}.zip"
    $downloadUrl = "https://github.com/${RepoOwner}/${RepoName}/releases/download/${Version}/${assetName}"
    $tempDir = Join-Path $env:TEMP "sifibridge-install-$(Get-Random)"
    $zipPath = Join-Path $tempDir $assetName

    Write-Info "Downloading ${BinaryName} ${Version} for ${Platform}..."

    try {
        # Create temporary directory
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

        # Download the asset
        Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -UseBasicParsing

        Write-Info "Extracting archive..."

        # Extract the zip file
        Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force

        # Find the binary in the extracted directory
        $binaryPath = Get-ChildItem -Path $tempDir -Filter "${BinaryName}.exe" -Recurse -File | Select-Object -First 1

        if ($null -eq $binaryPath) {
            Write-Error-Custom "Binary not found in archive"
            Remove-Item -Path $tempDir -Recurse -Force
            exit 1
        }

        # Create installation directory if it doesn't exist
        if (-not (Test-Path $InstallDir)) {
            New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
        }

        # Install the binary
        $targetPath = Join-Path $InstallDir "${BinaryName}.exe"
        Write-Info "Installing to ${targetPath}..."

        # Remove existing binary if it exists
        if (Test-Path $targetPath) {
            Remove-Item -Path $targetPath -Force
        }

        Move-Item -Path $binaryPath.FullName -Destination $targetPath -Force

        # Clean up
        Remove-Item -Path $tempDir -Recurse -Force

        Write-Info "Installation complete!"
    }
    catch {
        Write-Error-Custom "Installation failed: $_"
        if (Test-Path $tempDir) {
            Remove-Item -Path $tempDir -Recurse -Force
        }
        exit 1
    }
}

# Function to verify installation
function Test-Installation {
    $binaryPath = Join-Path $InstallDir "${BinaryName}.exe"

    if (Test-Path $binaryPath) {
        Write-Info "${BinaryName} installed successfully at ${binaryPath}"

        # Check if installation directory is in PATH
        $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
        if ($currentPath -notlike "*$InstallDir*") {
            Write-Warning-Custom "${InstallDir} is not in your PATH"
            Write-Host ""
            Write-Host "To add it to your PATH, run the following command in PowerShell (as Administrator):" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "    `$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')" -ForegroundColor White
            Write-Host "    [Environment]::SetEnvironmentVariable('Path', `"`$userPath;$InstallDir`", 'User')" -ForegroundColor White
            Write-Host ""
            Write-Host "Or add it to your current session:" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "    `$env:Path += `";$InstallDir`"" -ForegroundColor White
            Write-Host ""
        }
        else {
            Write-Info "You can now run: ${BinaryName} --help"
        }

        # Show version
        Write-Host ""
        Write-Info "Installed version:"
        try {
            & $binaryPath --version
        }
        catch {
            Write-Host "Unable to determine version"
        }
    }
    else {
        Write-Error-Custom "Installation verification failed"
        exit 1
    }
}

# Main installation flow
function Main {
    Write-Host "==================================" -ForegroundColor Cyan
    Write-Host "  SiFi Bridge Installer" -ForegroundColor Cyan
    Write-Host "==================================" -ForegroundColor Cyan
    Write-Host ""

    # Detect platform
    $platform = Get-Platform
    Write-Info "Detected platform: ${platform}"

    # Get latest version
    $version = Get-LatestVersion
    Write-Info "Latest version: ${version}"

    # Install binary
    Install-Binary -Platform $platform -Version $version

    # Verify installation
    Test-Installation

    Write-Host ""
    Write-Host "==================================" -ForegroundColor Cyan
    Write-Host "  Installation Successful!" -ForegroundColor Cyan
    Write-Host "==================================" -ForegroundColor Cyan
}

# Run main function
Main
