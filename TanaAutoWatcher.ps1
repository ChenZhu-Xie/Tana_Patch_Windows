# ============================================================================
# Tana Update Watcher (Quicker 增强版)
# ============================================================================

# 1. [关键] 修复 Quicker 中的中文乱码问题
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 配置信息
$ScriptFileName = "TanaPatch.ps1"
$TanaBasePath = "$env:LOCALAPPDATA\tana"
# [保底路径]：如果 Path 环境变量没生效，就用这个路径 (请根据实际情况确认此路径)
$FallbackPath = "D:\C2D\Desktop\Tana WX\TanaPatch.ps1"

# 2. 智能查找脚本路径
try {
    # 优先尝试从 Path 环境变量中查找
    $CommandInfo = Get-Command $ScriptFileName -ErrorAction Stop
    $ResolvedPatchPath = $CommandInfo.Source
    Write-Host "模式: 环境变量调用" -ForegroundColor Cyan
    Write-Host "已找到脚本: $ResolvedPatchPath" -ForegroundColor Green
}
catch {
    # 如果 Path 里找不到（例如 Quicker 还没重启），则尝试使用保底路径
    Write-Warning "注意：在系统 Path 中未找到 '$ScriptFileName' (可能是 Quicker 未重启导致)。"
    
    if (Test-Path $FallbackPath) {
        $ResolvedPatchPath = $FallbackPath
        Write-Host "已启用保底路径: $ResolvedPatchPath" -ForegroundColor Yellow
    }
    else {
        # 如果保底路径也找不到，彻底报错
        Write-Error "严重错误：无法找到补丁脚本！"
        Write-Error "1. 请检查系统 Path 环境变量。"
        Write-Error "2. 或检查保底路径是否存在: $FallbackPath"
        exit 1
    }
}

Write-Host "正在监控 Tana 更新目录: $TanaBasePath" -ForegroundColor Cyan

# 创建文件系统监视器
$Watcher = New-Object System.IO.FileSystemWatcher
$Watcher.Path = $TanaBasePath
$Watcher.Filter = "app-*"
$Watcher.IncludeSubdirectories = $false
$Watcher.EnableRaisingEvents = $true

# 将解析后的路径存入 Global，供事件内部调用
$Global:PatchScriptPath = $ResolvedPatchPath

# 定义事件触发动作
$Action = {
    $Name = $Event.SourceEventArgs.Name
    $TimeStamp = $Event.TimeGenerated

    Write-Host "[$TimeStamp] 检测到新版本: $Name" -ForegroundColor Yellow
    
    Write-Host "等待 30 秒以确保解压完成..." 
    Start-Sleep -Seconds 30

    Write-Host "开始执行补丁..."
    # 使用解析出的绝对路径执行
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$Global:PatchScriptPath`"" -Wait
    Write-Host "补丁执行完毕。" -ForegroundColor Green
}

# 注册事件
Register-ObjectEvent $Watcher "Created" -SourceIdentifier "TanaUpdateDetected" -Action $Action

# 保持运行
while ($true) {
    Start-Sleep -Seconds 5
}
