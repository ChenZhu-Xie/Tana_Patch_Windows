<#
.SYNOPSIS
    Tana Custom CSS/JS Patch - Cyber-Focus Refined
#>

# ============================================================================
# CONFIGURATION
# ============================================================================

$UseInlineCss = $true
$InlineCss = @"
/* ===== 基础编辑器样式 ===== */
.editable, .content {
  font-family: "Inconsolata-LXGWMono" !important;
  font-size: 20px !important;
}

/* ===== 霓虹文字效果 ===== */
.node-title, h1, h2, h3, h4, h5, h6 {
    font-size: 30px !important; 
    font-weight: 350 !important;
    color: #FF6AC2 !important; 
    text-shadow: 0 0 10px rgba(255, 106, 194, 0.3) !important;
}

/* ===== 全路径聚焦系统 (层级不透明度优化) ===== */

/* 1. 父辈/祖辈节点背景 - 深空蓝 (更显著的路径指引) */
.tana-ancestor > div > div[class*="NodeAsListElement-module_main"] {
    background-color: rgba(68, 71, 90, 0.35) !important; /* 增加不透明度 */
    transition: background-color 0.3s ease !important;
}

/* 2. 当前焦点节点 - 魅惑紫 */
.tana-current > div > div[class*="NodeAsListElement-module_main"] {
    background-color: rgba(255, 121, 198, 0.3) !important;
    border-radius: 6px !important;
    box-shadow: inset 0 0 20px rgba(255, 121, 198, 0.2) !important;
    transition: background-color 0.2s ease !important;
}

/* 3. 子孙节点背景 - 薰衣草紫 (更轻量的预览) */
.tana-descendant > div > div[class*="NodeAsListElement-module_main"] {
    background-color: rgba(189, 147, 249, 0.12) !important; /* 降低不透明度 */
    transition: background-color 0.4s ease !important;
}

/* ===== 其他格式化样式 ===== */
div[class*="sectionHeading"] .editable, .isSection .editable {
    font-size: 30px !important; color: #4CC9F0 !important; 
}
b, strong { color: #98ffb3 !important; }
i, em, .italic { color: #FF5555 !important; font-style: italic !important; }
u, .underline { text-decoration: none !important; border-bottom: 2px solid #FFB86C !important; }

/* 删除线 - 更新为 #cba6f7 */
strike, s, del, [class*="strikethrough"] {
    text-decoration: line-through !important;
    color: #cba6f7 !important;
    opacity: 0.6 !important;
}

code, pre { color: #80FFEA !important; background-color: rgba(128, 255, 234, 0.1) !important; border-radius: 4px; padding: 2px 4px; }
mark, .highlight { background-color: rgba(241, 250, 140, 0.15) !important; color: #F1FA8C !important; border-radius: 4px; }
"@

# ============================================================================
# 自动路径发现
# ============================================================================
$TanaBasePath = "$env:LOCALAPPDATA\tana"
$LatestVersionDir = Get-ChildItem -Path $TanaBasePath -Directory -Filter "app-*" | 
    Select-Object FullName, @{N='Version';E={[version]($_.Name -replace 'app-','')}} | 
    Sort-Object Version -Descending | 
    Select-Object -First 1
$TanaPreloadPath = Join-Path -Path $LatestVersionDir.FullName -ChildPath "resources\app\build\preload.js"
$TanaExePath = "$TanaBasePath\Tana.exe"

# ============================================================================
# 执行补丁
# ============================================================================
Write-Host "Updating CSS: Strikethrough color and Hierarchy Opacity..." -ForegroundColor Cyan

if (Test-Path -Path "$TanaPreloadPath.backup") {
    $OriginalContent = Get-Content -Path "$TanaPreloadPath.backup" -Raw
} else {
    $OriginalContent = Get-Content -Path $TanaPreloadPath -Raw
    Copy-Item -Path $TanaPreloadPath -Destination "$TanaPreloadPath.backup"
}

$CssEscaped = $InlineCss.Replace("\", "\\").Replace("'", "\'").Replace('"', '\"').Replace("`r", "").Replace("`n", " ")

$JsLogic = @"

// TANA_CUSTOM_CSS_INJECTED - DO NOT REMOVE THIS MARKER
document.onreadystatechange = async (event) => {
  if (document.readyState == "complete") {
    try {
        const styleSheet = document.createElement("style");
        styleSheet.innerText = "$CssEscaped";
        document.head.appendChild(styleSheet);

        const nodeSelector = 'div[data-is-node-container="true"]';
        let lastContainer = null;

        const updateContext = (e) => {
            const container = e.target.closest(nodeSelector);
            if (!container || container === lastContainer) return;

            document.querySelectorAll('.tana-ancestor, .tana-current, .tana-descendant').forEach(el => {
                el.classList.remove('tana-ancestor', 'tana-current', 'tana-descendant');
            });

            lastContainer = container;
            container.classList.add('tana-current');

            let p = container.parentElement;
            while(p) {
                if (p.hasAttribute && p.hasAttribute('data-is-node-container')) p.classList.add('tana-ancestor');
                p = p.parentElement;
            }

            container.querySelectorAll(nodeSelector).forEach(child => child.classList.add('tana-descendant'));
        };

        document.addEventListener('mouseover', updateContext, {passive: true});
        document.addEventListener('focusin', updateContext, {passive: true});
        console.log('Cyber-Focus Refined Engine Active');
    } catch (err) { console.error('Patch Error:', err); }
  }
};
"@

$PatchedContent = $OriginalContent + "`r`n" + $JsLogic
Set-Content -Path $TanaPreloadPath -Value $PatchedContent

Write-Host "Patch refined successfully!" -ForegroundColor Green

# 重启 Tana
Stop-Process -Name "Tana" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
if (Test-Path -Path $TanaExePath) { Start-Process -FilePath $TanaExePath }
