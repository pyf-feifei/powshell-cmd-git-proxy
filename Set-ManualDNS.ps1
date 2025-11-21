# Set Manual DNS

param(
    [string]$PrimaryDNS = "223.5.5.5",
    [string]$SecondaryDNS = "119.29.29.29"
)

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "需要管理员权限运行此脚本" -ForegroundColor Red
    Write-Host "请右键选择以管理员身份运行 PowerShell" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "=== 手动设置 DNS 服务器 ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "将设置 DNS 为:" -ForegroundColor Yellow
Write-Host "  主 DNS: $PrimaryDNS (阿里云)" -ForegroundColor White
Write-Host "  备用 DNS: $SecondaryDNS (DNSPod)" -ForegroundColor White
Write-Host ""

try {
    $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
    
    foreach ($adapter in $adapters) {
        Write-Host "处理适配器: $($adapter.Name)" -ForegroundColor Gray
        Set-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex -ServerAddresses ($PrimaryDNS, $SecondaryDNS)
        Write-Host "  已设置 DNS" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "所有网络适配器的 DNS 已更新" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "刷新 DNS 缓存..." -ForegroundColor Yellow
    ipconfig /flushdns | Out-Null
    Write-Host "  DNS 缓存已清空" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "测试 DNS 解析..." -ForegroundColor Yellow
    try {
        $dnsResult = Resolve-DnsName -Name "www.baidu.com" -ErrorAction Stop
        Write-Host "  DNS 解析成功: $($dnsResult[0].IPAddress)" -ForegroundColor Green
    } catch {
        Write-Host "  DNS 解析失败" -ForegroundColor Red
    }
    
} catch {
    Write-Host "设置 DNS 时出错: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== 设置完成 ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "后续步骤:" -ForegroundColor Yellow
Write-Host "  1. 重启浏览器" -ForegroundColor White
Write-Host "  2. 测试访问 www.baidu.com" -ForegroundColor White
Write-Host "  3. 如需恢复自动获取 DNS, 运行: .\Reset-DNSToAuto.ps1" -ForegroundColor White
Write-Host ""
