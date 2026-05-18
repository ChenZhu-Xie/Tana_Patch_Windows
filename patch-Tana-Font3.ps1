<#
.SYNOPSIS
    Tana Custom CSS Patch for Windows
.DESCRIPTION
    Patches Tana app by embedding custom CSS directly into preload.js
    Ported from Raycast script by dreetje
#>

# ============================================================================
# CONFIGURATION - Edit these values to customize the CSS injection
# ============================================================================

# Option 1: Use CSS from a URL (set $UseInlineCss = $false)
$CssUrl = "https://gist.githubusercontent.com/foeken/cd809018e6caf846d174f656bb30109c/raw/313e673744ad85205351ce0d6a32a75d14f27120/tana.css"

# Option 2: Use inline CSS (set $UseInlineCss = $true and paste your CSS below)
$UseInlineCss = $true

# Paste your CSS here (inside the @" "@ block) if using inline CSS:
$InlineCss = @"
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
"@


# Path Configuration (Based on your provided path)
# 注意：当 Tana 更新版本号时，你需要更新这里的路径
$TanaBuildPath = "C:\Users\Xcz\AppData\Local\tana\app-1.498.21\resources\app\build"
$TanaPreloadPath = Join-Path -Path $TanaBuildPath -ChildPath "preload.js"
# Tana 主程序路径 (通常位于 Local\tana 目录下，用于重启)
$TanaExePath = "C:\Users\Xcz\AppData\Local\tana\Tana Outliner.exe"

# ============================================================================
# SCRIPT LOGIC
# ============================================================================

Write-Host "Checking Tana installation..." -ForegroundColor Cyan

# Check if Tana preload file exists
if (-not (Test-Path -Path $TanaPreloadPath)) {
    Write-Error "Tana preload.js not found at: $TanaPreloadPath"
    exit 1
}

# Check if already patched and handle re-patching
$CurrentContent = Get-Content -Path $TanaPreloadPath -Raw
if ($CurrentContent -match "TANA_CUSTOM_CSS_INJECTED") {
    Write-Host "Existing patch found." -ForegroundColor Yellow
    
    # Check if backup exists
    $BackupPath = "$TanaPreloadPath.backup"
    if (-not (Test-Path -Path $BackupPath)) {
        Write-Error "No backup found - cannot safely update. Please reinstall Tana to reset."
        exit 1
    }

    # Restore from backup first
    Write-Host "Restoring from backup..."
    Copy-Item -Path $BackupPath -Destination $TanaPreloadPath -Force
}

# Get CSS content based on configuration
$CssContent = ""
if ($UseInlineCss) {
    Write-Host "Using Inline CSS..."
    $CssContent = $InlineCss
}
else {
    Write-Host "Downloading CSS from URL..."
    try {
        $CssContent = Invoke-RestMethod -Uri $CssUrl -Method Get
    }
    catch {
        Write-Error "Failed to download CSS: $_"
        exit 1
    }

    if ([string]::IsNullOrWhiteSpace($CssContent)) {
        Write-Error "Downloaded CSS is empty."
        exit 1
    }
}

# Create a backup (only if one doesn't exist)
if (-not (Test-Path -Path "$TanaPreloadPath.backup")) {
    Write-Host "Creating backup..."
    Copy-Item -Path $TanaPreloadPath -Destination "$TanaPreloadPath.backup"
}

# Escape the CSS content for JavaScript string
# PowerShell specific escaping to match the original sed logic:
# 1. Escape backslashes
# 2. Escape single quotes
# 3. Escape double quotes
# 4. Remove newlines (replace with space to keep it one line in JS)
$CssEscaped = $CssContent.Replace("\", "\\").Replace("'", "\'").Replace('"', '\"').Replace("`r", "").Replace("`n", " ")

# The code to inject
# Note: Using PowerShell escaping (backtick `) for internal quotes
$InjectionCode = @"

// TANA_CUSTOM_CSS_INJECTED - DO NOT REMOVE THIS MARKER
document.onreadystatechange = async (event) => {
  if (document.readyState == "complete") {
    try {
        // FIX: 使用双引号包裹，确保 PowerShell 能正确将变量内容填入
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

# Append the code to the file
Write-Host "Injecting CSS loader..."
Add-Content -Path $TanaPreloadPath -Value $InjectionCode

# Restart Tana
Write-Host "Restarting Tana..."
$TanaProcess = Get-Process -Name "Tana Outliner" -ErrorAction SilentlyContinue
if ($TanaProcess) {
    Stop-Process -Name "Tana Outliner" -Force
    Start-Sleep -Seconds 1
}

if (Test-Path -Path $TanaExePath) {
    Start-Process -FilePath $TanaExePath
    Write-Host "Custom CSS applied successfully!" -ForegroundColor Green
} else {
    Write-Host "Custom CSS applied, but could not find Tana Outliner.exe to restart automatically." -ForegroundColor Yellow
    Write-Host "Please start Tana manually."
}
