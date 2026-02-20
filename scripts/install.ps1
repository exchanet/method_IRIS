# IRIS v2.1 — Installer for Windows (PowerShell)
# Installs IRIS method files to a target project directory

param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectPath = ".",

    [Parameter(Mandatory=$false)]
    [ValidateSet("cursor", "claude-code", "kimi-code", "windsurf", "all")]
    [string]$IDE = "cursor",

    [Parameter(Mandatory=$false)]
    [switch]$Global,

    [Parameter(Mandatory=$false)]
    [switch]$WithPacks,

    [Parameter(Mandatory=$false)]
    [switch]$DryRun
)

$IrisRoot = $PSScriptRoot | Split-Path -Parent
$ErrorActionPreference = "Stop"

function Write-Step($message) {
    Write-Host "  → $message" -ForegroundColor Cyan
}

function Write-Success($message) {
    Write-Host "  ✅ $message" -ForegroundColor Green
}

function Write-Warning($message) {
    Write-Host "  ⚠️  $message" -ForegroundColor Yellow
}

function Copy-IfExists($source, $destination) {
    if (Test-Path $source) {
        if ($DryRun) {
            Write-Host "  [DRY RUN] Would copy: $source → $destination"
        } else {
            $destDir = Split-Path $destination -Parent
            if (-not (Test-Path $destDir)) {
                New-Item -ItemType Directory -Path $destDir -Force | Out-Null
            }
            Copy-Item -Recurse -Force $source $destination
        }
        return $true
    }
    return $false
}

Write-Host ""
Write-Host "═══════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "  IRIS v2.1 — Iterative Repository Improvement System" -ForegroundColor Magenta
Write-Host "  Windows Installer" -ForegroundColor Magenta
Write-Host "═══════════════════════════════════════════" -ForegroundColor Magenta
Write-Host ""

# Resolve target directory
if ($Global) {
    $targetDir = "$HOME"
    Write-Host "  Mode: Global installation (~/.cursor/)" -ForegroundColor Blue
} else {
    $targetDir = Resolve-Path $ProjectPath
    Write-Host "  Mode: Project installation" -ForegroundColor Blue
    Write-Host "  Target: $targetDir" -ForegroundColor Blue
}

if ($DryRun) {
    Write-Warning "DRY RUN mode — no files will be written"
}

Write-Host ""

# Install based on IDE selection
$idesToInstall = if ($IDE -eq "all") { @("cursor", "claude-code", "kimi-code", "windsurf") } else { @($IDE) }

