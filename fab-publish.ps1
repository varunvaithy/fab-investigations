<#
.SYNOPSIS
  Publish an investigation to the FAB Investigation Portal on GitHub Pages.

.DESCRIPTION
  Takes a markdown investigation report, extracts metadata, adds it to the
  manifest, commits, and pushes — deploying automatically to GitHub Pages.

  Works from any directory, any terminal, any machine with git + gh installed.

.EXAMPLE
  # Interactive — prompts for metadata:
  fab-publish C:\path\to\My_Investigation.md

  # Fully scripted — no prompts:
  fab-publish C:\path\to\report.md -Id inv-040 -Title "My Investigation" `
    -Date 2026-06-19 -Category ring-analysis -Severity critical `
    -Summary "Found 50 tenants abusing storage" -Tenants 50 -Storage "1.2 PB" `
    -Tags china,rclone,piracy -Status active

  # From clipboard (pipe markdown content):
  Get-Clipboard | fab-publish -stdin -Title "Quick Finding"
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$FilePath,

    [switch]$Stdin,

    [string]$Id,
    [string]$Title,
    [string]$Date,
    [ValidateSet('ring-analysis','storage-abuse','edu-fraud','detection-rules',
                 'remediation-gap','brand-impersonation','consumer-fraud',
                 'business-impact','dormant-analysis','quota-abuse','multiplexing')]
    [string]$Category,
    [ValidateSet('critical','high','medium','low')]
    [string]$Severity,
    [string]$Summary,
    [int]$Tenants,
    [string]$Storage,
    [string]$Tags,
    [ValidateSet('active','pending','pending-action','pre-ingestion',
                 'ready-enforcement','validated','remediated','completed')]
    [string]$Status = 'active'
)

$ErrorActionPreference = 'Stop'
$RepoDir = 'C:\Users\varunv\fab-investigations'
$RepoRemote = 'varunvaithy/fab-investigations'

# ── Ensure repo exists locally ───────────────────────────────
if (-not (Test-Path $RepoDir)) {
    Write-Host "Cloning repo..." -ForegroundColor Cyan
    gh repo clone $RepoRemote $RepoDir
}

# Pull latest
Push-Location $RepoDir
git pull --rebase origin main 2>$null

# ── Read input ───────────────────────────────────────────────
if ($Stdin) {
    $content = $input | Out-String
    $fileName = "Investigation_$(Get-Date -Format 'yyyyMMdd_HHmmss').md"
} elseif ($FilePath) {
    if (-not (Test-Path $FilePath)) {
        Write-Error "File not found: $FilePath"
        Pop-Location; return
    }
    $content = Get-Content $FilePath -Raw -Encoding UTF8
    $fileName = Split-Path $FilePath -Leaf
} else {
    Write-Host ""
    Write-Host "fab-publish — Publish investigation to GitHub Pages" -ForegroundColor Cyan
    Write-Host "Usage: fab-publish <path-to-markdown-file>" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Or with full params:" -ForegroundColor Gray
    Write-Host '  fab-publish report.md -Id inv-040 -Title "My Report" -Category ring-analysis -Severity critical' -ForegroundColor DarkGray
    Pop-Location; return
}

# ── Auto-extract metadata from markdown frontmatter / H1 ────
$autoTitle = ''
$autoDate = Get-Date -Format 'yyyy-MM-dd'
$autoId = ''

# Try to get title from first H1
if ($content -match '(?m)^#\s+(.+)') {
    $autoTitle = $Matches[1].Trim()
    # Try to extract INV-XXX from title
    if ($autoTitle -match '(INV-\d+|inv-\d+)') {
        $autoId = $Matches[1].ToLower().Replace('inv-', 'inv-')
    }
}

# Try to get date from content
if ($content -match '(?i)(?:investigation\s+)?date[:\s]*\**\s*(\d{4}[-/]\d{1,2}[-/]\d{1,2})') {
    $autoDate = $Matches[1].Replace('/', '-')
} elseif ($content -match '(?i)(?:date|dated)[:\s]*\**\s*(\w+ \d{1,2},? \d{4})') {
    try { $autoDate = Get-Date $Matches[1] -Format 'yyyy-MM-dd' } catch {}
}

# ── Prompt for missing metadata ──────────────────────────────
Write-Host ""
Write-Host "════════════════════════════════════════════" -ForegroundColor DarkCyan
Write-Host " Publishing: $fileName" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════" -ForegroundColor DarkCyan

if (-not $Title) {
    $default = if ($autoTitle) { " [$autoTitle]" } else { "" }
    $Title = Read-Host "Title$default"
    if (-not $Title -and $autoTitle) { $Title = $autoTitle }
}

if (-not $Id) {
    $default = if ($autoId) { " [$autoId]" } else { "" }
    # Auto-generate ID from existing manifest
    $manifestContent = Get-Content "$RepoDir\docs\assets\manifest.js" -Raw
    $existingIds = [regex]::Matches($manifestContent, 'id:\s*"(inv-\d+)"') | ForEach-Object { $_.Groups[1].Value }
    $maxNum = ($existingIds | ForEach-Object { [int]($_ -replace 'inv-', '') } | Measure-Object -Maximum).Maximum
    $suggestedId = if ($autoId) { $autoId } else { "inv-$('{0:D3}' -f ($maxNum + 1))" }
    $Id = Read-Host "ID [$suggestedId]"
    if (-not $Id) { $Id = $suggestedId }
}

if (-not $Date) {
    $Date = Read-Host "Date [$autoDate]"
    if (-not $Date) { $Date = $autoDate }
}

if (-not $Category) {
    Write-Host "Categories: ring-analysis, storage-abuse, edu-fraud, detection-rules," -ForegroundColor DarkGray
    Write-Host "            remediation-gap, brand-impersonation, consumer-fraud," -ForegroundColor DarkGray
    Write-Host "            business-impact, dormant-analysis, quota-abuse, multiplexing" -ForegroundColor DarkGray
    $Category = Read-Host "Category"
}

if (-not $Severity) {
    $Severity = Read-Host "Severity (critical/high/medium/low)"
}

if (-not $Summary) {
    $Summary = Read-Host "One-line summary"
}

if (-not $Tenants) {
    $t = Read-Host "Tenants count [0]"
    $Tenants = if ($t) { [int]$t } else { 0 }
}

if (-not $Storage) {
    $Storage = Read-Host "Storage impact (e.g. '1.2 PB', '500 TB') [TBD]"
    if (-not $Storage) { $Storage = 'TBD' }
}

if (-not $Tags) {
    $Tags = Read-Host "Tags (comma-separated, e.g. china,rclone,piracy)"
}

$tagArray = ($Tags -split ',') | ForEach-Object { $_.Trim() } | Where-Object { $_ }
$tagJson = ($tagArray | ForEach-Object { "`"$_`"" }) -join ', '

