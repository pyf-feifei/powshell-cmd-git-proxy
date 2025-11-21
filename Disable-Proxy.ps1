#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Quick disable all proxies
.DESCRIPTION
    One-click to clear proxy settings for PowerShell, CMD and Git
#>

Write-Host "Disabling proxy..." -ForegroundColor Cyan
& "$PSScriptRoot\Set-Proxy.ps1" -Action clear

Write-Host "`nPress any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
