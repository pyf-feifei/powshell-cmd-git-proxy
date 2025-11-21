#Requires -RunAsAdministrator

<#
.SYNOPSIS
    统一管理 PowerShell、CMD 和 Git 的代理设置
.DESCRIPTION
    此脚本可以一键设置或清除 PowerShell、CMD（系统环境变量）和 Git 的代理配置
.PARAMETER ProxyAddress
    代理服务器地址，例如：http://127.0.0.1:7890
.PARAMETER Action
    操作类型：set（设置代理）或 clear（清除代理）
.EXAMPLE
    .\Set-Proxy.ps1 -ProxyAddress "http://127.0.0.1:7890" -Action set
.EXAMPLE
    .\Set-Proxy.ps1 -Action clear
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$ProxyAddress = "http://127.0.0.1:7890",
    
    [Parameter(Mandatory=$true)]
    [ValidateSet("set", "clear")]
    [string]$Action
)

# 颜色输出函数
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# 更新 PowerShell 配置文件中的代理设置
function Update-PowerShellProfile {
    param(
        [string]$ProfilePath,
        [string]$ProxyAddress,
        [bool]$SetProxy
    )
    
    Write-ColorOutput "`n正在处理: $ProfilePath" "Cyan"
    
    # 确保目录存在
    $profileDir = Split-Path $ProfilePath -Parent
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
        Write-ColorOutput "  创建目录: $profileDir" "Green"
    }
    
    # 读取现有内容
    $content = @()
    if (Test-Path $ProfilePath) {
        $content = Get-Content $ProfilePath -ErrorAction SilentlyContinue
    }
    
    # 移除旧的代理设置
    $newContent = $content | Where-Object { 
        $_ -notmatch '^\$Env:http_proxy=' -and 
        $_ -notmatch '^\$Env:https_proxy=' 
    }
    
    if ($SetProxy) {
        # 在文件开头添加新的代理设置
        $proxyLines = @(
            "`$Env:http_proxy=`"$ProxyAddress`"",
            "`$Env:https_proxy=`"$ProxyAddress`""
        )
        $newContent = $proxyLines + $newContent
        Write-ColorOutput "  ✓ 已设置代理: $ProxyAddress" "Green"
    } else {
        Write-ColorOutput "  ✓ 已清除代理设置" "Green"
    }
    
    # 写回文件
    $newContent | Set-Content $ProfilePath -Encoding UTF8
}

# 设置系统环境变量（CMD 使用）
function Set-SystemProxy {
    param(
        [string]$ProxyAddress,
        [bool]$SetProxy
    )
    
    Write-ColorOutput "`n正在设置系统环境变量（CMD 代理）..." "Cyan"
    
    if ($SetProxy) {
        [Environment]::SetEnvironmentVariable("HTTP_PROXY", $ProxyAddress, "User")
        [Environment]::SetEnvironmentVariable("HTTPS_PROXY", $ProxyAddress, "User")
        Write-ColorOutput "  ✓ 已设置用户环境变量" "Green"
        Write-ColorOutput "    HTTP_PROXY = $ProxyAddress" "Gray"
        Write-ColorOutput "    HTTPS_PROXY = $ProxyAddress" "Gray"
    } else {
        [Environment]::SetEnvironmentVariable("HTTP_PROXY", $null, "User")
        [Environment]::SetEnvironmentVariable("HTTPS_PROXY", $null, "User")
        Write-ColorOutput "  ✓ 已清除用户环境变量" "Green"
    }
}

# 设置 Git 代理
function Set-GitProxy {
    param(
        [string]$ProxyAddress,
        [bool]$SetProxy
    )
    
    Write-ColorOutput "`n正在设置 Git 代理..." "Cyan"
    
    # 检查 git 是否安装
    $gitInstalled = Get-Command git -ErrorAction SilentlyContinue
    if (-not $gitInstalled) {
        Write-ColorOutput "  ⚠ 警告: Git 未安装或不在 PATH 中" "Yellow"
        return
    }
    
    if ($SetProxy) {
        git config --global http.proxy $ProxyAddress
        git config --global https.proxy $ProxyAddress
        Write-ColorOutput "  ✓ 已设置 Git 全局代理" "Green"
        Write-ColorOutput "    http.proxy = $ProxyAddress" "Gray"
        Write-ColorOutput "    https.proxy = $ProxyAddress" "Gray"
    } else {
        git config --global --unset http.proxy 2>$null
        git config --global --unset https.proxy 2>$null
        Write-ColorOutput "  ✓ 已清除 Git 全局代理" "Green"
    }
}

