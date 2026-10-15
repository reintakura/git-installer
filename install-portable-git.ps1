#Requires -Version 5.1
<#
.SYNOPSIS
    Install portable Git (MinGit) with no admin rights and no Scoop.
.DESCRIPTION
    Downloads official MinGit zip from Git for Windows, extracts it under
    %USERPROFILE%\PortableGit, and adds it to the user PATH.
    Fully user-scope. Suitable for public distribution:
      iwr -useb https://raw.githubusercontent.com/reintakura/git-installer/main/install-portable-git.ps1 | iex
#>

$ErrorActionPreference = 'Stop'
$ProgressPreference    = 'SilentlyContinue'

function Write-Log  { param($m) Write-Host "[+] $m" -ForegroundColor Green }
function Write-Warn { param($m) Write-Host "[!] $m" -ForegroundColor Yellow }
function Write-Err  { param($m) Write-Host "[x] $m" -ForegroundColor Red; exit 1 }

# --- Config ---
$GitVersion   = "2.56.0.2"
$ReleaseTag   = "v2.56.0.windows.2"
$InstallDir   = Join-Path $env:USERPROFILE "PortableGit"
$TempZip      = Join-Path $env:TEMP "mingit.zip"

# Detect architecture
$Arch = if ([Environment]::Is64BitOperatingSystem) {
    if ([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture -eq 'Arm64') { 'arm64' } else { '64-bit' }
} else { '32-bit' }

$FileName = "MinGit-$GitVersion-$Arch.zip"
$DownloadUrl = "https://github.com/git-for-windows/git/releases/download/$ReleaseTag/$FileName"

Write-Log "Target: MinGit $GitVersion ($Arch)"
Write-Log "Install location: $InstallDir"

# --- Skip if already installed and working ---
$GitExe = Join-Path $InstallDir "cmd\git.exe"
if (Test-Path $GitExe) {
    $env:PATH = "$(Join-Path $InstallDir 'cmd');$env:PATH"
    try {
        $ver = & $GitExe --version 2>$null
        Write-Log "Portable Git already present: $ver"
        Write-Log "Location: $InstallDir"
        exit 0
    } catch {
        Write-Warn "Existing install found but not working. Reinstalling..."
        Remove-Item -Recurse -Force $InstallDir -ErrorAction SilentlyContinue
    }
}

# --- Download ---
Write-Log "Downloading $FileName ..."
try {
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $TempZip -UseBasicParsing
} catch {
    Write-Err "Download failed: $_`nURL: $DownloadUrl"
}

# --- Extract ---
Write-Log "Extracting to $InstallDir ..."
if (Test-Path $InstallDir) {
    Remove-Item -Recurse -Force $InstallDir -ErrorAction SilentlyContinue
}
New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null

try {
    Expand-Archive -Path $TempZip -DestinationPath $InstallDir -Force
} catch {
    Write-Err "Extraction failed: $_"
}

Remove-Item -Force $TempZip -ErrorAction SilentlyContinue

# --- Add to user PATH permanently ---
$GitCmdDir = Join-Path $InstallDir "cmd"
$UserPath  = [Environment]::GetEnvironmentVariable("PATH", "User")

if ($UserPath -notlike "*$GitCmdDir*") {
    $NewPath = if ([string]::IsNullOrWhiteSpace($UserPath)) { $GitCmdDir } else { "$GitCmdDir;$UserPath" }
    [Environment]::SetEnvironmentVariable("PATH", $NewPath, "User")
    Write-Log "Added to user PATH: $GitCmdDir"
} else {
    Write-Log "Already in user PATH."
}

# Update current session
$env:PATH = "$GitCmdDir;$env:PATH"

# --- Verify ---
if (-not (Test-Path $GitExe)) {
    Write-Err "git.exe not found after extraction."
}

$version = & $GitExe --version
Write-Log "Success: $version"
Write-Log "Portable Git is ready at: $InstallDir"
Write-Log "Open a new PowerShell / CMD window for PATH changes to take effect everywhere."
