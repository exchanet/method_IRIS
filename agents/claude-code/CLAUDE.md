# Method IRIS — Claude Code Edition
# Iterative Repository Improvement System v2.1

> **Version:** 2.1.0 | **Author:** Francisco J Bernades | **Agent:** Claude Code (Anthropic)

When IRIS is activated, follow EXACTLY the 5-phase protocol below. Do not skip phases. Do not combine phases. Produce structured output at every phase transition.

## Available Commands

| Command | Action |
|---------|--------|
| `IRIS: analyze [path]` | Fase 1 (context) + Fase 2 (quality assessment) |
| `IRIS: plan` | Fase 3 (improvement roadmap) — requires Fase 2 complete |
| `IRIS: execute iter-N` | Fase 4 (implement iteration N) — requires Fase 3 complete |
| `IRIS: verify` | Fase 5 (verify + close cycle) — updates IRIS_MEMORY.json |
| `IRIS: full [path]` | Complete cycle Fase 1 → 2 → 3 → 4 → 5 |
| `IRIS: monitor` | Full build monitor (diff + affected tests + metrics delta) |
| `IRIS: monitor:delta` | Lightweight delta check (diff + affected tests only — fast) |
| `IRIS: memory` | Display and edit IRIS_MEMORY.json semantic memory |
| `IRIS: cascade` | Show cascade elimination map from last IRIS: plan |
| `IRIS: help` | Display this reference |
| `IRIS: analyze --security` | Fase 1+2 with security pack (STRIDE + OWASP) |
| `IRIS: analyze --performance` | Fase 1+2 with performance pack |
| `IRIS: analyze --architecture` | Fase 1+2 with architecture pack (SOLID + coupling) |

## System Nature

IRIS is a **language-agnostic, framework-agnostic** improvement methodology. It does not impose structure — it discovers, evaluates, and improves what exists. It adapts to any codebase.

IRIS operates:
- **Standalone** — directly activated on any repository
- **Integrated** — as a quality escalation layer for PDCA-T, Enterprise Builder, or Modular Design

## Tool Preferences (Claude Code Specific)

- **Read** — read any file before modifying it
- **Edit** — make precise changes using `old_string`/`new_string` pattern
- **Write** — create new files (IRIS_LOG.md, IRIS_INPUT.json, IRIS_OUTPUT.json, IRIS_MEMORY.json)
- **Bash** — run tests, linters, coverage reports, git commands
- Confirm before destructive operations

## Context Detection (run before any command)

1. Check for `IRIS_INPUT.json` in project root — load source method context
2. Check for `IRIS_LOG.md` — load previous cycle data
3. Check for `IRIS_MEMORY.json` — load semantic memory:
   - Load intentional_patterns, rejected_changes, architectural_constraints
   - Flag any intentional_pattern with `revisit_on ≤ today` for IDEATE review
   - Note any rejected_change with `expires_on` in the past (re-evaluatable)
   - If not found: note "memory absent — will create during IDEATE if decisions are made"
4. Check for co-existing methods:
   - `METHOD-PDCA-T.md` or `METODO-PDCA-T.md` → PDCA-T detected
   - `METHOD-ENTERPRISE-BUILDER-PLANNING.md` → Enterprise Builder detected
   - `core/` + `packs/` structure → Modular Design detected

---

## Fase 1: INGEST

**Activated by:** `IRIS: analyze [path]` or `IRIS: full`

**Actions:**
1. Read project root directory
2. Identify dependency manifests and determine language/ecosystem
3. Map directory structure (2–3 levels deep)
4. Locate entry points
5. Profile tech stack (runtime, framework, DB, test framework, CI/CD)
6. Detect co-existing methods
7. Collect documentation artifacts
8. Load previous metrics from IRIS_LOG.md (or note first cycle)
9. Load IRIS_MEMORY.json — intentional patterns, rejected changes, constraints. Flag any revisit_on ≤ today.

**Gate:** Ask user to confirm repository profile before proceeding to Fase 2.

---

## Fase 2: REVIEW

**Activated by:** `IRIS: analyze` (second half) or `IRIS: full`

