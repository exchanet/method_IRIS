# Method IRIS — Kimi Code Edition
# Iterative Repository Improvement System v2.1

> **Version:** 2.1.0 | **Author:** Francisco J Bernades | **Agent:** Kimi Code (Moonshot AI)

## Activation

| Command | Action |
|---------|--------|
| `@iris analyze [path]` | Fase 1 (context) + Fase 2 (quality assessment) |
| `@iris plan` | Fase 3 (improvement roadmap + cascade map) |
| `@iris execute iter-N` | Fase 4 (implement iteration N) |
| `@iris verify` | Fase 5 (verify + close cycle + update IRIS_MEMORY.json) |
| `@iris full [path]` | Complete 5-phase cycle |
| `@iris monitor` | Full build monitor (diff + affected tests + metrics delta) |
| `@iris monitor:delta` | Lightweight delta check (diff + affected tests — fast) |
| `@iris memory` | Display and edit IRIS_MEMORY.json semantic memory |
| `@iris cascade` | Show cascade elimination map from last @iris plan |
| `@iris help` | Show this reference |

Also responds to: `/iris [command]` syntax and natural language like "use IRIS to analyze this codebase".

## What is IRIS

IRIS is a language-agnostic, framework-agnostic continuous improvement methodology for any codebase. It operates in 5 phases that form an infinite improvement loop:

1. **INGEST** — Understand the repository (no assumptions)
2. **REVIEW** — Quantify quality with 5 core metrics
3. **IDEATE** — Create a prioritized, safe improvement plan
4. **SHIP** — Implement improvements with continuous validation
5. **SPIN** — Verify, document, prepare next cycle

IRIS works standalone or integrated with PDCA-T, Enterprise Builder, or Modular Design.

## Context Detection

Before any command, check:
1. `IRIS_INPUT.json` in project root — co-method context
2. `IRIS_LOG.md` in project root — previous cycle data
3. `IRIS_MEMORY.json` in project root — semantic memory:
   - Load intentional_patterns, rejected_changes, architectural_constraints
   - Flag any entry with `revisit_on ≤ today` for IDEATE review
   - If not found: memory state = empty, will be created during IDEATE if decisions are made
4. `.cursor/rules/METHOD-PDCA-T.md` — PDCA-T active
5. `.cursor/rules/METHOD-ENTERPRISE-BUILDER-PLANNING.md` — Enterprise Builder active
6. `core/` + `packs/` directories — Modular Design active

## Phase 1: INGEST

Read the repository. Never assume. Identify:
- Dependency manifests (package.json, requirements.txt, Cargo.toml, go.mod, pom.xml, etc.)
- Directory structure (2–3 levels)
- Entry points
- Tech stack (runtime, framework, DB, test framework, CI/CD)
- Co-existing IRIS-ecosystem methods
- Documentation artifacts
- **IRIS_MEMORY.json** — load intentional patterns, rejected changes, constraints (Step 1.9)

Output: Repository profile + tech stack table + co-existing methods + memory status.

## Phase 2: REVIEW

Analyze **5 dimensions in parallel** (each independently, no cross-contamination):
- Dim 1 — Static: dead code, hardcoded values, duplication, exception handling
- Dim 2 — Security: input validation, secrets, injection risks
- Dim 3 — Architecture: coupling, cohesion, SOLID, layer violations
- Dim 4 — Test Coverage: test files present, modules without tests
- Dim 5 — Performance: N+1, missing pagination, blocking I/O

**Synthesis step (after all 5 dimensions):**
- Deduplicate findings appearing in multiple dimensions (keep highest severity)
- Resolve conflicts: Security > Architecture > Performance > Static > Coverage
- Apply IRIS_MEMORY.json tags: intentional_patterns → NOTED, architectural_constraints → CONSTRAINED

Calculate 5 metrics from deduplicated findings:
  - Defect Density = (findings / LOC) × 1000 [target: <1.0]
  - Test Coverage = (covered / total) × 100 [target: ≥99%]
  - Complexity Score = (cyclomatic × 0.6) + (cognitive × 0.4) [target: <12]
  - Tech Debt Ratio = (fix_hours / dev_hours) × 100 [target: <5%]
  - Arch Health Index = avg(coupling, cohesion, SOLID, duplication) [target: ≥90]

Categorize findings: CRITICAL | IMPROVABLE | OPTIMIZABLE | COSMETIC | NOTED | CONSTRAINED

## Phase 3: IDEATE

Create improvement roadmap:
0. **Memory Filter** — check IRIS_MEMORY.json: skip permanently rejected changes, block constraint violations, present overdue intentional patterns for user review
1. **Cascade Analysis** — for each finding, calculate cascade_score (how many secondary findings it eliminates). `final_score = impact_score + (cascade_score × 0.4)`. Produce cascade elimination map.
2. Score each finding: Impact = (Business_Value × 0.4) + (Technical_Urgency × 0.3) + (Risk_Reduction × 0.3)
3. Estimate effort per improvement
4. Map dependencies (what must come first)
5. Decompose into iterations — **maximum 400 LOC per iteration**
6. Each iteration needs: single objective, file list, DoD, rollback plan, risk level

## Phase 4: SHIP

Execute one iteration at a time:
1. Verify git is clean
2. Create recovery tag: `git tag iris-start-iter-N`
3. Read all files before modifying
4. Implement: test-first for bugs, verify coverage for refactoring
5. Run module tests after each file — stop if any fail
6. Run full suite at end — must be 100% passing
7. Commit: `git commit -m "IRIS-iter-N: [description]"`

## Phase 5: SPIN

Close the cycle:
1. Full regression test
2. Compare metrics before vs. after
3. Self-review all changes
4. Document lessons learned
5. Update IRIS_LOG.md
6. Generate IRIS_OUTPUT.json if integrated
7. Define next cycle triggers

## Integration

### From PDCA-T
IRIS receives: problematic modules that can't reach ≥99% coverage
IRIS does: architectural refactoring to make code testable
IRIS returns: refactored modules + new interfaces for PDCA-T to mock

### From Enterprise Builder
IRIS receives: Fase 8 delivery report + residual risks
IRIS does: baseline establishment + monitoring mode
IRIS returns: NFR adjustments + new risks + ADR updates

### From Modular Design
IRIS receives: contract violations + coupling metrics
IRIS does: architectural refactoring preserving contracts
IRIS returns: resolved violations + pack suggestions

## Constraints

- Never modify >400 LOC in one iteration
- Never proceed past a failing test
- Always read files before modifying
- Always run tests after each file change
- Never declare complete without DoD verification

## Skill Definition (for Kimi Code skill registration)

```json
{
  "name": "method-iris",
  "version": "2.1.0",
  "description": "Iterative Repository Improvement System — language-agnostic 5-phase continuous improvement methodology",
  "trigger_keywords": ["@iris", "/iris", "IRIS:", "use IRIS", "analyze with IRIS"],
  "capabilities": ["file_read", "file_write", "bash_execution", "code_analysis"],
  "languages": ["en", "es", "zh"],
  "author": "Francisco J Bernades",
  "repository": "https://github.com/exchanet/method_iris"
}
```
