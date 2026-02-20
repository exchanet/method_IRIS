#!/usr/bin/env bash
# IRIS v2.1 — Installer for macOS and Linux
# Installs IRIS method files to a target project directory

set -euo pipefail

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# ── Script location ────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IRIS_ROOT="$(dirname "$SCRIPT_DIR")"

# ── Defaults ───────────────────────────────────────────────────────────────────
PROJECT_PATH="."
IDE="cursor"
GLOBAL=false
WITH_PACKS=false
DRY_RUN=false

# ── Parse arguments ────────────────────────────────────────────────────────────
usage() {
    cat <<EOF
IRIS v2.1 Installer

Usage: ./install.sh [OPTIONS]

Options:
  --project PATH       Target project directory (default: current directory)
  --ide IDE            IDE to install for: cursor|claude-code|kimi-code|windsurf|all (default: cursor)
  --global             Install globally (~/.cursor/) instead of project-specific
  --with-packs         Also install specialization packs (security, performance, architecture)
  --dry-run            Show what would be installed without making changes
  -h, --help           Show this help

Examples:
  ./install.sh                                # Install Cursor IRIS in current directory
  ./install.sh --project ~/my-project        # Install in specific directory
  ./install.sh --ide all                     # Install for all IDEs
  ./install.sh --ide claude-code             # Install for Claude Code only
  ./install.sh --global --ide cursor         # Install globally for Cursor
  ./install.sh --with-packs                  # Install with specialization packs
  ./install.sh --dry-run                     # Preview without installing
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --project) PROJECT_PATH="$2"; shift 2 ;;
        --ide) IDE="$2"; shift 2 ;;
        --global) GLOBAL=true; shift ;;
        --with-packs) WITH_PACKS=true; shift ;;
        --dry-run) DRY_RUN=true; shift ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown option: $1"; usage; exit 1 ;;
    esac
done

# ── Helper functions ───────────────────────────────────────────────────────────
step() { echo -e "  ${CYAN}→${NC} $1"; }
success() { echo -e "  ${GREEN}✅${NC} $1"; }
warn() { echo -e "  ${YELLOW}⚠️ ${NC} $1"; }

