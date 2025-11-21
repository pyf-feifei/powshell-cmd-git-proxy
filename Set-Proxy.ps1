#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Unified proxy management for PowerShell, CMD and Git
.DESCRIPTION
    This script can set or clear proxy configurations for PowerShell, CMD (system environment variables) and Git
.PARAMETER ProxyAddress
    Proxy server address, e.g.: http://127.0.0.1:7890
.PARAMETER Action
    Action type: set or clear
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

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Update-PowerShellProfile {
    param(
        [string]$ProfilePath,
        [string]$ProxyAddress,
        [bool]$SetProxy
    )
    
    Write-ColorOutput "`nProcessing: $ProfilePath" "Cyan"
    
    $profileDir = Split-Path $ProfilePath -Parent
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
        Write-ColorOutput "  Created directory: $profileDir" "Green"
    }
    
    $content = @()
    if (Test-Path $ProfilePath) {
        $content = Get-Content $ProfilePath -ErrorAction SilentlyContinue
    }
    
    $newContent = $content | Where-Object { 
        $_ -notmatch '^\$Env:http_proxy=' -and 
        $_ -notmatch '^\$Env:https_proxy=' 
    }
    
    if ($SetProxy) {
        $proxyLines = @(
            "`$Env:http_proxy=`"$ProxyAddress`"",
            "`$Env:https_proxy=`"$ProxyAddress`""
        )
        $newContent = $proxyLines + $newContent
        Write-ColorOutput "  [OK] Proxy set: $ProxyAddress" "Green"
    } else {
        Write-ColorOutput "  [OK] Proxy settings removed" "Green"
    }
    
    $newContent | Set-Content $ProfilePath -Encoding UTF8
}

function Set-SystemProxy {
    param(
        [string]$ProxyAddress,
        [bool]$SetProxy
    )
    
    Write-ColorOutput "`nSetting system environment variables (CMD proxy)..." "Cyan"
    
    if ($SetProxy) {
        [Environment]::SetEnvironmentVariable("HTTP_PROXY", $ProxyAddress, "User")
        [Environment]::SetEnvironmentVariable("HTTPS_PROXY", $ProxyAddress, "User")
        Write-ColorOutput "  [OK] User environment variables set" "Green"
        Write-ColorOutput "    HTTP_PROXY = $ProxyAddress" "Gray"
        Write-ColorOutput "    HTTPS_PROXY = $ProxyAddress" "Gray"
    } else {
        [Environment]::SetEnvironmentVariable("HTTP_PROXY", $null, "User")
        [Environment]::SetEnvironmentVariable("HTTPS_PROXY", $null, "User")
        Write-ColorOutput "  [OK] User environment variables cleared" "Green"
    }
}

function Set-GitProxy {
    param(
        [string]$ProxyAddress,
        [bool]$SetProxy
    )
    
    Write-ColorOutput "`nSetting Git proxy..." "Cyan"
    
    $gitInstalled = Get-Command git -ErrorAction SilentlyContinue
    if (-not $gitInstalled) {
        Write-ColorOutput "  [WARN] Git not installed or not in PATH" "Yellow"
        return
    }
    
    if ($SetProxy) {
        git config --global http.proxy $ProxyAddress
        git config --global https.proxy $ProxyAddress
        Write-ColorOutput "  [OK] Git global proxy set" "Green"
        Write-ColorOutput "    http.proxy = $ProxyAddress" "Gray"
        Write-ColorOutput "    https.proxy = $ProxyAddress" "Gray"
    } else {
        git config --global --unset http.proxy 2>$null
        git config --global --unset https.proxy 2>$null
        Write-ColorOutput "  [OK] Git global proxy cleared" "Green"
    }
}

function Show-ProxyStatus {
    Write-ColorOutput "`n" "White"
    Write-ColorOutput "========================================" "Cyan"
    Write-ColorOutput "          Current Proxy Status" "Cyan"
    Write-ColorOutput "========================================" "Cyan"
    
    Write-ColorOutput "`n[Current PowerShell Session]" "Yellow"
    Write-ColorOutput "  HTTP_PROXY  = $env:HTTP_PROXY" "Gray"
    Write-ColorOutput "  HTTPS_PROXY = $env:HTTPS_PROXY" "Gray"
    
    Write-ColorOutput "`n[System Environment Variables (CMD)]" "Yellow"
    $userHttpProxy = [Environment]::GetEnvironmentVariable("HTTP_PROXY", "User")
    $userHttpsProxy = [Environment]::GetEnvironmentVariable("HTTPS_PROXY", "User")
    Write-ColorOutput "  HTTP_PROXY  = $userHttpProxy" "Gray"
    Write-ColorOutput "  HTTPS_PROXY = $userHttpsProxy" "Gray"
    
    Write-ColorOutput "`n[Git Global Config]" "Yellow"
    $gitInstalled = Get-Command git -ErrorAction SilentlyContinue
    if ($gitInstalled) {
        $gitHttpProxy = git config --global --get http.proxy 2>$null
        $gitHttpsProxy = git config --global --get https.proxy 2>$null
        Write-ColorOutput "  http.proxy  = $gitHttpProxy" "Gray"
        Write-ColorOutput "  https.proxy = $gitHttpsProxy" "Gray"
    } else {
        Write-ColorOutput "  Git not installed" "Red"
    }
    
    Write-ColorOutput "`n========================================`n" "Cyan"
}

# Main Program
Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput "     Proxy Configuration Tool v1.0" "Cyan"
Write-ColorOutput "========================================" "Cyan"

$setProxy = ($Action -eq "set")

if ($setProxy) {
    Write-ColorOutput "`nSetting proxy to: $ProxyAddress" "Yellow"
} else {
    Write-ColorOutput "`nClearing all proxy settings" "Yellow"
}

$ps5ProfilePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
$ps7ProfilePath = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"

# 1. Update PowerShell 5.x profile
Update-PowerShellProfile -ProfilePath $ps5ProfilePath -ProxyAddress $ProxyAddress -SetProxy $setProxy

# 2. Update PowerShell 7+ profile
Update-PowerShellProfile -ProfilePath $ps7ProfilePath -ProxyAddress $ProxyAddress -SetProxy $setProxy

# 3. Set system environment variables (CMD)
Set-SystemProxy -ProxyAddress $ProxyAddress -SetProxy $setProxy

# 4. Set Git proxy
Set-GitProxy -ProxyAddress $ProxyAddress -SetProxy $setProxy

# Apply to current session
if ($setProxy) {
    $env:HTTP_PROXY = $ProxyAddress
    $env:HTTPS_PROXY = $ProxyAddress
    Write-ColorOutput "`n[OK] Applied to current PowerShell session" "Green"
} else {
    $env:HTTP_PROXY = $null
    $env:HTTPS_PROXY = $null
    Write-ColorOutput "`n[OK] Cleared from current PowerShell session" "Green"
}

# Display current status
Show-ProxyStatus

Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput "Done!" "Green"
Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput "`nNote:" "Yellow"
Write-ColorOutput "  * PowerShell config will take effect on next startup" "Gray"
Write-ColorOutput "  * CMD environment variables need to reopen CMD window" "Gray"
Write-ColorOutput "  * Git proxy is effective immediately" "Gray"
Write-ColorOutput ""
