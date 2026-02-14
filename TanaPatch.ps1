<#
.SYNOPSIS
    Tana Custom CSS Patch (Auto-Detect Version)
#>

# ============================================================================
# CONFIGURATION
# ============================================================================

$UseInlineCss = $true
$InlineCss = @"
/* https://github.com/rcvd/Tana-CSS-Snippets/blob/main/Custom%20Formats/custom-formats.css */
/* ===== Tana Font Override (Windows) ===== */

/* editor text */
.editable, .content {
  font-family: "Inconsolata-LXGWMono" !important;
  font-size: 20px !important;
  letter-spacing: 0.00em !important;
  text-rendering: optimizeLegibility;
  -webkit-font-smoothing: antialiased;
}

/* Code-like areas */
code, pre, kbd, samp {
  font-family:
    "Inconsolata-LXGWMono",
    "JetBrains Mono",
    "LXGW WenKai Mono GB",
    Consolas,
    "Courier New",
    monospace !important;
  font-size: 16px !important;
}

.node-title, h1, h2, h3, h4, h5, h6 {
    font-size: 30px !important; 
    font-weight: 350 !important; /* 300 is regular */
    letter-spacing: 0.015em !important;
    color: #FF6AC2 !important; /* 霓虹粉 */
}

/* 针对包含 sectionHeading 特征的父级下的编辑区 */
div[class*="NodeAsListElement-module_sectionHeading"] .editable,
.isSection .editable {
    font-size: 30px !important; 
    font-weight: 350 !important;
    letter-spacing: 0.015em !important;
    color: #4CC9F0 !important; /* 极光青 */
}

/* 加粗 - 极光绿 */
strong, b {
    font-size: inherit !important;
    font-weight: 350 !important;
    color: #98ffb3 !important;
}

/* 斜体 - 丁香紫 */
em, i, .italic {
    font-style: italic !important;
    color: #BD93F9 !important;
}

/* 下划线 - 活力橙 (现代底边线风格) */
u, .underline {
    text-decoration: none !important;
    border-bottom: 2px solid #FFB86C !important;
    padding-bottom: 1px !important;
}

/* 删除线 - 增加兼容性选择器 */
s, del, .strikethrough, span[style*="line-through"] {
    text-decoration: line-through !important;
    color: #94a3b8 !important;
    opacity: 0.5 !important;
}

/* 高亮 - 增加 mark 和 .highlight，改用明亮黄 */
mark, .highlight, .expandedHighlight, .tanas-highlight {
    background-color: rgba(241, 250, 140, 0.2) !important;
    color: #F1FA8C !important;
    padding: 0 4px !important;
    border-radius: 4px !important;
    border: 1px solid rgba(241, 250, 140, 0.4) !important;
    font-weight: 450 !important;
}
"@

# ============================================================================
# 自动路径发现逻辑 (核心修改)
# ============================================================================

Write-Host "Searching for latest Tana version..." -ForegroundColor Cyan

# 1. 定位 Tana 根目录
$TanaBasePath = "$env:LOCALAPPDATA\tana"

if (-not (Test-Path $TanaBasePath)) {
    Write-Error "Tana installation directory not found at: $TanaBasePath"
    exit 1
}

# 2. 获取所有 app- 开头的文件夹，解析版本号并排序
#    逻辑：找到 app-1.506.0, app-1.507.0 等，按版本号降序排列，取第一个
$LatestVersionDir = Get-ChildItem -Path $TanaBasePath -Directory -Filter "app-*" | 
    Select-Object FullName, @{N='Version';E={[version]($_.Name -replace 'app-','')}} | 
    Sort-Object Version -Descending | 
    Select-Object -First 1

if (-not $LatestVersionDir) {
    Write-Error "Could not find any Tana version folders (app-x.x.x)."
    exit 1
}

Write-Host "Found latest version: $($LatestVersionDir.Version)" -ForegroundColor Green

# 3. 动态构建路径
$TanaBuildPath = Join-Path -Path $LatestVersionDir.FullName -ChildPath "resources\app\build"
$TanaPreloadPath = Join-Path -Path $TanaBuildPath -ChildPath "preload.js"
$TanaExePath = "$TanaBasePath\Tana.exe"

# ============================================================================
# 执行补丁逻辑 (保持原有逻辑，稍作优化)
# ============================================================================

if (-not (Test-Path -Path $TanaPreloadPath)) {
    Write-Error "preload.js not found at: $TanaPreloadPath"
    exit 1
}

# 读取当前内容
$CurrentContent = Get-Content -Path $TanaPreloadPath -Raw

# 检查是否已经 Patch 过
if ($CurrentContent -match "TANA_CUSTOM_CSS_INJECTED") {
    Write-Host "Patch already detected." -ForegroundColor Yellow
    # 如果已经是最新版本且已 patch，直接退出，避免重复写入
    # 如果你想强制覆盖（例如改了CSS），可以注释掉下面这行
    # exit 0 
    
    # 恢复备份以便重新注入新的 CSS
    $BackupPath = "$TanaPreloadPath.backup"
    if (Test-Path -Path $BackupPath) {
        Write-Host "Restoring backup to re-apply CSS..."
        Copy-Item -Path $BackupPath -Destination $TanaPreloadPath -Force
    }
} else {
    # 创建备份
    Copy-Item -Path $TanaPreloadPath -Destination "$TanaPreloadPath.backup"
    Write-Host "Backup created."
}

# 处理 CSS 字符串转义
$CssEscaped = $InlineCss.Replace("\", "\\").Replace("'", "\'").Replace('"', '\"').Replace("`r", "").Replace("`n", " ")

# 注入代码
$InjectionCode = @"

// TANA_CUSTOM_CSS_INJECTED - DO NOT REMOVE THIS MARKER
document.onreadystatechange = async (event) => {
  if (document.readyState == "complete") {
    try {
        const css = "$CssEscaped"; 
        var styleSheet = document.createElement("style");
        styleSheet.innerText = css;
        document.head.appendChild(styleSheet);
        console.log('Tana custom CSS applied successfully');
    } catch (err) {
        console.error('Failed to apply custom CSS:', err);
    }
  }
};
"@

Add-Content -Path $TanaPreloadPath -Value $InjectionCode
Write-Host "Patch applied successfully to $($LatestVersionDir.Version)" -ForegroundColor Green

# 重启 Tana
$TanaProcess = Get-Process -Name "Tana" -ErrorAction SilentlyContinue
if ($TanaProcess) {
    Stop-Process -Name "Tana" -Force
    Start-Sleep -Seconds 2
}

if (Test-Path -Path $TanaExePath) {
    Start-Process -FilePath $TanaExePath
}