foreach ($currentIDE in $idesToInstall) {
    Write-Host "  Installing for: $currentIDE" -ForegroundColor Yellow

    switch ($currentIDE) {
        "cursor" {
            Write-Step "Copying Cursor rule file..."
            $rulesSrc = Join-Path $IrisRoot "agents\cursor\.cursor\rules\METHOD-IRIS.md"
            $rulesDst = Join-Path $targetDir ".cursor\rules\METHOD-IRIS.md"
            if (Copy-IfExists $rulesSrc $rulesDst) {
                Write-Success "Cursor rule installed: .cursor/rules/METHOD-IRIS.md"
            }

            Write-Step "Copying Cursor skills..."
            $skillsSrc = Join-Path $IrisRoot "agents\cursor\.cursor\skills\method-iris"
            $skillsDst = Join-Path $targetDir ".cursor\skills\method-iris"
            if (Copy-IfExists $skillsSrc $skillsDst) {
                Write-Success "Cursor skills installed: .cursor/skills/method-iris/ (7 files)"
            }
        }

        "claude-code" {
            Write-Step "Copying CLAUDE.md..."
            $claudeSrc = Join-Path $IrisRoot "agents\claude-code\CLAUDE.md"
            $claudeDst = Join-Path $targetDir "CLAUDE.md"

            if (Test-Path $claudeDst) {
                Write-Warning "CLAUDE.md already exists. Appending IRIS section..."
                if (-not $DryRun) {
                    $existing = Get-Content $claudeDst -Raw
                    $irisContent = Get-Content $claudeSrc -Raw
                    if ($existing -notlike "*Method IRIS*") {
                        "`n`n---`n`n" + $irisContent | Add-Content $claudeDst
                        Write-Success "IRIS appended to existing CLAUDE.md"
                    } else {
                        Write-Warning "IRIS already present in CLAUDE.md — skipped"
                    }
                }
            } else {
                if (Copy-IfExists $claudeSrc $claudeDst) {
                    Write-Success "CLAUDE.md installed"
                }
            }

            Write-Step "Copying Claude commands..."
            $cmdSrc = Join-Path $IrisRoot "agents\claude-code\.claude\commands\iris.md"
            $cmdDst = Join-Path $targetDir ".claude\commands\iris.md"
            if (Copy-IfExists $cmdSrc $cmdDst) {
                Write-Success "Claude commands installed: .claude/commands/iris.md"
            }
        }

        "kimi-code" {
            Write-Step "Copying KIMI.md..."
            $kimiSrc = Join-Path $IrisRoot "agents\kimi-code\KIMI.md"
            $kimiDst = Join-Path $targetDir "KIMI.md"
            if (Copy-IfExists $kimiSrc $kimiDst) {
                Write-Success "KIMI.md installed"
            }
        }

        "windsurf" {
            Write-Step "Copying WINDSURF.md..."
            $wsurfSrc = Join-Path $IrisRoot "agents\windsurf\WINDSURF.md"
            $wsurfDst = Join-Path $targetDir "WINDSURF.md"
            if (Copy-IfExists $wsurfSrc $wsurfDst) {
                Write-Success "WINDSURF.md installed"
            }
        }
    }
}

# Install packs if requested
if ($WithPacks) {
    Write-Host ""
    Write-Host "  Installing Specialization Packs..." -ForegroundColor Yellow
    $packsDst = Join-Path $targetDir ".iris\packs"

    foreach ($pack in @("security-pack", "performance-pack", "architecture-pack")) {
        $packSrc = Join-Path $IrisRoot "packs\$pack"
        $packTarget = Join-Path $packsDst $pack
        if (Copy-IfExists $packSrc $packTarget) {
            Write-Success "$pack installed"
        }
    }
}

# Create IRIS_LOG.md if it doesn't exist
if ($IDE -eq "cursor" -or $IDE -eq "all") {
    $logFile = Join-Path $targetDir "IRIS_LOG.md"
    if (-not (Test-Path $logFile)) {
        if (-not $DryRun) {
            $logContent = @"
# IRIS Log

## Configuration
- IRIS Version: 2.1.0
- Installed: $(Get-Date -Format "yyyy-MM-dd")
- Coverage target: 99%
- Complexity target: 12
- Defect density target: 1.0
- Tech debt target: 5%
- Architecture health target: 90

## Cycle History

*No cycles run yet. Run `/iris:full` to start your first cycle.*
"@
            $logContent | Set-Content $logFile -Encoding UTF8
        }
        Write-Success "IRIS_LOG.md created (tracks all cycle history)"
    } else {
        Write-Warning "IRIS_LOG.md already exists — preserved"
    }
}

Write-Host ""
Write-Host "═══════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "  Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "  Next steps:" -ForegroundColor White
Write-Host "  1. Open your project in Cursor/Claude Code/Kimi Code/Windsurf" -ForegroundColor White
Write-Host "  2. Run: /iris:help  (to verify installation)" -ForegroundColor White
Write-Host "  3. Run: /iris:full  (to start your first improvement cycle)" -ForegroundColor White
Write-Host ""
Write-Host "  Documentation: docs/IDE-SETUP.md" -ForegroundColor Gray
Write-Host "  Integration:   docs/INTEGRATION-GUIDE.md" -ForegroundColor Gray
Write-Host "═══════════════════════════════════════════" -ForegroundColor Magenta
Write-Host ""
