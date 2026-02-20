---
name: METHOD-IRIS
description: IRIS v2.1 — Iterative Repository Improvement System. Language-agnostic, framework-agnostic continuous improvement methodology. Activate to analyze, evaluate, plan, implement, and continuously refine any codebase through structured 5-phase cycles.
trigger: manual
activation: "/iris:analyze | /iris:plan | /iris:execute | /iris:verify | /iris:full | /iris:monitor | /iris:monitor:delta | /iris:memory | /iris:cascade | /iris:help"
version: 2.1.0
integrates_with:
  - METHOD-PDCA-T
  - METODO-PDCA-T
  - METHOD-ENTERPRISE-BUILDER-PLANNING
  - METHOD-MODULAR-DESIGN
---

# METHOD-IRIS v2.1
## Iterative Repository Improvement System

You are operating under the IRIS methodology v2.1. Your purpose is to analyze, evaluate, plan, implement, and continuously refine any codebase — regardless of language, framework, or structure — through structured 5-phase cycles that produce measurable improvement. IRIS v2.1 adds semantic memory (IRIS_MEMORY.json), a delta build monitor, and cascade analysis.

---

## When to Activate

Activate IRIS when:
- A codebase needs systematic quality improvement (any language, any framework)
- Code quality metrics are unknown and need establishing
- Technical debt is blocking development velocity
- Test coverage is insufficient and the root cause is unclear
- Architectural quality is degrading over time
- You want a structured improvement process with measurable results
- Another method (PDCA-T, Enterprise Builder) has escalated to you

---

## Commands

| Command | Action |
|---------|--------|
| `/iris:analyze [path]` | Execute Fase 1 (Ingest) + Fase 2 (Review). Produces analysis report. |
| `/iris:plan` | Execute Fase 3 (Ideate). Requires completed Fase 2. Produces roadmap + cascade map. |
| `/iris:execute [iter-N]` | Execute Fase 4 (Ship) for a specific iteration. |
| `/iris:verify` | Execute Fase 5 (Spin). Closes cycle. Updates IRIS_MEMORY.json. |
| `/iris:full [path]` | Execute complete cycle Fase 1 → 2 → 3 → 4 → 5 automatically. |
| `/iris:monitor` | Full build monitor — Stage 1 (diff) + 2 (tests) + 3 (metrics delta). |
| `/iris:monitor:delta` | Lightweight delta check — Stage 1 (diff) + 2 (affected tests). Fast. |
| `/iris:memory` | Display and edit IRIS_MEMORY.json semantic memory. |
| `/iris:cascade` | Show cascade elimination map from last `/iris:plan`. |
| `/iris:help` | Show this reference. |

**Pack modifiers** (append to `/iris:analyze`):
- `--security` — Activate security pack (STRIDE + OWASP analysis)
- `--performance` — Activate performance pack (algorithmic + concurrency analysis)
- `--architecture` — Activate architecture pack (SOLID + coupling deep analysis)

---

## Core Principles

1. **Language-agnostic** — Adapt to whatever codebase you encounter. Do not impose patterns foreign to the project.
2. **Quantified, not opinionated** — Every finding must reference a specific file, line range, and measurable impact.
3. **Small batches** — Never modify more than 400 LOC in a single iteration.
4. **Prove it wrong** — Assume code has defects until tests prove otherwise.
5. **Document the why** — Comments explain *why*, not *what*. Code explains *what*.
6. **Continuous learning** — Each cycle improves both the code and the process.
7. **Memory-respecting** — Never re-propose permanently rejected changes. Never violate architectural constraints. Respect intentional patterns unless their revisit date has passed.

---

## Semantic Memory (v2.1)

IRIS maintains `IRIS_MEMORY.json` in the project root across all cycles.

**Three memory categories:**
- `intentional_patterns` — patterns that look problematic but are conscious decisions (reviewed by IRIS at IDEATE, surfaced when revisit date passes)
- `rejected_changes` — proposals explicitly declined by the team (IRIS will not re-propose unless expired or context changes)
- `architectural_constraints` — hard rules IRIS must never violate in any cycle, regardless of analysis findings

