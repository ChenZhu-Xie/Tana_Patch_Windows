---
name: windows-ps-dev
description: Specialized guidance for software development in Windows PowerShell environments. Use when working on Windows to handle paths with spaces/Chinese characters, use correct command separators, and manage PowerShell-specific quirks.
---

# Windows PowerShell Development Guide

## Core Mandates

1.  **Command Separators**: ALWAYS use `;` instead of `&&` for sequential commands in PowerShell.
2.  **Path Handling**: 
    *   ALWAYS wrap file paths in double quotes `"`.
    *   Handle spaces and non-ASCII (e.g., Chinese) characters by ensuring the shell environment supports UTF-8.
3.  **PowerShell Execution**: 
    *   To run local scripts, use `.\script.ps1`.
    *   If execution policy issues occur, suggest `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass`.
4.  **Encoding**: Use UTF-8 for all file operations (`Set-Content -Encoding UTF8`, etc.) to prevent corruption of Chinese characters.

## Common Workflows

### Git Operations
`git add "file name with spaces.txt"; git commit -m "message"`

### File Content Manipulation
Use `Get-Content -Raw` for reading and `Set-Content -Value $content -Encoding UTF8` for writing to preserve formatting and characters.
