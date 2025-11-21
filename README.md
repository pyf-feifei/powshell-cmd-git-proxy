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

## 许可证

MIT License

