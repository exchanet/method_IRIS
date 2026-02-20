# Method IRIS — Windsurf Cascade Edition
# Iterative Repository Improvement System v2.1

> **Version:** 2.1.0 | **Author:** Francisco J Bernades | **Agent:** Windsurf (Codeium Cascade)

## Activation

Activate IRIS with any of these:

```
IRIS: analyze [path]
IRIS: plan
IRIS: execute iter-N
IRIS: verify
IRIS: full [path]
IRIS: monitor
IRIS: monitor:delta
IRIS: memory
IRIS: cascade
IRIS: help
```

Also responds to: "analyze this codebase with IRIS", "run IRIS on this project", "start an IRIS cycle".

## Purpose

IRIS (Iterative Repository Improvement System) is a language-agnostic, framework-agnostic continuous improvement methodology. It works on any codebase — any language, any framework, any architecture.

**The 5-Phase Cycle:**
```
INGEST → REVIEW → IDEATE → SHIP → SPIN → (next cycle)
```

Operates standalone or integrated with PDCA-T, Enterprise Builder, and Modular Design.

## Context Check (always run first)

1. Look for `IRIS_INPUT.json` → load source method context
2. Look for `IRIS_LOG.md` → load previous cycle number and metrics
3. Look for `IRIS_MEMORY.json` → load semantic memory:
   - Load intentional_patterns (flag any with `revisit_on ≤ today`)
   - Load rejected_changes (check `expires_on` for expired rejections)
   - Load architectural_constraints (hard rules IRIS must not violate)
   - If absent: memory state = empty, will be created during IDEATE if decisions are made
4. Look for `.cursor/rules/METHOD-PDCA-T.md` → PDCA-T present
5. Look for co-existing methods rules in `.cursor/rules/`

---

## FASE 1: INGEST

Read everything. Assume nothing.

**Steps:**
1. List project root directory
2. Find dependency manifest (package.json / requirements.txt / Cargo.toml / go.mod / pom.xml / build.gradle / Gemfile / composer.json / .csproj)
3. Map directory structure to 2–3 levels
4. Find entry points (main.*, index.*, server.*, app.*, cmd/)
5. Profile: runtime, framework, database, test framework, linter, CI/CD
6. Detect PDCA-T / Enterprise Builder / Modular Design presence
7. Read README, changelogs, ADRs, IRIS_LOG.md
8. Note previous metrics or flag as first cycle
9. Load IRIS_MEMORY.json — intentional patterns, rejected changes, constraints. Flag any revisit_on ≤ today.

**Output:** Repository profile document + memory status.

---

## FASE 2: REVIEW

Quantify quality. No subjective opinions — facts and metrics only.

**Steps (analyze each dimension independently — parallel):**
1. Static: dead code, hardcoded values, broad exception handlers, duplicated blocks
2. Security: input validation, secrets, injection patterns
3. Architecture: coupling count, SRP violations, circular imports, layer violations
4. Test coverage: test files present? modules without tests? test quality?
5. Performance: N+1, no pagination, blocking I/O (static detection)

**Synthesis (after all 5 dimensions):**
6. Apply IRIS_MEMORY.json tags: intentional_patterns → NOTED, architectural_constraints → CONSTRAINED
7. Deduplicate findings across dimensions. Severity precedence: Security > Architecture > Performance > Static > Coverage
8. Calculate metrics from deduplicated findings:
   - Defect Density = (findings / LOC) × 1000
   - Test Coverage = (covered / total) × 100
   - Complexity Score = (cyclomatic × 0.6) + (cognitive × 0.4)
   - Tech Debt Ratio = (fix_hours / dev_hours) × 100
   - Architectural Health Index = avg(coupling, cohesion, SOLID, duplication)

**Output:** Quality report with metrics dashboard, findings table (including NOTED and CONSTRAINED).

---

## FASE 3: IDEATE

Build a safe, executable improvement plan.

**Steps:**
0. **Memory Filter** — check IRIS_MEMORY.json: skip permanently rejected changes, block constraint violations, present overdue intentional patterns for user review before planning
1. **Cascade Analysis** — for each finding, count how many secondary findings it eliminates. `final_score = impact_score + (cascade_score × 0.4)`. Produce cascade elimination map.
2. Score: Impact = (Business_Value × 0.4) + (Technical_Urgency × 0.3) + (Risk_Reduction × 0.3)
3. Estimate effort per improvement
4. Map dependencies (what must precede what)
5. Decompose into iterations — **400 LOC maximum per iteration — hard limit**
6. For each iteration: single objective, file list, LOC estimate, risk level, rollback, DoD

**Output:** Roadmap with cascade elimination map, blocked proposals list, iteration plan, success metrics.

---

## FASE 4: SHIP

Execute one iteration. No shortcuts.

**Steps:**
1. `git status` — must be clean
2. `git tag iris-start-iter-N` — recovery point
3. Read all target files before touching any
4. Implement: test-first for bugs; verify existing tests for refactoring
5. After each file: run module tests → if fail, fix NOW before next file
6. After all files: full suite + linter + coverage check
7. `git commit -m "IRIS-iter-N: [description]"`
8. Update IRIS_LOG.md

**Hard stops:** Any failing test = stop and fix before continuing.

---

## FASE 5: SPIN

Verify, learn, close, restart.

**Steps:**
1. Full regression test suite
2. Calculate post-cycle metrics
3. Compare before vs. after (5 metrics)
4. Self-review: does every change solve the problem? is it simpler? tests meaningful?
5. Document: what worked, what was harder, patterns discovered
6. Update IRIS_LOG.md (full cycle record)
7. Generate IRIS_OUTPUT.json if integrated
8. Define: when next cycle triggers

**Output:** Verification report + updated IRIS_LOG.md.

---

## Integration With Ecosystem

### PDCA-T Escalation
Receives: untestable code, coverage stuck at <99%
IRIS response: architectural refactoring to make code testable
Returns: refactored modules + new abstractions for PDCA-T to use

### Enterprise Builder Post-Delivery
Receives: Fase 8 delivery report + residual risks
IRIS response: baseline establishment + monitoring mode
Returns: NFR feedback, new risks, ADR updates

### Modular Design Health Check
Receives: contract violations + circular dependencies
IRIS response: refactoring preserving all contracts
Returns: resolved violations + pack improvement suggestions

---

## Metrics Quick Reference

| Metric | Target | Formula |
|--------|--------|---------|
| Defect Density | <1.0 per 1K LOC | (findings/LOC)×1000 |
| Test Coverage | ≥99% | (covered/total)×100 |
| Complexity Score | <12 | (cyclomatic×0.6)+(cognitive×0.4) |
| Tech Debt Ratio | <5% | (fix_hours/dev_hours)×100 |
| Arch Health Index | ≥90/100 | avg(coupling,cohesion,SOLID,duplication) |

---

## Absolute Constraints

- Never exceed 400 LOC per iteration
- Never advance past a failing test
- Always read files before modifying
- Always run tests after every file change
- Always verify DoD before closing iteration
- Never declare complete without IRIS_LOG.md updated
