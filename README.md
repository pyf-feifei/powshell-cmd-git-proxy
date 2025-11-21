# 代理配置管理工具

一键管理 PowerShell、CMD 和 Git 的代理设置。

## 功能特性

✅ 自动修改两个 PowerShell 配置文件：

- `WindowsPowerShell\Microsoft.PowerShell_profile.ps1` (PowerShell 5.x)
- `PowerShell\Microsoft.PowerShell_profile.ps1` (PowerShell 7+)

✅ 设置 Windows 用户环境变量（CMD 永久代理）

✅ 设置 Git 全局代理配置

✅ 支持一键清除所有代理设置

## 使用方法

### 1. 设置代理（使用默认地址）

```powershell
.\Set-Proxy.ps1 -Action set
```

默认代理地址为：`http://127.0.0.1:7890`

### 2. 设置代理（自定义地址）

```powershell
.\Set-Proxy.ps1 -ProxyAddress "http://127.0.0.1:7890" -Action set
```

### 3. 清除所有代理

```powershell
.\Set-Proxy.ps1 -Action clear
```

## 快捷方式

为了方便使用，提供了两个快捷脚本：

### 启用代理

```powershell
.\Enable-Proxy.ps1
```

### 禁用代理

```powershell
.\Disable-Proxy.ps1
```

## 权限要求

需要**管理员权限**运行（用于修改系统环境变量）

右键点击 PowerShell，选择"以管理员身份运行"

## 代理设置说明

### PowerShell 代理

通过在配置文件开头添加环境变量：

```powershell
$Env:http_proxy="http://127.0.0.1:7890"
$Env:https_proxy="http://127.0.0.1:7890"
```

### CMD 代理

设置用户环境变量：

- `HTTP_PROXY`
- `HTTPS_PROXY`

### Git 代理

设置全局 Git 配置：

```bash
git config --global http.proxy http://127.0.0.1:7890
git config --global https.proxy http://127.0.0.1:7890
```

## 查看当前状态

脚本执行后会自动显示当前所有代理的状态。

## 注意事项

1. ⚠️ **PowerShell 配置**：修改后需要重启 PowerShell 才能生效
2. ⚠️ **CMD 环境变量**：需要重新打开 CMD 窗口才能生效
3. ✅ **Git 代理**：立即生效
4. ✅ **当前 PowerShell 会话**：立即应用到当前窗口

## 文件说明

- `Set-Proxy.ps1` - 主脚本，完整的代理管理功能
- `Enable-Proxy.ps1` - 快捷启用代理（使用默认地址）
- `Disable-Proxy.ps1` - 快捷禁用所有代理
- `README.md` - 使用说明文档

## 故障排除

### 执行策略错误

如果遇到"无法加载文件，因为在此系统上禁止运行脚本"错误，请以管理员身份运行：

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 需要管理员权限

如果提示需要管理员权限，请：

1. 右键点击 PowerShell 图标
2. 选择"以管理员身份运行"
3. 再次执行脚本

## 网络故障诊断与修复

### 🚨 常见问题：关闭代理后无法访问网站

**症状：**

- 使用代理软件（Clash、v2rayN）时可以访问网站
- 关闭代理后提示 `DNS_PROBE_FINISHED_BAD_CONFIG`
- 无法访问百度等国内网站
- 浏览器提示"找不到服务器 IP 地址"

**原因：**
代理软件可能劫持了系统的 DNS 配置或系统代理设置，关闭后没有自动恢复。

### 🔧 解决方案

#### 方案 1：一键诊断（推荐第一步）

```powershell
.\Diagnose-Network.ps1
```

这个脚本会全面检查：

- Windows 系统代理状态
- DNS 服务器配置
- 环境变量代理
- 网络连接状态
- 并给出具体的修复建议

#### 方案 2：自动修复（推荐）

```powershell
.\Fix-NetworkDNS.ps1
```

这个脚本会自动：

- ✅ 清除 Windows 系统代理设置
- ✅ 重置 DNS 为自动获取
- ✅ 刷新 DNS 缓存
- ✅ 重新注册 DNS
- ✅ 测试网络连接

**需要管理员权限运行！**

#### 方案 3：手动设置可靠的 DNS