# 显示当前代理状态
function Show-ProxyStatus {
    Write-ColorOutput "`n" "White"
    Write-ColorOutput "========================================" "Cyan"
    Write-ColorOutput "          当前代理状态" "Cyan"
    Write-ColorOutput "========================================" "Cyan"
    
    # PowerShell 当前会话
    Write-ColorOutput "`n【PowerShell 当前会话】" "Yellow"
    Write-ColorOutput "  HTTP_PROXY  = $env:HTTP_PROXY" "Gray"
    Write-ColorOutput "  HTTPS_PROXY = $env:HTTPS_PROXY" "Gray"
    
    # 系统环境变量
    Write-ColorOutput "`n【系统环境变量（CMD）】" "Yellow"
    $userHttpProxy = [Environment]::GetEnvironmentVariable("HTTP_PROXY", "User")
    $userHttpsProxy = [Environment]::GetEnvironmentVariable("HTTPS_PROXY", "User")
    Write-ColorOutput "  HTTP_PROXY  = $userHttpProxy" "Gray"
    Write-ColorOutput "  HTTPS_PROXY = $userHttpsProxy" "Gray"
    
    # Git 配置
    Write-ColorOutput "`n【Git 全局配置】" "Yellow"
    $gitInstalled = Get-Command git -ErrorAction SilentlyContinue
    if ($gitInstalled) {
        $gitHttpProxy = git config --global --get http.proxy 2>$null
        $gitHttpsProxy = git config --global --get https.proxy 2>$null
        Write-ColorOutput "  http.proxy  = $gitHttpProxy" "Gray"
        Write-ColorOutput "  https.proxy = $gitHttpsProxy" "Gray"
    } else {
        Write-ColorOutput "  Git 未安装" "Red"
    }
    
    Write-ColorOutput "`n========================================`n" "Cyan"
}

# 主程序
Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput "     代理配置管理工具 v1.0" "Cyan"
Write-ColorOutput "========================================" "Cyan"

$setProxy = ($Action -eq "set")

if ($setProxy) {
    Write-ColorOutput "`n将设置代理为: $ProxyAddress" "Yellow"
} else {
    Write-ColorOutput "`n将清除所有代理设置" "Yellow"
}

# PowerShell 配置文件路径
$ps5ProfilePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
$ps7ProfilePath = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"

# 1. 更新 PowerShell 5.x 配置文件
Update-PowerShellProfile -ProfilePath $ps5ProfilePath -ProxyAddress $ProxyAddress -SetProxy $setProxy

# 2. 更新 PowerShell 7+ 配置文件
Update-PowerShellProfile -ProfilePath $ps7ProfilePath -ProxyAddress $ProxyAddress -SetProxy $setProxy

# 3. 设置系统环境变量（CMD）
Set-SystemProxy -ProxyAddress $ProxyAddress -SetProxy $setProxy

# 4. 设置 Git 代理
Set-GitProxy -ProxyAddress $ProxyAddress -SetProxy $setProxy

# 如果是设置代理，立即应用到当前会话
if ($setProxy) {
    $env:HTTP_PROXY = $ProxyAddress
    $env:HTTPS_PROXY = $ProxyAddress
    Write-ColorOutput "`n✓ 已应用到当前 PowerShell 会话" "Green"
} else {
    $env:HTTP_PROXY = $null
    $env:HTTPS_PROXY = $null
    Write-ColorOutput "`n✓ 已从当前 PowerShell 会话清除" "Green"
}

# 显示当前状态
Show-ProxyStatus

Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput "完成！" "Green"
Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput "`n注意：" "Yellow"
Write-ColorOutput "  • PowerShell 配置将在下次启动时生效" "Gray"
Write-ColorOutput "  • CMD 环境变量需要重新打开 CMD 窗口" "Gray"
Write-ColorOutput "  • Git 代理已立即生效" "Gray"
Write-ColorOutput ""