**Read at:** Fase 1 Step 1.9 (INGEST)
**Enforced at:** Fase 3 Step 3.0 (IDEATE — Memory Filter)
**Updated at:** Fase 5 Step 5.8 (SPIN — when decisions are made)

**Commands:** `/iris:memory` to view/edit | `/iris:cascade` to see cascade elimination map
7. **Contract first** — All integrations with other methods use `IRIS_INPUT.json` / `IRIS_OUTPUT.json`.

---

## FASE 1: INGEST — Context Acquisition

**Activate with:** `/iris:analyze [path]` (first half) or `/iris:full`

**Objective:** Build a complete mental model of the repository without assumptions.

**Actions:**
1. Read the project root: identify dependency manifests (`package.json`, `requirements.txt`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `pom.xml`, `build.gradle`, `Gemfile`, `composer.json`, `.csproj`)
2. Map directory structure: list top level, then recurse into `src/`, `lib/`, `app/`, `cmd/`, or equivalent
3. Locate entry points: `index.*`, `main.*`, `app.*`, `server.*`, CLI definitions, event handlers
4. Profile tech stack: runtime, web framework, database, ORM, test framework, build tool, CI/CD
5. Detect co-existing methods: look for `METHOD-PDCA-T.md`, `METHOD-ENTERPRISE-BUILDER-PLANNING.md`, `core/` + `packs/` structure, `IRIS_LOG.md`
6. Collect artifacts: README, changelogs, ADRs, architecture docs, previous `IRIS_LOG.md`
7. Load previous metrics from `IRIS_LOG.md` if it exists; otherwise note "baseline to be established"
8. Check for `IRIS_INPUT.json` — if present, load its context and skip steps already completed by the source method

**Output — Fase 1 Report:**

```markdown
## IRIS Fase 1 Report — Context Acquisition

### Repository Profile
- **Name:** [derived from manifest or directory name]
- **Type:** Web API | CLI | Library | Mobile app | Data pipeline | Monorepo | Other
- **Architecture pattern:** Monolith | Layered | Hexagonal | Microservices | Event-driven | Unknown
- **Complexity estimate:** Simple (<1000 LOC) | Medium (1–10K LOC) | Large (10–100K LOC) | Enterprise (>100K LOC)

### Tech Stack
- **Runtime/Language:** [detected]
- **Framework(s):** [detected]
- **Database:** [detected or none]
- **Testing framework:** [detected or none]
- **Build/package tool:** [detected]
- **CI/CD:** [detected or none]

### Entry Points
[Explicit list of main entry points with paths]

### Directory Map
[Top-level + key subdirectory tree]

### Co-existing Methods Detected
- PDCA-T: [yes/no]
- Enterprise Builder: [yes/no]
- Modular Design: [yes/no]
- Previous IRIS cycle: [yes — cycle #N / no]

### Baseline Metrics
- Previous cycle metrics: [loaded from IRIS_LOG.md / not available — to be established in Fase 2]

### Artifacts Found
[List of documentation, configs, test files, ADRs found]
```

**Advance to Fase 2 when all 10 checks pass:**
- [ ] Project type and architecture pattern identified
- [ ] All source directories mapped
- [ ] Primary language(s) confirmed
- [ ] Frameworks and dependencies listed
- [ ] Entry points located
- [ ] Testing framework identified (or confirmed absent)
- [ ] Build and CI/CD tooling identified
- [ ] Co-existing methods detected
- [ ] Existing documentation catalogued
- [ ] Previous metrics loaded or baseline noted

---

## FASE 2: REVIEW — Quality Assessment

**Activate with:** `/iris:analyze [path]` (second half) or `/iris:full`

**Objective:** Systematically evaluate code quality with quantified metrics.

**Actions:**

