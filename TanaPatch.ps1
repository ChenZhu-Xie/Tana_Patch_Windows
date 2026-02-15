<#
.SYNOPSIS
    Tana Custom CSS/JS Patch - Cyber-Focus Refined (Dual-Track + Descendants)
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
    font-weight: 300 !important;
    color: #FF6AC2 !important; 
    text-shadow: 0 0 10px rgba(255, 106, 194, 0.3) !important;
}

/* ===== 全路径聚焦系统 (Focus - 背景色) ===== */

/* 1. 父辈路径 - 晶莹青 */
.tana-focus-ancestor > div > div[class*="NodeAsListElement-module_main"] {
    background-color: rgba(139, 233, 253, 0.08) !important; 
    border-left: 2px solid rgba(139, 233, 253, 0.3) !important;
    transition: background-color 0.3s ease !important;
}

/* 2. 当前焦点节点 - 霓虹粉 */
.tana-focus-current > div > div[class*="NodeAsListElement-module_main"] {
    background-color: rgba(255, 121, 198, 0.15) !important;
    border-radius: 6px !important;
    box-shadow: 0 0 15px rgba(255, 121, 198, 0.1) !important;
    border-left: 2px solid rgba(255, 121, 198, 0.5) !important;
    transition: background-color 0.2s ease !important;
}

/* 3. 焦点子孙节点 - 梦幻紫 */
.tana-focus-current [data-is-node-container] > div > div[class*="NodeAsListElement-module_main"] {
    background-color: rgba(189, 147, 249, 0.06) !important;
    border-left: 2px solid rgba(189, 147, 249, 0.2) !important;
}

/* ===== 全路径悬停系统 (Hover - 虚线边框) ===== */

/* 1. 悬停父辈路径 - 虚线青 */
.tana-hover-ancestor > div > div[class*="NodeAsListElement-module_main"] {
    border-left: 2px dashed rgba(139, 233, 253, 0.5) !important;
}

/* 2. 当前悬停节点 - 虚线粉框 */
.tana-hover-current > div > div[class*="NodeAsListElement-module_main"] {
    outline: 2px dashed rgba(255, 121, 198, 0.5) !important;
    outline-offset: -2px !important;
    border-radius: 6px !important;
}

/* 3. 悬停子孙节点 - 虚线紫框 */
.tana-hover-current [data-is-node-container] > div > div[class*="NodeAsListElement-module_main"] {
    border-left: 2px dashed rgba(189, 147, 249, 0.4) !important;
}

/* ===== 其他格式化样式 ===== */
div[class*="sectionHeading"] .editable, .isSection .editable {
    font-size: 30px !important; color: #4CC9F0 !important; 
}
b, strong { color: #98ffb3 !important; }
i, em, .italic { color: #FF5555 !important; font-style: italic !important; }
u, .underline { text-decoration: none !important; border-bottom: 2px solid #FFB86C !important; }

/* 删除线 */
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
Write-Host "Updating CSS: Bringing back Descendants (Dreamy Purple)..." -ForegroundColor Cyan

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

        const nodeSelector = '[data-is-node-container]';
        
        const states = {
            focus: { 
                last: null, 
                nodes: new Set(), 
                classes: { current: 'tana-focus-current', ancestor: 'tana-focus-ancestor' } 
            },
            hover: { 
                last: null, 
                nodes: new Set(), 
                classes: { current: 'tana-hover-current', ancestor: 'tana-hover-ancestor' } 
            }
        };

        const updateTrack = (type, target) => {
            const container = target.closest(nodeSelector);
            const state = states[type];
            if (!container || container === state.last) return;

            requestAnimationFrame(() => {
                state.nodes.forEach(el => el.classList.remove(state.classes.current, state.classes.ancestor));
                state.nodes.clear();

                state.last = container;
                container.classList.add(state.classes.current);
                state.nodes.add(container);

                let p = container.parentElement;
                while(p) {
                    if (p.hasAttribute && p.hasAttribute('data-is-node-container')) {
                        p.classList.add(state.classes.ancestor);
                        state.nodes.add(p);
                    }
                    p = p.parentElement;
                }
            });
        };

        document.addEventListener('pointerover', (e) => updateTrack('hover', e.target), {passive: true});
        document.addEventListener('focusin', (e) => updateTrack('focus', e.target), {passive: true});
        
        console.log('Cyber-Focus Engine V3.1 (Descendants Restored) Active');
    } catch (err) { console.error('Patch Error:', err); }
  }
};
"@

$PatchedContent = $OriginalContent + "`r`n" + $JsLogic
Set-Content -Path $TanaPreloadPath -Value $PatchedContent -Encoding UTF8

Write-Host "Patch with Descendants applied successfully!" -ForegroundColor Green

# 重启 Tana
Stop-Process -Name "Tana" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
if (Test-Path -Path $TanaExePath) { Start-Process -FilePath $TanaExePath }
