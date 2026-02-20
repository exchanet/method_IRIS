# Method IRIS — Google Antigravity Edition
# Iterative Repository Improvement System v2.1

> **Version:** 2.1.0 | **Author:** Francisco J Bernades | **Agent:** Google Antigravity

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

Also responds to: "analyze this codebase with IRIS", "run IRIS on this project", "start an IRIS cycle", "use the IRIS method".

## Purpose

IRIS (Iterative Repository Improvement System) is a language-agnostic, framework-agnostic continuous improvement methodology. It works on any codebase — any language, any framework, any architecture.

**The 5-Phase Cycle:**
```
INGEST → REVIEW → IDEATE → SHIP → SPIN → (next cycle)
```

Operates standalone or integrated with PDCA-T, Enterprise Builder, and Modular Design.

## Context Check (always run first, before any command)

1. Look for `IRIS_INPUT.json` in project root → load source method context if found
2. Look for `IRIS_LOG.md` in project root → load previous cycle number and metrics
3. Look for `IRIS_MEMORY.json` in project root → load semantic memory (rejected changes, intentional patterns, architectural constraints)
4. Look for `.cursor/rules/METHOD-PDCA-T.md` → PDCA-T active
5. Look for `.cursor/rules/METHOD-ENTERPRISE-BUILDER-PLANNING.md` → Enterprise Builder active
6. Look for `core/` + `packs/` directory structure → Modular Design active

---

## FASE 1: INGEST

Read everything. Assume nothing.

**Steps:**
1. List project root directory
2. Find dependency manifest: `package.json`, `requirements.txt`, `Cargo.toml`, `go.mod`, `pom.xml`, `build.gradle`, `Gemfile`, `composer.json`, `.csproj`, `pyproject.toml`, `mix.exs`, `pubspec.yaml`
3. Map directory structure to 2–3 levels
4. Find entry points: `main.*`, `index.*`, `server.*`, `app.*`, `cmd/`
5. Profile: runtime, framework, database, test framework, linter, CI/CD
6. Detect PDCA-T / Enterprise Builder / Modular Design presence
7. Read README, changelogs, ADRs, `IRIS_LOG.md`
8. Note previous metrics or flag as first cycle
9. **Load `IRIS_MEMORY.json`** — read intentional patterns, rejected changes, constraints. Flag any intentional_pattern with `revisit_on` ≤ today for user review at IDEATE start

**Output:** Repository profile document + co-existing methods + memory status.

---

## FASE 2: REVIEW

Quantify quality. No subjective opinions — facts and metrics only.

**Parallel analysis — analyze each dimension independently before combining:**

- Dim 1 — Static Analysis: dead code, hardcoded values, exception handling, duplication
- Dim 2 — Security: input validation, secrets, injection risks, auth bypass
- Dim 3 — Architecture: coupling, cohesion, SOLID violations, layer violations
- Dim 4 — Test Coverage: test files present, modules without tests, test quality
- Dim 5 — Performance: N+1 queries, missing pagination, blocking I/O

**After all 5 dimensions: Synthesis step**
- Deduplicate findings that appear in multiple dimensions (keep highest severity)
- Resolve severity conflicts: Security > Architecture > Performance > Static > Coverage
- Calculate 5 metrics using deduplicated findings:
  - Defect Density = (findings / LOC) × 1000 [target: <1.0]
  - Test Coverage = (covered / total) × 100 [target: ≥99%]
  - Complexity Score = (cyclomatic × 0.6) + (cognitive × 0.4) [target: <12]
  - Tech Debt Ratio = (fix_hours / dev_hours) × 100 [target: <5%]
  - Arch Health Index = avg(coupling, cohesion, SOLID, duplication) [target: ≥90]

**Memory tagging:** Findings matching `intentional_patterns` → tag as NOTED (not IMPROVABLE). Findings blocked by `architectural_constraints` → tag as CONSTRAINED.

Categorize remaining: CRITICAL | IMPROVABLE | OPTIMIZABLE | COSMETIC

---

## FASE 3: IDEATE

Build a safe, executable improvement plan.

**Steps:**
1. **Memory Filter** — Before scoring anything, check `IRIS_MEMORY.json`:
   - Proposed improvement matches `rejected_change` → skip or show in Blocked Proposals
   - Proposed improvement violates `architectural_constraint` → mark as BLOCKED
   - `intentional_pattern` due for revisit → present to user before continuing