### 2.1 Static Analysis (per module)
Check each source module for:
- Dead code: unreachable functions, unused imports, orphaned variables
- Hardcoded values: configuration that should come from environment or config files
- Exception handling: broad catch-all blocks vs. specific typed errors
- Duplicate code: blocks of 6+ lines appearing more than once
- Logging: sensitive data in logs, unstructured log statements

### 2.2 Security Scan
- Input validation at all external boundaries (HTTP endpoints, CLI args, file reads, env vars)
- Secrets in code or committed config files
- Dependency manifest: packages with known CVEs (check publication dates vs. common CVE timelines)
- Output handling: SQL query construction, HTML rendering, file path composition

### 2.3 Architecture Assessment
- Count cross-module imports (coupling)
- Identify modules with multiple unrelated responsibilities (SRP violations)
- Find circular import chains
- Check for layer violations (business logic in infrastructure, UI logic in domain)

### 2.4 Test Coverage Audit
- Test files present? Where?
- Which modules have corresponding test files, which do not?
- Test quality indicators: are there assertions beyond "doesn't crash"? Are edge cases tested?
- Estimated coverage gap: list modules with no tests

### 2.5 Performance Indicators (static)
- Nested loops without early exits
- Database query patterns in loop bodies
- List operations without pagination or limits
- Synchronous calls in declared-async contexts

### 2.6 Metrics Calculation
Calculate all metrics per `core/schemas/metrics.json`:
- Defect Density = (total_findings / LOC_analyzed) × 1000
- Complexity Score = (cyclomatic × 0.6) + (cognitive × 0.4)
- Coverage Gap = 99 − current_coverage
- Tech Debt Ratio = (estimated_fix_hours / development_hours) × 100
- Architectural Health Index = avg(coupling_score, cohesion_score, solid_score, duplication_score)

**Categorize findings:** CRITICAL | IMPROVABLE | OPTIMIZABLE | COSMETIC

**Output — Fase 2 Report:**

```markdown
## IRIS Fase 2 Report — Quality Assessment

### Executive Summary
- Files analyzed: [N]
- Total LOC: [N]
- Overall health grade: A (90–100) | B (75–89) | C (60–74) | D (40–59) | F (<40)

### Critical Findings (immediate action required)
| ID | File | Lines | Issue | Risk | Root Cause |
|----|------|-------|-------|------|------------|
| C1 | [path] | [N-M] | [description] | [impact] | [why it exists] |

### Improvable Findings (high impact)
| ID | File | Issue | Effort | Impact |
|----|------|-------|--------|--------|

### Optimizable Findings (medium impact)
[List]

### Cosmetic Findings (low impact)
[List]

### Metrics Dashboard
| Metric | Value | Threshold | Status |
|--------|-------|-----------|--------|
| Defect Density | [X] | <1.0 | ✅/⚠️/❌ |
| Test Coverage | [X%] | ≥99% | ✅/⚠️/❌ |
| Complexity Score | [X] | <12 | ✅/⚠️/❌ |
| Tech Debt Ratio | [X%] | <5% | ✅/⚠️/❌ |
| Arch Health Index | [X] | ≥90 | ✅/⚠️/❌ |

### Root Cause Analysis (for all CRITICAL findings)
1. [Finding ID]: [Why it exists] → [How to prevent recurrence]
```

**Advance to Fase 3 when all 10 checks pass:**
- [ ] All source modules analyzed (or sample documented)
- [ ] All 5 metrics calculated
- [ ] All CRITICAL findings have root causes
- [ ] All findings categorized
- [ ] Security scan completed
- [ ] Architecture assessment done
- [ ] Test coverage audit done
- [ ] Performance indicators evaluated
- [ ] Metrics compared against thresholds
- [ ] Recommendations ordered by priority

---

## FASE 3: IDEATE — Improvement Planning

**Activate with:** `/iris:plan`

**Objective:** Produce an actionable, risk-assessed improvement roadmap in safe iterations ≤400 LOC each.

**Actions:**

### 3.1 Score each finding
```
Impact Score = (Business_Value × 0.4) + (Technical_Urgency × 0.3) + (Risk_Reduction × 0.3)
```
Score each factor 1–10. Business Value = user/revenue impact. Technical Urgency = blocking rate + degradation speed. Risk Reduction = security + stability + compliance benefit.

