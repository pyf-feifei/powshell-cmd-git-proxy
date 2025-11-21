<#
.SYNOPSIS
    全面诊断网络和代理配置

.DESCRIPTION
    检查所有可能导致网络问题的配置：
    1. Windows 系统代理设置
    2. DNS 配置
    3. 环境变量中的代理
    4. 网络适配器状态
    5. 防火墙设置
    6. 常见网站连接测试

.EXAMPLE
    .\Diagnose-Network.ps1
#>

[CmdletBinding()]
param()

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  网络诊断工具" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "正在收集网络配置信息..." -ForegroundColor Yellow
Write-Host ""

# 1. 检查系统代理
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host "📊 [1] Windows 系统代理设置" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
try {
    $proxySettings = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -ErrorAction Stop
    
    if ($proxySettings.ProxyEnable -eq 1) {
        Write-Host "  状态: ⚠️  已启用" -ForegroundColor Yellow
        Write-Host "  代理服务器: $($proxySettings.ProxyServer)" -ForegroundColor Yellow
        Write-Host "  ⚠️  建议: 如果不使用代理，请运行 .\Fix-NetworkDNS.ps1" -ForegroundColor Yellow
    } else {
        Write-Host "  状态: ✅ 未启用" -ForegroundColor Green
        Write-Host "  代理服务器: (无)" -ForegroundColor Gray
    }
} catch {
    Write-Host "  ❌ 无法读取代理设置: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# 2. 检查环境变量代理
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host "📊 [2] 环境变量代理设置" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray

$envProxyVars = @("HTTP_PROXY", "HTTPS_PROXY", "http_proxy", "https_proxy")
$hasEnvProxy = $false

foreach ($var in $envProxyVars) {
    $value = [Environment]::GetEnvironmentVariable($var, "User")
    if ($value) {
        Write-Host "  $var = $value" -ForegroundColor Yellow
        $hasEnvProxy = $true
    }
}

if (-not $hasEnvProxy) {
    Write-Host "  ✅ 未设置环境变量代理" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  建议: 运行 .\Disable-Proxy.ps1 清除代理" -ForegroundColor Yellow
}
Write-Host ""

# 3. 检查 DNS 配置
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host "📊 [3] DNS 服务器配置" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray

try {
    $dnsServers = Get-DnsClientServerAddress -AddressFamily IPv4 | Where-Object { $_.ServerAddresses.Count -gt 0 }
    $hasLocalDNS = $false
    
    foreach ($dns in $dnsServers) {
        Write-Host "  接口: $($dns.InterfaceAlias)" -ForegroundColor Gray
        
        foreach ($server in $dns.ServerAddresses) {
            if ($server -eq "127.0.0.1" -or $server -eq "::1" -or $server -like "fec0:*") {
                Write-Host "    ⚠️  DNS: $server (本地地址)" -ForegroundColor Red
                $hasLocalDNS = $true
            } else {
                Write-Host "    ✅ DNS: $server" -ForegroundColor Green
            }
        }
    }
    
    if ($hasLocalDNS) {
        Write-Host ""
        Write-Host "  ⚠️  检测到本地 DNS (127.0.0.1)！" -ForegroundColor Red
        Write-Host "  💡 这通常是代理软件劫持了 DNS" -ForegroundColor Yellow
        Write-Host "  💡 解决方法: 运行 .\Fix-NetworkDNS.ps1" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ❌ 无法读取 DNS 配置: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# 4. 检查网络适配器
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host "📊 [4] 网络适配器状态" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray

try {
    $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
    
    foreach ($adapter in $adapters) {
        Write-Host "  $($adapter.Name)" -ForegroundColor Gray
        Write-Host "    状态: $($adapter.Status)" -ForegroundColor Green
        Write-Host "    速度: $($adapter.LinkSpeed)" -ForegroundColor Gray
    }
} catch {
    Write-Host "  ❌ 无法读取网络适配器: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# 5. 测试 DNS 解析
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host "🧪 [5] DNS 解析测试" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray

$testDomains = @("www.baidu.com", "www.qq.com", "www.google.com")

foreach ($domain in $testDomains) {
    Write-Host "  测试: $domain" -ForegroundColor Gray
    try {
        $result = Resolve-DnsName -Name $domain -ErrorAction Stop -TimeoutSec 3
        Write-Host "    ✅ 成功: $($result[0].IPAddress)" -ForegroundColor Green
    } catch {
        Write-Host "    ❌ 失败: $($_.Exception.Message)" -ForegroundColor Red
    }
}
Write-Host ""

# 6. 测试网络连接
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host "🧪 [6] 网络连接测试" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray

$testHosts = @(
    @{Name="百度"; Host="www.baidu.com"; Port=80},
    @{Name="腾讯"; Host="www.qq.com"; Port=80},
    @{Name="阿里云DNS"; Host="223.5.5.5"; Port=53}
)

foreach ($test in $testHosts) {
    Write-Host "  测试: $($test.Name) ($($test.Host):$($test.Port))" -ForegroundColor Gray
    try {
        $result = Test-NetConnection -ComputerName $test.Host -Port $test.Port -InformationLevel Quiet -WarningAction SilentlyContinue -ErrorAction Stop
        if ($result) {
            Write-Host "    ✅ 连接成功" -ForegroundColor Green
        } else {
            Write-Host "    ❌ 连接失败" -ForegroundColor Red
        }
    } catch {
        Write-Host "    ❌ 连接失败: $($_.Exception.Message)" -ForegroundColor Red
    }
}
Write-Host ""

# 7. 检查 Git 代理
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host "📊 [7] Git 代理配置" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray

try {
    $gitHttpProxy = & git config --global --get http.proxy 2>$null
    $gitHttpsProxy = & git config --global --get https.proxy 2>$null
    
    if ($gitHttpProxy -or $gitHttpsProxy) {
        Write-Host "  http.proxy: $gitHttpProxy" -ForegroundColor Yellow
        Write-Host "  https.proxy: $gitHttpsProxy" -ForegroundColor Yellow
    } else {
        Write-Host "  ✅ 未设置 Git 代理" -ForegroundColor Green
    }
} catch {
    Write-Host "  ℹ️  Git 未安装或不可用" -ForegroundColor Gray
}
Write-Host ""

# 总结和建议
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host "💡 诊断总结与建议" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""

if ($hasLocalDNS -or $proxySettings.ProxyEnable -eq 1 -or $hasEnvProxy) {
    Write-Host "⚠️  检测到可能的问题配置！" -ForegroundColor Red
    Write-Host ""
    Write-Host "建议修复步骤：" -ForegroundColor Yellow
    Write-Host "  1. 关闭所有代理软件 (Clash、v2rayN 等)" -ForegroundColor White
    Write-Host "  2. 运行: .\Fix-NetworkDNS.ps1 (清除系统代理和重置 DNS)" -ForegroundColor White
    Write-Host "  3. 如果还有问题，运行: .\Set-ManualDNS.ps1 (手动设置可靠的 DNS)" -ForegroundColor White
    Write-Host "  4. 重启浏览器测试" -ForegroundColor White
} else {
    Write-Host "✅ 未检测到明显的配置问题" -ForegroundColor Green
    Write-Host ""
    Write-Host "如果仍然无法访问网站，可能的原因：" -ForegroundColor Yellow
    Write-Host "  1. 路由器或上级网络问题" -ForegroundColor White
    Write-Host "  2. ISP DNS 服务器问题" -ForegroundColor White
    Write-Host "  3. 防火墙阻止" -ForegroundColor White
    Write-Host ""
    Write-Host "建议尝试：" -ForegroundColor Yellow
    Write-Host "  - 运行: .\Set-ManualDNS.ps1 (使用公共 DNS)" -ForegroundColor White
    Write-Host "  - 重启路由器" -ForegroundColor White
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  诊断完成" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

