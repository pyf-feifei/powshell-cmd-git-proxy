#Requires -RunAsAdministrator

<#
.SYNOPSIS
    快捷启用代理（使用端口 7897）
.DESCRIPTION
    一键启用 PowerShell、CMD 和 Git 的代理设置（端口 7897）
#>

Write-Host "正在启用代理（端口 7897）..." -ForegroundColor Cyan
& "$PSScriptRoot\Set-Proxy.ps1" -ProxyAddress "http://127.0.0.1:7897" -Action set

Write-Host "`n按任意键退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