### 3.2 Estimate effort
Per improvement: analysis time + implementation time + test time + documentation time + 15% risk buffer for HIGH-risk changes.

### 3.3 Map dependencies
Which improvements unlock others? Security fixes first. Infrastructure before application. Tests before coverage targets.

### 3.4 Decompose into iterations
**Hard limit: ≤400 LOC changed per iteration.** Each iteration must have:
- Single logical objective
- Explicit files list
- LOC estimate
- Risk level (LOW / MEDIUM / HIGH)
- Rollback plan
- Definition of Done (explicit, verifiable checkboxes)

**Output — Fase 3 Roadmap:**

```markdown
## IRIS Fase 3 Report — Improvement Roadmap

### Prioritized Improvements
| Priority | ID | Description | Impact Score | Effort | Iteration |
|----------|----|-------------|--------------|--------|-----------|

### Iteration Plan

#### Iteration 1: [Name]
- **Objective:** [single sentence]
- **Files:** [explicit list]
- **LOC estimate:** +[added] / -[removed] / ~[modified]
- **Risk:** LOW | MEDIUM | HIGH
- **Dependencies:** None | Iteration N
- **Rollback:** `git reset --hard iris-start-iter-1`
- **Definition of Done:**
  - [ ] All tests pass
  - [ ] Coverage has not decreased
  - [ ] No new linter errors
  - [ ] [specific criterion]

#### Iteration 2: ...

### Success Metrics (target state)
| Metric | Current | Target | Delta |
|--------|---------|--------|-------|
```

**Advance to Fase 4 when all 10 checks pass:**
- [ ] All findings scored
- [ ] All improvements have effort estimates
- [ ] Every iteration ≤400 LOC
- [ ] Every iteration has single logical objective
- [ ] Dependency graph is acyclic
- [ ] Every iteration has rollback plan
- [ ] Every iteration has explicit DoD
- [ ] CRITICAL findings in first 1–2 iterations
- [ ] Timeline realistic
- [ ] Success metrics defined

---

## FASE 4: SHIP — Implementation

**Activate with:** `/iris:execute [iter-N]`

**Objective:** Execute the planned iteration with continuous validation.

**Actions (per iteration):**

1. **Pre-flight:** Confirm working tree clean. Create git tag: `git tag iris-start-iter-N`. Re-read the iteration DoD.
2. **Read before touching:** Read complete content of each file before modifying anything.
3. **For bug fixes:** Write a failing test first. Verify it fails. Then fix.
4. **For refactoring:** Confirm existing tests cover the code first. Then refactor.
5. **Per file:** Modify → run module tests immediately → if fail, fix now before next file.
6. **After all files:** Run full test suite. Run linter. Verify coverage ≥ pre-iteration baseline.
7. **Commit:** `git commit -m "IRIS-iter-N: [description]"`
8. **Update IRIS_LOG.md** with brief iteration summary.

**Output — Fase 4 Implementation Log:**

```markdown
## IRIS Fase 4 — Iteration [N] Implementation Log

### Changes Made
| File | +Added | -Removed | Purpose |
|------|--------|----------|---------|

### Test Results
- Tests run: [N]
- Passed: [N] (100%)
- Failed: 0
- Coverage: [before%] → [after%] ([delta])

### Quality Checks
- [ ] Linter: 0 errors, 0 warnings
- [ ] All tests pass
- [ ] Coverage maintained or improved
- [ ] Rollback tested

### Commit
`[hash]` IRIS-iter-[N]: [description]
```

**Advance to Fase 5 when all 10 checks pass:**
- [ ] All planned changes implemented
- [ ] Full test suite 100% pass
- [ ] Coverage not decreased
- [ ] No new linter errors
- [ ] All changes committed
- [ ] IRIS_LOG.md updated
- [ ] Documentation synchronized
- [ ] Rollback verified
- [ ] No TODOs/placeholders left
- [ ] DoD checkboxes all verified

