# IRIS Skill — Main Orchestrator
# Iterative Repository Improvement System v2.1

## Purpose

This skill orchestrates the IRIS 5-phase improvement cycle. It detects context (standalone vs. integrated), routes commands to the appropriate phase skill, and manages state across the cycle.

## Activation

Called by `METHOD-IRIS.md` rule when any `/iris:*` command is detected.

## Command Routing

```
/iris:analyze [path]   → iris-ingest.md + iris-review.md
/iris:plan             → iris-ideate.md  (requires Fase 2 complete)
/iris:execute [iter-N] → iris-ship.md    (requires Fase 3 complete)
/iris:verify           → iris-spin.md    (requires Fase 4 complete)
/iris:full [path]      → all 5 phases sequentially
/iris:monitor          → iris-build-monitor.md (full monitoring — Stages 1+2+3)
/iris:monitor:delta    → iris-build-monitor.md (lightweight delta — Stages 1+2 only)
/iris:memory           → display/edit IRIS_MEMORY.json (semantic memory)
/iris:cascade          → show cascade elimination map from last /iris:plan
/iris:help             → display command reference
```

## Context Detection (run first, before any phase)

1. **Check for IRIS_INPUT.json** in current directory
   - If found: load `source_method`, `trigger_reason`, `current_metrics`, and any escalation data
   - Adapt focus based on `source_method`:
     - `pdca-t` → focus Fase 2 on testability analysis, Fase 3 on architectural fixes
     - `enterprise-builder` → focus Fase 1 on full system ingestion, enter monitoring after Fase 5
     - `modular-design` → focus Fase 2 on architectural health, Fase 3 on contract preservation
     - `standalone` or absent → standard 5-phase analysis

2. **Check for IRIS_LOG.md** in project root
   - If found: load last cycle number, last metrics, and defined trigger conditions
   - If not found: this is Cycle #1

3. **Check for IRIS_MEMORY.json** in project root
   - If found: load intentional_patterns, rejected_changes, architectural_constraints, context_changes
   - Check for any intentional_pattern with `revisit_on ≤ today` → flag for IDEATE review
   - Check for any rejected_change with `expires_on` that has passed → note as re-evaluatable
   - If not found: memory state = empty, will be created during IDEATE if decisions are made

4. **Check for co-existing method rules** in `.cursor/rules/`
   - `METHOD-PDCA-T.md` or `METODO-PDCA-T.md` → log "PDCA-T detected" in Fase 1 report
   - `METHOD-ENTERPRISE-BUILDER-PLANNING.md` → log "Enterprise Builder detected"
   - Any `core/` + `packs/` directory structure → log "Modular Design detected"

## State Object

Track this across all phases in the session:

```json
{
  "cycle_number": 1,
  "source_method": "standalone",
  "trigger_reason": "manual-request",
  "repository_path": ".",
  "completed_phases": [],
  "current_metrics": {},
  "baseline_metrics": {},
  "improvements_planned": [],
  "improvements_completed": [],
  "current_iteration": null,
  "handoff_pending": false,
  "monitoring_mode": false,
  "memory_loaded": false,
  "memory_intentional_patterns": 0,
  "memory_rejected_changes": 0,
  "memory_constraints": 0,
  "memory_patterns_due_revisit": []
}
```

## Phase Gate Enforcement

Before executing any phase, verify prerequisites:

| Phase | Requires |
|-------|---------|
| Fase 1 | Nothing — always executable |
| Fase 2 | Fase 1 completed (report exists) |
| Fase 3 | Fase 2 completed (metrics calculated) |
| Fase 4 | Fase 3 completed (iteration plan exists) |
| Fase 5 | Fase 4 completed (iteration implemented) |

If a prerequisite is missing, inform the user and suggest the correct starting command.

## /iris:help Output

```markdown
## IRIS v2.1 — Command Reference

**Full cycle:** `/iris:full [path]`
**Step by step:**
  1. `/iris:analyze [path]` — Fase 1 (context) + Fase 2 (quality assessment)
  2. `/iris:plan` — Fase 3 (improvement roadmap)
  3. `/iris:execute iter-1` — Fase 4 (implement iteration 1)
  4. `/iris:verify` — Fase 5 (verify + close cycle)

**Monitoring:**
  - `/iris:monitor` — Full build monitor (Stages 1+2+3)
  - `/iris:monitor:delta` — Lightweight delta check (Stages 1+2 only — fast)

**Semantic memory:**
  - `/iris:memory` — Display and edit IRIS_MEMORY.json
  - `/iris:cascade` — Show cascade elimination map from last /iris:plan

**Pack modifiers for deeper analysis:**
  - `/iris:analyze --security` — STRIDE + OWASP analysis
  - `/iris:analyze --performance` — Algorithmic + concurrency analysis
  - `/iris:analyze --architecture` — SOLID + coupling deep analysis

**Integration:**
  - Place `IRIS_INPUT.json` in project root to receive handoff from PDCA-T, Enterprise Builder, or Modular Design
  - IRIS generates `IRIS_OUTPUT.json` when completing a cycle that hands off to another method
  - `IRIS_MEMORY.json` persists rejected changes, intentional patterns, and architectural constraints across cycles

**Documentation:** `core/iris-methodology.md`
```

## /iris:cascade Output

When `/iris:cascade` is called:
- If a cascade elimination map was produced in the last `/iris:plan` → display it
- Format: table with columns [Primary Finding, Cascade Score, Findings Eliminated, Final Score]
- Also show total LOC savings from cascade effect
- If no prior plan exists → suggest running `/iris:plan` first

## /iris:memory Routing

When `/iris:memory` is called, follow the protocol in `core/iris-memory-spec.md`:
- Display memory summary (patterns, rejections, constraints)
- Accept subcommands: `add-constraint`, `add-pattern`, `reject [ID]`, `edit [ID]`, `remove [ID]`
- Always confirm before any write to `IRIS_MEMORY.json`

## Error Handling

- If path argument is missing from `/iris:analyze`: use current working directory
- If IRIS_INPUT.json schema is invalid: warn and proceed as standalone
- If IRIS_MEMORY.json schema is invalid: warn, show the validation error, ask user whether to reset it or fix manually
- If a phase fails: report the specific check that failed and what information is needed to proceed
- If tests fail during Fase 4: STOP immediately — report which tests failed and why before proceeding
