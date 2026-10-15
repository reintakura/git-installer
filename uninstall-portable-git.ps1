#Requires -Version 5.1
<#
.SYNOPSIS
    Removes portable Git installed by install-portable-git.ps1. No admin rights needed.
    iwr -useb https://raw.githubusercontent.com/reintakura/git-installer/main/uninstall-portable-git.ps1 | iex
#>
$ErrorActionPreference = 'Stop'
function Write-Log  { param($m) Write-Host "[+] $m" -ForegroundColor Green }
function Write-Warn { param($m) Write-Host "[!] $m" -ForegroundColor Yellow }

$InstallDir = Join-Path $env:USERPROFILE "PortableGit"
$GitCmdDir  = Join-Path $InstallDir "cmd"

# Remove from user PATH
$UserPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($UserPath) {
    $parts = $UserPath -split ';' | Where-Object { $_ -and ($_.TrimEnd('\') -ne $GitCmdDir.TrimEnd('\')) }
    $NewPath = $parts -join ';'
    if ($NewPath -ne $UserPath) {
        [Environment]::SetEnvironmentVariable("PATH", $NewPath, "User")
        Write-Log "Removed from user PATH: $GitCmdDir"
    }
}

# Remove install folder and leftover download
if (Test-Path $InstallDir) {
    Remove-Item -Recurse -Force $InstallDir
    Write-Log "Removed $InstallDir"
} else {
    Write-Warn "Nothing found at $InstallDir"
}
Remove-Item -Force (Join-Path $env:TEMP "mingit.zip") -ErrorAction SilentlyContinue

Write-Log "Cleanup done. Open a new PowerShell / CMD window to refresh PATH."