copy_if_exists() {
    local src="$1"
    local dst="$2"
    if [[ -e "$src" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            echo "  [DRY RUN] Would copy: $src → $dst"
        else
            mkdir -p "$(dirname "$dst")"
            cp -r "$src" "$dst"
        fi
        return 0
    fi
    return 1
}

# ── Resolve target directory ───────────────────────────────────────────────────
if [[ "$GLOBAL" == "true" ]]; then
    TARGET_DIR="$HOME"
    echo ""
    echo -e "  Mode: ${CYAN}Global installation (~/.cursor/)${NC}"
else
    TARGET_DIR="$(cd "$PROJECT_PATH" && pwd)"
    echo ""
    echo -e "  Mode: ${CYAN}Project installation${NC}"
    echo -e "  Target: ${CYAN}$TARGET_DIR${NC}"
fi

echo ""
echo -e "${MAGENTA}═══════════════════════════════════════════${NC}"
echo -e "${MAGENTA}  IRIS v2.1 — Iterative Repository Improvement System${NC}"
echo -e "${MAGENTA}  macOS/Linux Installer${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════${NC}"
echo ""

[[ "$DRY_RUN" == "true" ]] && warn "DRY RUN mode — no files will be written"
echo ""

# ── Determine IDEs to install ──────────────────────────────────────────────────
if [[ "$IDE" == "all" ]]; then
    IDES=("cursor" "claude-code" "kimi-code" "windsurf")
else
    IDES=("$IDE")
fi

# ── Install per IDE ────────────────────────────────────────────────────────────
for current_ide in "${IDES[@]}"; do
    echo -e "  Installing for: ${YELLOW}$current_ide${NC}"

    case "$current_ide" in
        cursor)
            step "Copying Cursor rule file..."
            rule_src="$IRIS_ROOT/agents/cursor/.cursor/rules/METHOD-IRIS.md"
            rule_dst="$TARGET_DIR/.cursor/rules/METHOD-IRIS.md"
            copy_if_exists "$rule_src" "$rule_dst" && success "Cursor rule installed: .cursor/rules/METHOD-IRIS.md"

            step "Copying Cursor skills..."
            skills_src="$IRIS_ROOT/agents/cursor/.cursor/skills/method-iris"
            skills_dst="$TARGET_DIR/.cursor/skills/method-iris"
            copy_if_exists "$skills_src" "$skills_dst" && success "Cursor skills installed: .cursor/skills/method-iris/ (7 files)"
            ;;

        claude-code)
            step "Copying CLAUDE.md..."
            claude_src="$IRIS_ROOT/agents/claude-code/CLAUDE.md"
            claude_dst="$TARGET_DIR/CLAUDE.md"

            if [[ -f "$claude_dst" ]]; then
                warn "CLAUDE.md already exists. Appending IRIS section..."
                if [[ "$DRY_RUN" != "true" ]]; then
                    if ! grep -q "Method IRIS" "$claude_dst" 2>/dev/null; then
                        { echo ""; echo ""; echo "---"; echo ""; cat "$claude_src"; } >> "$claude_dst"
                        success "IRIS appended to existing CLAUDE.md"
                    else
                        warn "IRIS already present in CLAUDE.md — skipped"
                    fi
                fi
            else
                copy_if_exists "$claude_src" "$claude_dst" && success "CLAUDE.md installed"
            fi

            step "Copying Claude commands..."
            cmd_src="$IRIS_ROOT/agents/claude-code/.claude/commands/iris.md"
            cmd_dst="$TARGET_DIR/.claude/commands/iris.md"
            copy_if_exists "$cmd_src" "$cmd_dst" && success "Claude commands installed: .claude/commands/iris.md"
            ;;

        kimi-code)
            step "Copying KIMI.md..."
            kimi_src="$IRIS_ROOT/agents/kimi-code/KIMI.md"
            kimi_dst="$TARGET_DIR/KIMI.md"
            copy_if_exists "$kimi_src" "$kimi_dst" && success "KIMI.md installed"
            ;;

        windsurf)
            step "Copying WINDSURF.md..."
            ws_src="$IRIS_ROOT/agents/windsurf/WINDSURF.md"
            ws_dst="$TARGET_DIR/WINDSURF.md"
            copy_if_exists "$ws_src" "$ws_dst" && success "WINDSURF.md installed"
            ;;
    esac

    echo ""
done

# ── Install packs if requested ─────────────────────────────────────────────────
if [[ "$WITH_PACKS" == "true" ]]; then
    echo -e "  Installing ${YELLOW}Specialization Packs${NC}..."
    packs_dst="$TARGET_DIR/.iris/packs"

    for pack in "security-pack" "performance-pack" "architecture-pack"; do
        pack_src="$IRIS_ROOT/packs/$pack"
        pack_target="$packs_dst/$pack"
        copy_if_exists "$pack_src" "$pack_target" && success "$pack installed"
    done
    echo ""
fi

# ── Create IRIS_LOG.md if not present ─────────────────────────────────────────
log_file="$TARGET_DIR/IRIS_LOG.md"
if [[ ! -f "$log_file" ]]; then
    if [[ "$DRY_RUN" != "true" ]]; then
        cat > "$log_file" << 'EOF'
# IRIS Log

## Configuration
- IRIS Version: 2.1.0
- Coverage target: 99%
- Complexity target: 12
- Defect density target: 1.0
- Tech debt target: 5%
- Architecture health target: 90

## Cycle History

*No cycles run yet. Run `/iris:full` to start your first cycle.*
EOF
    fi
    success "IRIS_LOG.md created (tracks all cycle history)"
else
    warn "IRIS_LOG.md already exists — preserved"
fi

# ── Done ───────────────────────────────────────────────────────────────────────
echo ""
echo -e "${MAGENTA}═══════════════════════════════════════════${NC}"
echo -e "${GREEN}  Installation complete!${NC}"
echo ""
echo "  Next steps:"
echo "  1. Open your project in Cursor/Claude Code/Kimi Code/Windsurf"
echo "  2. Type: /iris:help   (to verify installation)"
echo "  3. Type: /iris:full   (to start your first improvement cycle)"
echo ""
echo -e "  Documentation: ${CYAN}docs/IDE-SETUP.md${NC}"
echo -e "  Integration:   ${CYAN}docs/INTEGRATION-GUIDE.md${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════${NC}"
echo ""
