#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Quick enable proxy (default address: http://127.0.0.1:7890)
.DESCRIPTION
    One-click to enable proxy for PowerShell, CMD and Git
#>

Write-Host "Enabling proxy..." -ForegroundColor Cyan
& "$PSScriptRoot\Set-Proxy.ps1" -Action set

Write-Host "`nPress any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
