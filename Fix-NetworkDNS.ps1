# Fix Network DNS - 修复网络DNS配置

param()

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "需要管理员权限运行此脚本" -ForegroundColor Red
    Write-Host "请右键选择以管理员身份运行 PowerShell" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "=== 网络 DNS 修复工具 ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "[1/4] 清除系统代理..." -ForegroundColor Yellow
try {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyEnable -Value 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyServer -Value ""
    Write-Host "  系统代理已清除" -ForegroundColor Green
} catch {
    Write-Host "  清除失败" -ForegroundColor Red
}
Write-Host ""

Write-Host "[2/4] 刷新 DNS 缓存..." -ForegroundColor Yellow
ipconfig /flushdns | Out-Null
Write-Host "  DNS 缓存已清空" -ForegroundColor Green
Write-Host ""

Write-Host "[3/4] 重置所有网络适配器 DNS..." -ForegroundColor Yellow
try {
    $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
    foreach ($adapter in $adapters) {
        Set-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex -ResetServerAddresses -ErrorAction SilentlyContinue
        Write-Host "  $($adapter.Name) DNS 已重置" -ForegroundColor Green
    }
} catch {
    Write-Host "  重置失败" -ForegroundColor Red
}
Write-Host ""

Write-Host "[4/4] 测试网络连接..." -ForegroundColor Yellow
try {
    $result = Resolve-DnsName -Name "www.baidu.com" -ErrorAction Stop
    Write-Host "  DNS 解析成功: $($result[0].IPAddress)" -ForegroundColor Green
} catch {
    Write-Host "  DNS 解析失败" -ForegroundColor Red
    Write-Host "  建议运行: .\Set-ManualDNS.ps1" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "=== 修复完成 ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "后续步骤:" -ForegroundColor Yellow
Write-Host "  1. 重启浏览器" -ForegroundColor White
Write-Host "  2. 测试访问 www.baidu.com" -ForegroundColor White
Write-Host ""
