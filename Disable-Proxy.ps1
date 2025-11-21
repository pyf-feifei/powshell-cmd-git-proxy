#Requires -RunAsAdministrator

<#
.SYNOPSIS
    快捷禁用所有代理
.DESCRIPTION
    一键清除 PowerShell、CMD 和 Git 的代理设置
#>

Write-Host "正在禁用代理..." -ForegroundColor Cyan
& "$PSScriptRoot\Set-Proxy.ps1" -Action clear

Write-Host "`n按任意键退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