如果自动修复后还有问题，手动设置公共 DNS：

```powershell
.\Set-ManualDNS.ps1
```

这会设置：

- 主 DNS: `223.5.5.5` (阿里云)
- 备用 DNS: `119.29.29.29` (DNSPod)

#### 方案 4：恢复为自动获取 DNS

如果需要恢复为自动获取（从路由器 DHCP 获取）：

```powershell
# 使用 Fix-NetworkDNS.ps1 会自动重置为自动获取
.\Fix-NetworkDNS.ps1

# 或者手动重置
Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | ForEach-Object {Set-DnsClientServerAddress -InterfaceIndex $_.InterfaceIndex -ResetServerAddresses}
```

### ⚠️ Clash for Windows 特别提醒

如果使用 Clash for Windows，请检查以下设置：

1. **关闭 TUN 模式**

   - TUN 模式会创建虚拟网卡，可能导致网络问题
   - 在设置中确保 TUN 模式已关闭

2. **关闭系统代理**

   - 退出 Clash 时确保系统代理已关闭
   - 或使用本工具清除代理设置

3. **检查 DNS 劫持**
   - 某些配置文件可能会劫持 DNS
   - 使用 `Diagnose-Network.ps1` 检查是否有 127.0.0.1 的 DNS

### 📋 完整操作步骤

1. **关闭所有代理软件**

   - 完全退出 Clash、v2rayN 等

2. **以管理员身份运行 PowerShell**

   ```powershell
   # 先诊断问题
   .\Diagnose-Network.ps1

   # 自动修复
   .\Fix-NetworkDNS.ps1

   # 如果还有问题，手动设置 DNS
   .\Set-ManualDNS.ps1
   ```

3. **重启浏览器**

   - 完全关闭浏览器（包括后台进程）
   - 重新打开浏览器

4. **测试访问**
   - 访问 <www.baidu.com>
   - 访问 <www.qq.com>

### 🔍 为什么会出现这个问题？

1. **DNS 劫持**：代理软件为了优化解析，可能设置 DNS 为 127.0.0.1（本地）
2. **系统代理未清除**：关闭软件时没有清除 Windows 系统代理设置
3. **TUN/TAP 虚拟网卡**：某些模式会创建虚拟网卡，关闭后可能配置残留

### 💡 预防措施

1. 使用本工具管理代理：

   ```powershell
   # 启用代理
   .\Enable-Proxy.ps1

   # 禁用代理
   .\Disable-Proxy.ps1
   ```

2. 定期检查网络状态：

   ```powershell
   .\Diagnose-Network.ps1
   ```

3. 避免使用 TUN 模式（除非必要）

## 网络诊断工具说明

### `Diagnose-Network.ps1` - 诊断工具 🔍

**作用：** 全面检查网络和代理配置，显示所有可能的问题点。

**特点：** 只读检查，不修改任何配置，安全无害。

**使用场景：** 不确定问题在哪时使用。

### `Fix-NetworkDNS.ps1` - 自动修复 🔧

**作用：** 自动修复常见网络问题，恢复 DNS 为自动获取。

**操作：**

- 清除 Windows 系统代理设置
- 刷新 DNS 缓存
- 重置 DNS 为自动获取（从路由器 DHCP 获取）
- 测试网络连接

**使用场景：** 尝试恢复到默认状态，让系统自动从路由器获取 DNS。

### `Set-ManualDNS.ps1` - 手动设置 💉

**作用：** 强制设置可靠的公共 DNS 服务器。

**DNS 设置：**

- 主 DNS: 223.5.5.5（阿里云）
- 备用 DNS: 119.29.29.29（腾讯 DNSPod）

**使用场景：** 路由器 DNS 有问题时，绕过路由器直接使用公共 DNS。

### 🎯 推荐使用流程

**正常流程（稳妥）：**

```powershell
# 第1步：诊断问题（可选）
.\Diagnose-Network.ps1

# 第2步：尝试自动修复
.\Fix-NetworkDNS.ps1

# 第3步：如果还不行，强制使用公共DNS
.\Set-ManualDNS.ps1
```

**快速修复（直接）：**

```powershell
# 直接使用公共DNS，一步到位
.\Set-ManualDNS.ps1
```

## 许可证

MIT License
