# IRIS IDE Setup Guide
## Installation Instructions for All Supported IDEs

---

## Quick Start (All IDEs)

1. Download or clone this repository
2. Follow the instructions for your IDE below
3. Verify installation with the test command
4. Run your first cycle: analyze any project

---

## Cursor AI

### Installation (Project-specific)

Copy the Cursor-specific files to your project:

```powershell
# Windows (PowerShell)
$project = "C:\path\to\your\project"
Copy-Item -Recurse "agents\cursor\.cursor" "$project\.cursor" -Force
```

```bash
# macOS / Linux
cp -r agents/cursor/.cursor /path/to/your/project/
```

### Installation (Global — available in all projects)

```powershell
# Windows
Copy-Item -Recurse "agents\cursor\.cursor" "$HOME\.cursor" -Force
```

```bash
# macOS / Linux
cp -r agents/cursor/.cursor ~/.cursor/
```

### Verification

Open Cursor in your project. In the chat panel, type:

```
/iris:help
```

Expected response: IRIS command reference table.

### File Structure Installed

```
.cursor/
├── rules/
│   └── METHOD-IRIS.md          ← main rule (trigger: manual)
└── skills/
    └── method-iris/
        ├── SKILL.md             ← orchestrator
        ├── iris-ingest.md       ← Fase 1
        ├── iris-review.md       ← Fase 2
        ├── iris-ideate.md       ← Fase 3
        ├── iris-ship.md         ← Fase 4
        ├── iris-spin.md         ← Fase 5
        └── iris-handoffs.md     ← integration protocols
```

### Usage Commands

```
/iris:analyze                    ← analyze current directory
/iris:analyze src/              ← analyze specific path
/iris:analyze --security        ← with security pack
/iris:analyze --performance     ← with performance pack
/iris:analyze --architecture    ← with architecture pack
/iris:plan                      ← create improvement roadmap
/iris:execute iter-1            ← implement iteration 1
/iris:verify                    ← close cycle
/iris:full                      ← complete 5-phase cycle
/iris:monitor                   ← activate monitoring mode
```

### Multi-method Setup (all methods together)

If you use PDCA-T, Enterprise Builder, or Modular Design, the final `.cursor/rules/` should look like:

```
.cursor/rules/
├── METHOD-ENTERPRISE-BUILDER-PLANNING.md   (trigger: manual)
├── METHOD-PDCA-T.md                        (trigger: always_on)
└── METHOD-IRIS.md                          (trigger: manual)
```

PDCA-T's `always_on` trigger means it's active for all tasks. IRIS and Enterprise Builder are manual — activated only when explicitly called.

---

## Claude Code (Anthropic)

### Installation (Project-specific)

```bash
# Copy CLAUDE.md and commands to your project
cp agents/claude-code/CLAUDE.md /path/to/your/project/
cp -r agents/claude-code/.claude /path/to/your/project/
```

```powershell
# Windows
Copy-Item "agents\claude-code\CLAUDE.md" "C:\path\to\project\" -Force
Copy-Item -Recurse "agents\claude-code\.claude" "C:\path\to\project\.claude" -Force
```

### Installation (Global)

```bash
# Append to existing CLAUDE.md if present, or create new
cat agents/claude-code/CLAUDE.md >> ~/.config/claude/CLAUDE.md
# Or replace entirely if no existing CLAUDE.md
cp agents/claude-code/CLAUDE.md ~/.config/claude/CLAUDE.md
```

### Verification

Start a Claude Code session in your project directory. Type:

```
IRIS: help
```

Expected: Command reference display.

### Usage Commands

```
IRIS: analyze                    ← analyze current directory
IRIS: analyze src/auth/         ← specific path
IRIS: analyze --security        ← with security pack
IRIS: plan                      ← create roadmap (after analyze)
IRIS: execute iter-1            ← implement iteration
IRIS: verify                    ← close cycle
IRIS: full                      ← complete cycle
IRIS: monitor                   ← monitoring mode
```

Also works with slash commands:
```
/iris:analyze
/iris:plan
/iris:execute iter-1
/iris:verify
```

### Notes for Claude Code

- Claude Code runs with access to the project directory automatically
- `IRIS_INPUT.json` and `IRIS_OUTPUT.json` will be created in the project root
- `IRIS_LOG.md` will be created/updated in the project root
- Use `git status` to verify clean working tree before `/iris:execute`

---

## Kimi Code (Moonshot AI)

### Installation

1. Open Kimi Code settings
2. Navigate to "Custom Skills" or "Agent Skills"
3. Create a new skill named `method-iris`
4. Paste the contents of `agents/kimi-code/KIMI.md` as the skill definition
5. Save and reload

### Alternative: Project file

Copy `KIMI.md` to your project root so Kimi Code reads it automatically:

```bash
cp agents/kimi-code/KIMI.md /path/to/your/project/KIMI.md
```

### Verification

In Kimi Code, type:

```
@iris help
```

Expected: Command reference display.

### Usage Commands

```
@iris analyze                   ← analyze current directory
@iris analyze src/              ← specific path
@iris analyze --security        ← with security pack
@iris plan                      ← create roadmap
@iris execute iter-1            ← implement iteration
@iris verify                    ← close cycle
@iris full                      ← complete cycle
@iris monitor                   ← monitoring mode
```

Also works with:
```
/iris analyze
/iris plan
IRIS: analyze
```

---

## Windsurf (Codeium Cascade)

### Installation

Copy `WINDSURF.md` to your project root:

```bash
cp agents/windsurf/WINDSURF.md /path/to/your/project/
```

```powershell
# Windows
Copy-Item "agents\windsurf\WINDSURF.md" "C:\path\to\project\" -Force
```

### Verification

In Windsurf Cascade chat, type:

```
IRIS: help
```

Expected: Command reference display.

### Usage Commands

```
IRIS: analyze                   ← analyze current directory
IRIS: analyze src/              ← specific path
IRIS: plan                      ← create roadmap
IRIS: execute iter-1            ← implement iteration
IRIS: verify                    ← close cycle
IRIS: full                      ← complete cycle
IRIS: monitor                   ← monitoring mode
```

---

## Shared Configuration (All IDEs)

Create `iris.config.json` in your project root for shared configuration across all IDEs:

```json
{
  "version": "2.1.0",
  "project_name": "your-project-name",
  "default_mode": "standalone",
  "integrations": {
    "pdca-t": false,
    "enterprise-builder": false,
    "modular-design": false
  },
  "thresholds": {
    "coverage_target": 99,
    "complexity_target": 12,
    "defect_density_target": 1.0,
    "tech_debt_target": 5,
    "architecture_health_target": 90
  },
  "monitoring": {
    "enabled": false,
    "frequency_days": 7,
    "degradation_coverage_threshold": 90,
    "degradation_complexity_threshold": 20
  },
  "packs": {
    "security": false,
    "performance": false,
    "architecture": false
  }
}
```

All IDEs will read this configuration for consistent thresholds and behavior. Set `integrations` to `true` for methods you have installed.

---

## Updating IRIS

To update to a newer version:

```bash
# Pull latest version
git pull origin main

# Re-copy to your project (for project-specific installation)
cp -r agents/cursor/.cursor /path/to/your/project/

# For Claude Code
cp agents/claude-code/CLAUDE.md /path/to/your/project/
```

Check `IRIS_LOG.md` in your project — it records the IRIS version used in each cycle.
