# Method IRIS
## Iterative Repository Improvement System

> **Universal 5-phase methodology for continuous improvement of any codebase. Compatible with leading AI coding agents.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Multi-Agent](https://img.shields.io/badge/agents-5%20platforms-purple)](agents/)

**Version:** 2.1.0 | **License:** MIT | **Language:** EN / ES

**Author:** Francisco J Bernades  
**GitHub:** [@exchanet](https://github.com/exchanet)  
**Repository:** [method_IRIS](https://github.com/exchanet/method_IRIS)

---

## Why use IRIS?

### For teams that need:
- **Systematic quality improvement** — measurable cycles instead of ad-hoc refactors
- **Legacy and multi-language codebases** — Python, JavaScript, Go, Java, Rust, Ruby, PHP, C#, and others
- **Integration with other methods** — handoffs from Enterprise Builder, Modular Design, or PDCA-T
- **Consistent process across AI agents** — same 5-phase protocol on Cursor, Claude Code, Kimi, Windsurf, or Antigravity

### What you get:
- **Measurable improvement cycles** — 5 universal metrics (defect density, coverage, complexity, tech debt, architectural health)
- **Safe iteration size** — ≤400 LOC per iteration with rollback plans and Definition of Done
- **Semantic memory** — `IRIS_MEMORY.json` stores rejected changes, intentional patterns, and architectural constraints so IRIS never re-proposes what the team declined
- **Delta build monitor** — lightweight checks (diff + affected tests) without re-analyzing the whole codebase
- **JSON handoffs** — schema-validated `IRIS_INPUT.json` / `IRIS_OUTPUT.json` for integration with other Exchanet methods
- **Same protocol on 5 platforms** — install once, use with Cursor AI, Claude Code, Kimi Code, Windsurf, or Google Antigravity

---

## Recommended companion methods

- [Method Enterprise Builder Planning](https://github.com/exchanet/method_enterprise_builder_planning) — Planning and delivery of enterprise-grade systems
- [Method Modular Design](https://github.com/exchanet/method_modular_design) — Core + Packs architecture pattern
- [PDCA-T Method](https://github.com/exchanet/method_pdca-t_coding) — Quality assurance cycle (≥99% test coverage)

---

## What is IRIS?

**Method IRIS** is a **universal 5-phase methodology** for continuous improvement of any repository. It is language-agnostic, framework-agnostic, and IDE-agnostic: it discovers the codebase, quantifies quality with defined metrics, and produces a prioritized, risk-assessed improvement roadmap. Each cycle ends by preparing the next; there is no "done," only "better."

Principles: **adapt to the existing codebase** (no style imposition), **metrics-first** (numbers over opinions), **safe batches** (≤400 LOC per iteration), and **contract-based integration** (JSON Schema handoffs).

### Multi-agent support

| Agent Platform   | Adapter                    | Installation                    |
|------------------|----------------------------|---------------------------------|
| **Cursor AI**    | `.cursor/` rules + skills  | Copy `agents/cursor/.cursor/`   |
| **Claude Code**  | `CLAUDE.md`                | Copy to project root            |
| **Kimi Code**    | `KIMI.md`                  | Copy to project root            |
| **Windsurf**     | `WINDSURF.md`             | Copy to project root            |
| **Google Antigravity** | `ANTIGRAVITY.md`    | Copy to project root            |

All adapters follow the **same 5-phase protocol**.

### The 5-Phase IRIS Cycle

```
INGEST   → Build complete mental model (structure, stack, entry points, memory)
    ↓
REVIEW   → Quantify quality: 5 dimensions in parallel, 5 core metrics
    ↓
IDEATE   → Prioritized roadmap, cascade analysis, iterations ≤400 LOC each
    ↓
SHIP     → Implement one iteration at a time, test after every file
    ↓
SPIN     → Verify, update IRIS_LOG.md and IRIS_MEMORY.json, prepare next cycle
    ↓
→ INGEST (next cycle)
```

---

## Core metrics

| Metric                  | Target      | Formula |
|-------------------------|------------|---------|
| Defect Density          | <1.0 per 1K LOC | `(findings / LOC) × 1000` |
| Test Coverage           | ≥99%       | `(covered / total) × 100` |
| Complexity Score        | <12        | `(cyclomatic × 0.6) + (cognitive × 0.4)` |
| Tech Debt Ratio         | <5%        | `(fix_hours / dev_hours) × 100` |
| Architectural Health Index | ≥90/100 | `avg(coupling, cohesion, SOLID, duplication)` |

---

## Quick Start

### Cursor AI

1. Copy the `.cursor/` folder to your project:
   ```bash
   cp -r agents/cursor/.cursor /path/to/your/project/
   ```
2. Open Cursor in your project and run: `/iris:full`

### Claude Code

1. Copy `CLAUDE.md` to your project:
   ```bash
   cp agents/claude-code/CLAUDE.md /path/to/your/project/
   ```
2. Use: `IRIS: full`

### Kimi Code

1. Copy `KIMI.md` to your project:
   ```bash
   cp agents/kimi-code/KIMI.md /path/to/your/project/
   ```
2. Use: `@iris full`

### Windsurf

1. Copy `WINDSURF.md` to your project:
   ```bash
   cp agents/windsurf/WINDSURF.md /path/to/your/project/
   ```
2. Use: `IRIS: full`

### Google Antigravity

1. Copy `ANTIGRAVITY.md` to your project:
   ```bash
   cp agents/antigravity/ANTIGRAVITY.md /path/to/your/project/
   ```
2. Use: `IRIS: full [path]`

**Automated installation:** Use `scripts/install.sh` (macOS/Linux) or `scripts/install.ps1` (Windows).

---

## Activation

Once installed, trigger IRIS with:

```
/iris:full
/iris:analyze [path]
"Use IRIS to improve this codebase"
"Run IRIS quality assessment on this repo"
```

---

## Commands

| Command | Description |
|---------|-------------|
| `/iris:analyze [path]` | Fase 1 + 2: Context acquisition + quality assessment (parallel 5 dimensions) |
| `/iris:plan` | Fase 3: Improvement roadmap with cascade analysis |
| `/iris:execute iter-N` | Fase 4: Implement iteration N |
| `/iris:verify` | Fase 5: Verify cycle, update IRIS_MEMORY.json |
| `/iris:full [path]` | Complete 5-phase cycle |
| `/iris:monitor` | Full build monitor (diff + affected tests + metrics delta) |
| `/iris:monitor:delta` | Lightweight delta (diff + affected tests only) |
| `/iris:memory` | View and edit IRIS_MEMORY.json |
| `/iris:cascade` | Show cascade elimination map from last `/iris:plan` |
| `/iris:analyze --security` | With STRIDE + OWASP analysis |
| `/iris:analyze --performance` | With algorithmic and DB performance analysis |
| `/iris:analyze --architecture` | With SOLID and coupling deep analysis |

---

## Specialization packs

Optional deep-dive packs for Fase 2:

| Pack | Covers | Activated with |
|------|--------|----------------|
| Security Pack | STRIDE, OWASP Top 10, secrets scan | `--security` |
| Performance Pack | Big O, N+1, async patterns, caching | `--performance` |
| Architecture Pack | SOLID, coupling/cohesion, layer violations | `--architecture` |

---

## Repository structure

```
method_IRIS/
├── agents/
│   ├── cursor/.cursor/rules/           ← Cursor rule
│   │   .cursor/skills/method-iris/     ← Phase skills + build monitor
│   ├── claude-code/CLAUDE.md
│   ├── kimi-code/KIMI.md
│   ├── windsurf/WINDSURF.md
│   └── antigravity/ANTIGRAVITY.md
├── core/
│   ├── iris-methodology.md            ← Formal 5-phase definition
│   ├── iris-memory-spec.md             ← Semantic memory specification
│   ├── iris-build-monitor.md          ← Delta pipeline specification
│   └── schemas/                        ← JSON Schema Draft-7
│       ├── handoff-input.json
│       ├── handoff-output.json
│       ├── metrics.json
│       └── memory.json
├── packs/
│   ├── security-pack/
│   ├── performance-pack/
│   └── architecture-pack/
├── docs/
│   ├── INTEGRATION-GUIDE.md
│   ├── IDE-SETUP.md
│   └── METRICS-REFERENCE.md
├── examples/
│   ├── standalone-usage.md
│   ├── with-pdca-t.md
│   ├── with-enterprise-builder.md
│   └── full-ecosystem-demo.md
└── scripts/
    ├── install.ps1                     ← Windows
    └── install.sh                     ← macOS/Linux
```

---

## Semantic memory

`IRIS_MEMORY.json` (project root) persists across all IRIS cycles:

| Component | Purpose |
|-----------|---------|
| `intentional_patterns` | Patterns that look problematic but are deliberate; IRIS tags them NOTED, not IMPROVABLE. |
| `rejected_changes` | Proposals the team declined; IRIS does not re-propose unless expired. |
| `architectural_constraints` | Hard rules IRIS must never violate. |

Use `/iris:memory` to view and edit. IRIS creates the file when decisions are made during IDEATE.

**Handoff files:** `IRIS_INPUT.json`, `IRIS_OUTPUT.json` (schema-validated), `IRIS_LOG.md` (cycle history).

---

## Ecosystem integration

IRIS works standalone or with other Exchanet methods:

```
Enterprise Builder → delivers the system
      ↓
Modular Design → Core/Pack architecture
      ↓
PDCA-T → tasks with ≥99% coverage
      ↓ (escalation when blocked)
IRIS ← → resolves blockers, monitors quality
      ↓
Enterprise Builder (next cycle)
```

---

## Compatibility

| IDE / Agent | Status |
|-------------|--------|
| Cursor AI (0.40+) | Full support |
| Claude Code | Full support |
| Kimi Code (Moonshot AI) | Full support |
| Windsurf (Codeium) | Full support |
| Google Antigravity | Full support |
| Any LLM with file access | Use `core/iris-methodology.md` |

---

## License

MIT — see [LICENSE](LICENSE).

---

## Author

**Francisco J Bernades**  
GitHub: [@exchanet](https://github.com/exchanet)

---

See [README.es.md](README.es.md) for Spanish documentation.