# ── Copy file to investigations ──────────────────────────────
$destFile = "docs\investigations\$fileName"
$destPath = Join-Path $RepoDir $destFile
Copy-Item -Path (Resolve-Path $FilePath -ErrorAction SilentlyContinue).Path -Destination $destPath -ErrorAction SilentlyContinue
if (-not (Test-Path $destPath)) {
    Set-Content -Path $destPath -Value $content -Encoding UTF8
}
Write-Host "✓ Copied to $destFile" -ForegroundColor Green

# ── Add to manifest ──────────────────────────────────────────
$manifestPath = Join-Path $RepoDir 'docs\assets\manifest.js'
$manifest = Get-Content $manifestPath -Raw

# Escape summary for JS
$escapedSummary = $Summary.Replace('\', '\\').Replace('"', '\"').Replace("'", "\'")

$newEntry = @"

  {
    id: "$Id",
    title: "$Title",
    file: "investigations/$fileName",
    date: "$Date",
    status: "$Status",
    category: "$Category",
    summary: "$escapedSummary",
    tenants: $Tenants,
    storage: "$Storage",
    severity: "$Severity",
    tags: [$tagJson]
  },
"@

# Insert after the opening bracket of INVESTIGATIONS array
$manifest = $manifest -replace '(const INVESTIGATIONS = \[)', "`$1$newEntry"
Set-Content -Path $manifestPath -Value $manifest -Encoding UTF8 -NoNewline
Write-Host "✓ Added to manifest" -ForegroundColor Green

# ── Git commit & push ────────────────────────────────────────
git add -A
git commit -m "Add $Id`: $Title"
git push origin main

Write-Host ""
Write-Host "════════════════════════════════════════════" -ForegroundColor Green
Write-Host " ✓ Published!" -ForegroundColor Green
Write-Host ""
Write-Host " Portal:  https://varunvaithy.github.io/fab-investigations/docs/portal.html" -ForegroundColor Cyan
Write-Host " Direct:  https://varunvaithy.github.io/fab-investigations/docs/investigations/viewer.html?id=$Id" -ForegroundColor Cyan
Write-Host ""
Write-Host " GitHub Pages deploys in ~30 seconds." -ForegroundColor DarkGray
Write-Host "════════════════════════════════════════════" -ForegroundColor Green

Pop-Location