2. **Cascade Analysis** — For each remaining finding:
   - Does resolving this finding eliminate other findings automatically?
   - `cascade_score` = count of eliminated secondary findings
   - `final_score = impact_score + (cascade_score × 0.4)`

3. **Impact Scoring** — Score each finding:
   `Impact = (Business_Value × 0.4) + (Technical_Urgency × 0.3) + (Risk_Reduction × 0.3)`

4. Estimate effort per improvement
5. Map dependencies (what must precede what)
6. Decompose into iterations — **400 LOC maximum per iteration — hard limit**
7. Each iteration: single objective, file list, DoD, rollback plan, risk level

**Output:** Roadmap + cascade elimination map + success metrics.

---

## FASE 4: SHIP

Execute one iteration. No shortcuts.

**Steps:**
1. `git status` — must be clean
2. `git tag iris-start-iter-N` — recovery point
3. Read all files before modifying any
4. Implement: test-first for bugs; verify existing tests for refactoring
5. After each file: run module tests → if fail, fix NOW before next file
6. After all files: full suite + linter + coverage check
7. `git commit -m "IRIS-iter-N: [description]"`
8. Update `IRIS_LOG.md`

**Hard stops:** Any failing test = stop and fix before continuing.

---

## FASE 5: SPIN

Verify, learn, close, restart.

**Steps:**
1. Full regression test suite
2. Calculate post-cycle metrics (all 5)
3. Compare before vs. after — produce delta table
4. Self-review: does every change solve the problem? simpler? tests meaningful?
5. Document lessons learned
6. Update `IRIS_LOG.md` (full cycle record)
7. Update `IRIS_MEMORY.json` if any changes were rejected or patterns were marked intentional
8. Generate `IRIS_OUTPUT.json` if integrated with another method
9. Define next cycle triggers

**Output:** Verification report + updated IRIS_LOG.md + updated IRIS_MEMORY.json.

---

## Build Monitor (v2.1)

### `/iris:monitor:delta`
Lightweight delta check — runs only on changed files since last build:
1. Extract diff from last successful build ref (from IRIS_LOG.md)
2. Identify impact scope: changed files + direct importers
3. Run only affected tests
4. If tests fail: auto-fix attempt (max 3 tries) or escalate
5. If OK: report healthy

Exit conditions:
- `<5% LOC change AND all metrics stable` → convergence, do not trigger full cycle
- `Same error for 3 builds` → escalate to human with full context
- `Diff undoes an IRIS change` → stop, flag human conflict

### `/iris:monitor`
Full monitoring pipeline (Stage 1 + 2 + 3):
- Same as delta, plus partial metrics recalculation for changed modules
- Triggers full IRIS cycle if 2+ metrics degrade simultaneously

---

## Semantic Memory (v2.1)

### `/iris:memory`
Displays and allows editing `IRIS_MEMORY.json`:
- Intentional patterns (patterns that look bad but are conscious decisions)
- Rejected changes (proposals declined by the team)
- Architectural constraints (hard rules IRIS must never violate)

IRIS reads memory at INGEST and enforces it at IDEATE. Memory persists across all cycles.

### `/iris:cascade`
Shows the cascade elimination map from the last `/iris:plan`:
- Which improvements eliminate secondary problems automatically
- Adjusted priority scores including cascade effect
- Useful for re-evaluating iteration order

---

## Integration With Ecosystem

### PDCA-T Escalation
Receives: untestable code, coverage stuck at <99%
IRIS does: architectural refactoring to make code testable
Returns: refactored modules + new interfaces + IRIS_OUTPUT.json for PDCA-T to resume

### Enterprise Builder Post-Delivery
Receives: Fase 8 delivery report + residual risks
IRIS does: baseline establishment + monitoring mode (via Build Monitor)
Returns: NFR adjustments + new risks + ADR updates in IRIS_OUTPUT.json

### Modular Design Health Check
Receives: contract violations + circular dependencies
IRIS does: refactoring preserving all Core/Pack contracts
Returns: resolved violations + pack improvement suggestions in IRIS_OUTPUT.json

---

## Metrics Reference

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
- Never re-propose a permanently rejected change (check IRIS_MEMORY.json)
- Never violate an architectural constraint regardless of analysis findings