**Actions (5 dimensions analyzed in parallel — independently):**
1. Static analysis: dead code, hardcoded values, exception handling, duplication
2. Security: input validation, secrets, SQL injection, outdated dependencies
3. Architecture: coupling, cohesion, SOLID violations, layer violations
4. Test coverage: test files present, modules without tests, test quality
5. Performance: N+1 queries, missing pagination, blocking I/O (static detection)
6. Apply IRIS_MEMORY.json tags: intentional patterns → NOTED, architectural constraints → CONSTRAINED
7. Synthesis: deduplicate findings across dimensions, resolve severity conflicts (Security > Architecture > Performance > Static > Coverage)
8. Calculate all 5 metrics from deduplicated findings
9. Categorize: CRITICAL | IMPROVABLE | OPTIMIZABLE | COSMETIC | NOTED | CONSTRAINED

**Gate:** All metrics calculated before proceeding. No CRITICAL finding without root cause.

---

## Fase 3: IDEATE

**Activated by:** `IRIS: plan`

**Actions:**
0. Memory Filter: check IRIS_MEMORY.json — skip permanently rejected changes, block constraint violations, present overdue intentional patterns for user review
1. Cascade Analysis: for each finding, count how many secondary findings it eliminates. `final_score = impact_score + (cascade_score × 0.4)`
2. Score each finding: `Impact = (Business_Value × 0.4) + (Technical_Urgency × 0.3) + (Risk_Reduction × 0.3)`
3. Estimate effort per improvement (analysis + implementation + tests + docs + risk buffer)
4. Map dependencies between improvements (topological sort)
5. Decompose into iterations — **hard limit: ≤400 LOC per iteration**
6. Sequence: CRITICAL first, then foundation work, then high impact, then polish
7. Risk mitigation for HIGH-risk iterations
8. Define success metrics (target state)

**Gate:** Every iteration has DoD, rollback plan, single objective. LOC budget verified ≤400.

---

## Fase 4: SHIP

**Activated by:** `IRIS: execute iter-N`

**Actions (per iteration):**
1. Check git status — must be clean before starting
2. Create recovery tag: `git tag iris-start-iter-N`
3. Re-read all files to be modified
4. Implement: for bugs — test first; for refactoring — verify tests exist first
5. After each file: run module-level tests immediately. If fail: fix before next file.
6. After all files: run full test suite + linter + coverage
7. Commit: `git commit -m "IRIS-iter-N: [description]"`
8. Update IRIS_LOG.md
9. Update `IRIS_MEMORY.json` if: user rejected a change, user marked a pattern as intentional, or a context change was detected

**Gate:** 100% tests pass, coverage not decreased, linter clean, DoD verified.

---

## Fase 5: SPIN

**Activated by:** `IRIS: verify`

**Actions:**
1. Run full regression test suite
2. Calculate post-cycle metrics (compare vs. Fase 2 baseline)
3. Self-review each change (solves problem? simpler? tests meaningful? follows conventions?)
4. Document lessons learned
5. Update IRIS_LOG.md with complete cycle record
6. Generate IRIS_OUTPUT.json if integrated with another method
7. Define next cycle triggers

**Gate:** All original tests pass. Metrics delta calculated. IRIS_LOG.md updated.

---

## Integration With Other Methods

### From PDCA-T (Coverage Escalation)
Read IRIS_INPUT.json. Focus Fase 2 on *why* code is untestable. Focus Fase 3 on architectural fixes (abstractions, decoupling). Do not plan "write tests" — only plan "make code testable". Return IRIS_OUTPUT.json for PDCA-T to resume.

### From Enterprise Builder (Post-Delivery)
Read delivery report from enterprise_context. Establish baseline metrics. Enter monitoring mode after first cycle. Return nfr_adjustments, new_risks, adr_updates in IRIS_OUTPUT.json.

### From Modular Design (Architecture Health)
Read architecture violations from architecture_context. All refactoring must preserve Core/Pack contracts. Return resolved_violations and new_pack_suggestions in IRIS_OUTPUT.json.

---

## Absolute Constraints

- STOP if iteration exceeds 400 LOC — decompose first
- STOP if tests fail — fix before next file
- ALWAYS read files before modifying
- ALWAYS run tests after each file modification
- NEVER hallucinate file contents — use Read tool
- NEVER proceed past a failing test without fixing it

---

## Metrics Reference

| Metric | Target | Formula |
|--------|--------|---------|
| Defect Density | <1.0 | (findings / LOC) × 1000 |
| Test Coverage | ≥99% | (covered_lines / total) × 100 |
| Complexity Score | <12 | (cyclomatic × 0.6) + (cognitive × 0.4) |
| Tech Debt Ratio | <5% | (fix_hours / dev_hours) × 100 |
| Arch Health Index | ≥90 | avg(coupling, cohesion, SOLID, duplication) |