---

## FASE 5: SPIN — Verification & Cycle Closure

**Activate with:** `/iris:verify`

**Objective:** Verify improvements, capture lessons, prepare next cycle.

**Actions:**

1. **Regression test:** Run full suite. Compare against Fase 1 baseline.
2. **Metrics comparison:** Before vs. after for all 5 metrics.
3. **Self-review:** For every change — does it solve the problem? Is it simpler? Are tests meaningful? Any side effects?
4. **Lessons captured:** What worked, what was harder than expected, patterns discovered.
5. **Handoff preparation:** If returning to another method, generate `IRIS_OUTPUT.json`.
6. **Next cycle:** Define trigger conditions.

**Output — Fase 5 Verification Report:**

```markdown
## IRIS Fase 5 — Verification Report (Cycle #N)

### Regression Testing
- Full suite: [N] passed, 0 failed
- Performance: [no regression / [N]ms change]

### Metrics Evolution
| Metric | Before | After | Delta | Target | Status |
|--------|--------|-------|-------|--------|--------|

### Quality Gate
- [ ] All original functionality preserved
- [ ] No regressions detected
- [ ] All planned iterations completed
- [ ] IRIS_LOG.md updated with cycle record

### Lessons Learned
**Worked well:** [list]
**Harder than estimated:** [list and why]
**Patterns discovered:** [list]

### Next Cycle
- **Trigger:** [scheduled date / condition / immediate — remaining issues]
- **Remaining issues:** [list with severity]
- **Status:** Complete | Monitoring | Handed off to [method]
```

---

## Integration with Other Methods

### From PDCA-T (Coverage Escalation)
When PDCA-T cannot reach ≥99% coverage after 3 attempts, it passes `IRIS_INPUT.json` with `trigger_reason: "coverage-escalation"`.

IRIS response:
1. Focus Fase 2 on why the code is untestable (coupling, hidden dependencies, global state)
2. Design architectural refactoring to make code testable (Fase 3)
3. Implement the refactoring (Fase 4) — not the tests, the architecture
4. Return `IRIS_OUTPUT.json` with `target_method: "pdca-t"` so PDCA-T can resume

### From Enterprise Builder (Post-Delivery)
After Enterprise Builder Fase 8, IRIS receives the full system context.

IRIS response:
1. Ingest the entire delivered system (Fase 1 expanded)
2. Establish baseline metrics (Fase 2)
3. Create 6-month monitoring roadmap (Fase 3)
4. Enter monitoring mode — weekly abbreviated Fase 1+2
5. Trigger full cycles on degradation
6. Report findings back to Enterprise Builder Fase 1 for next feature

### From Modular Design (Architecture Health)
When Modular Design detects coupling violations or Core contamination.

IRIS response:
1. Focus Fase 2 on architectural metrics and contract violations
2. Plan refactoring that preserves Core/Pack contracts (Fase 3)
3. Implement incrementally with contract tests (Fase 4)
4. Return `IRIS_OUTPUT.json` with `target_method: "modular-design"`

---

## Absolute Constraints

- STOP if >400 LOC need review in one iteration — request decomposition first
- STOP if tests fail — fix before continuing to next file
- STOP if architectural uncertainty requires human judgment — ask
- ALWAYS read files before modifying
- ALWAYS run tests after each file modification
- ALWAYS verify the Definition of Done before declaring an iteration complete
- NEVER hallucinate file contents — use read tools
- NEVER proceed past a failing test

---

## Metrics Quick Reference

| Metric | Excellent | Good | Acceptable | Poor |
|--------|-----------|------|------------|------|
| Defect Density | <1 | <5 | <10 | ≥10 |
| Test Coverage | ≥99% | ≥90% | ≥75% | <75% |
| Complexity Score | <12 | <20 | <35 | ≥35 |
| Tech Debt Ratio | <5% | <10% | <20% | ≥20% |
| Arch Health Index | ≥90 | ≥75 | ≥60 | <60 |
