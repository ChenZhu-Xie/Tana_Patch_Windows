# patch-tana-css.ps1
# Purpose: Patch Tana (Windows) preload.js to inject custom CSS (e.g., change fonts)
# Usage examples:
#   powershell -ExecutionPolicy Bypass -File .\patch-tana-css.ps1
#   powershell -ExecutionPolicy Bypass -File .\patch-tana-css.ps1 -UseInlineCss
#   powershell -ExecutionPolicy Bypass -File .\patch-tana-css.ps1 -CssUrl "https://example.com/tana.css"
#   powershell -ExecutionPolicy Bypass -File .\patch-tana-css.ps1 -Restore

param(
  [string]$CssUrl = "",
  [switch]$UseInlineCss = $true,
  [switch]$Restore = $false
)

$Marker = "TANA_CUSTOM_CSS_INJECTED"
$ErrorActionPreference = "Stop"

# -------- 1) Find preload.js on Windows --------
function Get-TanaPreloadPath {
  $candidates = @(
    Join-Path $env:LOCALAPPDATA "Programs\Tana\resources\app\build\preload.js",
    Join-Path $env:LOCALAPPDATA "Tana\resources\app\build\preload.js"
  )

  foreach ($p in $candidates) {
    if (Test-Path $p) { return $p }
  }

  # common pattern: %LOCALAPPDATA%\Tana\app-*\resources\app\build\preload.js
  $root = Join-Path $env:LOCALAPPDATA "Tana"
  if (Test-Path $root) {
    $found = Get-ChildItem -Path $root -Recurse -Filter "preload.js" -File -ErrorAction SilentlyContinue |
      Where-Object { $_.FullName -match "\\resources\\app\\build\\preload\.js$" } |
      Select-Object -First 1
    if ($found) { return $found.FullName }
  }

  # fallback brute search (can be slow)
  $roots = @($env:LOCALAPPDATA, $env:ProgramFiles, ${env:ProgramFiles(x86)})
  foreach ($r in $roots) {
    if (-not $r -or -not (Test-Path $r)) { continue }
    $found2 = Get-ChildItem -Path $r -Recurse -Filter "preload.js" -File -ErrorAction SilentlyContinue |
      Where-Object { $_.FullName -match "Tana" -and $_.FullName -match "\\resources\\app\\build\\preload\.js$" } |
      Select-Object -First 1
    if ($found2) { return $found2.FullName }
  }

  return $null
}

$PreloadPath = Get-TanaPreloadPath
if (-not $PreloadPath) {
  throw "找不到 Tana 的 preload.js。请确认已安装 Tana，并把你的安装路径/截图发我，我再帮你定向改。"
}

$BackupPath = "$PreloadPath.backup"

Write-Host "Using preload.js: $PreloadPath"

# -------- 2) Restore mode --------
if ($Restore) {
  if (-not (Test-Path $BackupPath)) {
    throw "未找到备份文件：$BackupPath"
  }
  Copy-Item -Force $BackupPath $PreloadPath
  Write-Host "已从备份恢复：$BackupPath -> $PreloadPath"
  exit 0
}

# -------- 3) Create backup (once) --------
if (-not (Test-Path $BackupPath)) {
  Copy-Item -Force $PreloadPath $BackupPath
  Write-Host "已创建备份：$BackupPath"
}

# -------- 4) Load CSS --------
# Option A: inline CSS (edit here)
$InlineCss = @'
/* ===== Tana Font Override (Windows) ===== */

/* UI + editor text */
html, body, button, input, textarea, select {
  font-family:
    "Inconsolata-LXGWMono",
    "LXGW WenKai",
    "霞鹜文楷",
    "Microsoft YaHei UI",
    "Segoe UI",
    sans-serif !important;
}

/* Code-like areas */
code, pre, kbd, samp {
  font-family:
    "JetBrains Mono",
    "LXGW WenKai Mono",
    Consolas,
    "Courier New",
    monospace !important;
}

/* Optional: slightly improve readability */
body {
  font-size: 14.5px !important;
  line-height: 1.75 !important;
  -webkit-font-smoothing: antialiased;
  text-rendering: optimizeLegibility;
}
'@

$CssContent = ""
if ($UseInlineCss) {
  $CssContent = $InlineCss
  Write-Host "CSS source: inline"
} else {
  if (-not $CssUrl) { throw "UseInlineCss=false 时必须提供 -CssUrl" }
  Write-Host "Downloading CSS from: $CssUrl"
  $resp = Invoke-WebRequest -Uri $CssUrl -UseBasicParsing
  $CssContent = [string]$resp.Content
  Write-Host "CSS source: url"
}

# -------- 5) Read preload.js and (re)patch --------
$orig = Get-Content -Raw -Encoding UTF8 $PreloadPath

# If already patched, restore from backup first (safer)
if ($orig -match $Marker) {
  Write-Host "Detected existing patch marker, restoring from backup then re-patching..."
  $orig = Get-Content -Raw -Encoding UTF8 $BackupPath
}

# Escape CSS for JS template literal
$cssJson = $CssContent | ConvertTo-Json -Compress

$injectJs = @"
;/* $Marker */
(function () {
  try {
    const css = $cssJson; // safe JS string
    const apply = () => {
      const id = "tana-custom-css";
      let el = document.getElementById(id);
      if (!el) {
        el = document.createElement("style");
        el.id = id;
        el.type = "text/css";
        document.head.appendChild(el);
      }
      el.textContent = css;
    };

    if (document.readyState === "loading") {
      document.addEventListener("DOMContentLoaded", apply, { once: true });
    } else {
      apply();
    }
  } catch (e) {
    console.error("Tana custom CSS inject failed:", e);
  }
})();
"@
# Append injection block near the end (simple + robust)
$patched = $orig + "`r`n" + $injectJs + "`r`n"

Set-Content -Path $PreloadPath -Value $patched -Encoding UTF8
Write-Host "Patch applied OK."
Write-Host "If Tana doesn't start, run: powershell -ExecutionPolicy Bypass -File .\patch-tana-css.ps1 -Restore"