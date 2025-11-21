#Requires -RunAsAdministrator

<#
.SYNOPSIS
    快捷启用代理（使用默认地址 http://127.0.0.1:7890）
.DESCRIPTION
    一键启用 PowerShell、CMD 和 Git 的代理设置
#>

Write-Host "正在启用代理..." -ForegroundColor Cyan
& "$PSScriptRoot\Set-Proxy.ps1" -Action set

Write-Host "`n按任意键退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

