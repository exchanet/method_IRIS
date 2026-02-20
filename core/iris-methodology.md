# IRIS Core Methodology v2.1
# Iterative Repository Improvement System

> **Language-agnostic, framework-agnostic, structure-agnostic.**
> IRIS adapts to any codebase it encounters. It does not impose structure — it discovers, evaluates, and improves what exists.

---

## Purpose

IRIS is a 5-phase systematic improvement loop designed to transform any repository — regardless of language, framework, or architecture — into progressively better software. It operates in infinite cycles: each cycle ends by preparing the next one. There is no "done," only "better."

IRIS can operate:
- **Standalone** — activated directly on any repository
- **Integrated** — as a quality escalation layer within an ecosystem of methods (PDCA-T, Enterprise Builder, Modular Design)

---

## The 5-Phase IRIS Cycle

```
┌─────────────────────────────────────────────────────┐
│                   IRIS CYCLE #N                      │
│                                                     │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐        │
│  │ FASE 1   │──▶│ FASE 2   │──▶│ FASE 3   │        │
│  │  INGEST  │   │  REVIEW  │   │  IDEATE  │        │
│  └──────────┘   └──────────┘   └──────────┘        │
│       ▲                              │              │
│       │                              ▼              │
│  ┌──────────┐   ┌──────────┐        │              │
│  │ FASE 5   │◀──│ FASE 4   │◀───────┘              │
│  │   SPIN   │   │   SHIP   │                       │
│  └──────────┘   └──────────┘                       │
│       │                                             │
│       └──────────── CYCLE #N+1 ────────────────────▶│
└─────────────────────────────────────────────────────┘
```

---

## Phase Definitions

### FASE 1: INGEST — Context Acquisition

**Objective:** Build a complete mental model of the repository without assumptions.

**Inputs:**
- Repository path or specific files/modules to analyze
- Optional: `IRIS_INPUT.json` from another method (PDCA-T, Enterprise Builder, Modular Design)
- Optional: `IRIS_LOG.md` from previous cycles

**Process:**
1. Map directory structure — top-level, then key subdirectories
2. Identify project type: Web API, CLI tool, library, mobile app, data pipeline, monorepo, etc.
3. Profile tech stack: runtime, frameworks, databases, external services, build tools, test frameworks
4. Locate entry points: main files, API routers, CLI commands, event handlers, configuration loaders
5. Detect co-existing methods: look for `.cursor/rules/METHOD-PDCA-T.md`, `docs/enterprise-plan/`, `core/` + `packs/` structure
6. Collect existing artifacts: README, ADRs, changelogs, previous IRIS logs, CI/CD configs
7. Load baseline metrics if previous cycle data exists in `IRIS_LOG.md`

**Outputs:**
- Repository profile document (type, stack, architecture pattern, complexity estimate)
- Entry points map
- Integration method detection results
- Baseline metrics (loaded or noted as "to be established in Fase 2")

**Advance to Fase 2 when all 10 checks pass:**
- [ ] Project type identified and described in one sentence
- [ ] All source directories mapped
- [ ] Primary language(s) and runtime confirmed
- [ ] Frameworks and key dependencies listed
- [ ] All entry points located
- [ ] Testing framework identified (or noted as absent)
- [ ] Build and CI/CD tooling identified
- [ ] Co-existing methods detected (or confirmed absent)
- [ ] Existing documentation artifacts catalogued
- [ ] Previous metrics loaded or noted as "baseline to be established"

**Retreat to manual clarification when:**
- Repository structure is unclear after analysis (e.g., no recognizable entry points, no dependency manifest)
- Access to key files is denied or files are missing

---

### FASE 2: REVIEW — Quality Assessment

**Objective:** Systematically evaluate current code quality across all dimensions using quantified metrics.

**Inputs:** Fase 1 context document

**Process:**

#### 2.1 Static Analysis (language-agnostic principles)
For each source module, evaluate:
- Dead code: unreachable functions, unused imports, orphaned variables
- Hardcoded values: literals that should be configuration
- Exception handling specificity: broad catch-all vs. specific error types
- Logging quality: structured vs. unstructured, sensitive data exposure
- Code duplication: copy-paste patterns across modules

#### 2.2 Security Assessment
- Input validation at all external boundaries (API endpoints, CLI args, file reads, env vars)
- Output sanitization before rendering or returning data
- Secrets and credentials: hardcoded or committed to version control
- Dependency vulnerabilities: outdated packages with known CVEs
- Authentication and authorization presence (not correctness — that requires execution)

#### 2.3 Architectural Assessment
- Coupling: how many modules depend on each other (count cross-module imports)
- Cohesion: does each module have a single, clear responsibility?
- SOLID principle violations (observable from code structure, not runtime)
- Circular dependencies between modules
- Layer violations: business logic in infrastructure code, etc.

#### 2.4 Test Coverage Audit
- Test files present? (yes/no, and location)
- Estimated coverage: which modules have tests, which do not
- Test quality indicators: assertions present, mocked dependencies, edge cases visible
- Missing test types: unit, integration, contract, end-to-end

#### 2.5 Performance Indicators (static, observable)
- Nested loops without early exit
- Database queries inside loops (N+1 pattern observable in code)
- Missing pagination in list operations
- Synchronous blocking calls in async contexts
- Memory allocation patterns (large allocations in tight loops)

#### 2.6 Metrics Calculation
Calculate all metrics defined in `core/schemas/metrics.json`:
- Defect Density
- Complexity Score (cyclomatic + cognitive, weighted)
- Coverage Gap
- Tech Debt Ratio (estimated)
- Architectural Health Index

**Categorize all findings:**
- **CRITICAL** — Security vulnerabilities, data loss risks, crashes, compliance violations
- **IMPROVABLE** — Bugs, significant tech debt, architectural problems, performance bottlenecks
- **OPTIMIZABLE** — Refactoring opportunities, minor performance gains, code clarity
- **COSMETIC** — Style inconsistencies, naming, formatting

**Outputs:**
- Quality Assessment Report with findings table
- Metrics Dashboard (all 5 core metrics with values and threshold comparison)
- Root cause analysis for all CRITICAL findings
- Prioritized recommendation list

**Advance to Fase 3 when all 10 checks pass:**
- [ ] All source modules analyzed (or representative sample for large codebases, with sampling documented)
- [ ] All 5 core metrics calculated
- [ ] All CRITICAL findings have root cause identified
- [ ] Findings categorized: CRITICAL / IMPROVABLE / OPTIMIZABLE / COSMETIC
- [ ] Security assessment completed
- [ ] Architecture assessment completed
- [ ] Test coverage audit completed
- [ ] Performance indicators evaluated
- [ ] Metrics compared against thresholds from `metrics.json`
- [ ] Recommendation list ordered by priority

**Retreat to Fase 1 when:**
- New context discovered during analysis that fundamentally changes the repository profile

---

### FASE 3: IDEATE — Improvement Planning

**Objective:** Design a prioritized, risk-assessed, actionable improvement roadmap broken into safe iterations.

**Inputs:** Fase 2 Quality Assessment Report

**Process:**

#### 3.1 Impact Scoring
For each finding, calculate:
```
Impact Score = (Business_Value × 0.4) + (Technical_Urgency × 0.3) + (Risk_Reduction × 0.3)
```
Where each factor is scored 1–10:
- Business Value: user-facing impact, reliability, correctness
- Technical Urgency: is it blocking other work? is it degrading?
- Risk Reduction: security, data integrity, system stability

#### 3.2 Effort Estimation
For each improvement, estimate:
- Analysis time (understanding the code)
- Implementation time (writing changes)
- Test time (writing/running tests)
- Documentation time (comments, docs update)
- Risk buffer (15% of total for high-risk changes)

#### 3.3 Dependency Graph
Identify which improvements must happen before others:
- Security fixes before any other changes (reduced blast radius)
- Infrastructure changes before application-layer changes
- Test infrastructure before coverage improvements
- Architectural changes before feature additions

#### 3.4 Iteration Decomposition
**Non-negotiable constraint:** Every iteration must modify ≤400 LOC.

Each iteration must have:
- Single logical objective (no mixing refactoring with feature additions)
- Specific files affected (listed explicitly)
- Estimated LOC change (+added, -removed)
- Risk level: LOW / MEDIUM / HIGH
- Rollback plan
- Definition of Done (explicit, verifiable criteria)

#### 3.5 Iteration Sequencing
Order iterations by:
1. CRITICAL findings first (security, crashes)
2. High impact / low effort next (quick wins)
3. Architectural improvements (unlock future iterations)
4. Coverage improvements (test what was just fixed)
5. OPTIMIZABLE / COSMETIC last

**Outputs:**
- Prioritized improvements table with Impact Scores
- Iteration plan with all fields defined
- Dependency graph (text-based)
- Risk mitigation strategies
- Success metrics (target state after all iterations)

**Advance to Fase 4 when all 10 checks pass:**
- [ ] All findings have Impact Scores calculated
- [ ] All improvements have effort estimates
- [ ] Every iteration modifies ≤400 LOC
- [ ] Every iteration has a single logical objective
- [ ] Dependency graph is acyclic
- [ ] Every iteration has a rollback plan
- [ ] Every iteration has an explicit Definition of Done
- [ ] CRITICAL findings addressed in first 1–2 iterations
- [ ] Timeline is realistic (estimated vs. available hours)
- [ ] Success metrics defined for final state

**Retreat to Fase 2 when:**
- Planning reveals new high-severity findings not identified in Fase 2

---

### FASE 4: SHIP — Implementation

**Objective:** Execute the planned improvements with maximum quality, minimum risk, and continuous validation.

**Inputs:** Iteration plan from Fase 3

**Process (per iteration):**

#### 4.1 Pre-Implementation Checklist
- Confirm working tree is clean (no uncommitted changes)
- Create backup reference: `git tag iris-start-iter-[N]` or note the current commit hash
- Re-read the iteration's Definition of Done
- Read all files to be modified before touching any

#### 4.2 Implementation Approach
**Order of operations within each iteration:**
1. If fixing a bug: write a failing test first, then fix
2. If refactoring: ensure existing tests cover the code, then refactor
3. If adding tests: analyze uncovered code, write tests, verify they pass
4. If improving architecture: make the smallest structural change that unblocks future work

**Per-file process:**
- Read the complete file
- Understand all callers and dependencies
- Make the minimum necessary change
- Add or update comments explaining *why* (not what)
- Run the relevant tests immediately

#### 4.3 Continuous Validation
After every file modification:
- Run tests for that module (not the full suite — focused feedback)
- If tests fail: fix immediately before moving to the next file
- Never accumulate more than one failing test at a time

#### 4.4 Documentation Synchronization
For every change:
- Update inline comments if behavior changes
- Update README if public interface changes
- Update `IRIS_LOG.md` with a brief note of what changed

#### 4.5 Iteration Completion
After all files in the iteration are modified:
- Run the full test suite
- Run linter/static analysis
- Verify coverage has not decreased
- Commit with message format: `IRIS-iter-[N]: [description]`

**Outputs:**
- Implementation log (changes made, commits, test results)
- Updated `IRIS_LOG.md`
- Test execution results (pass/fail counts, coverage delta)

**Advance to Fase 5 when all 10 checks pass:**
- [ ] All planned changes in this iteration are implemented
- [ ] Full test suite passes (100% pass rate)
- [ ] Coverage has not decreased from pre-iteration baseline
- [ ] No new linter errors introduced
- [ ] All changes are committed with descriptive messages
- [ ] `IRIS_LOG.md` updated
- [ ] Documentation synchronized with code changes
- [ ] Rollback tested (can revert to `iris-start-iter-[N]` cleanly)
- [ ] No TODO or placeholder left in modified code
- [ ] Definition of Done criteria all verified

**Retreat to Fase 3 when:**
- Implementation reveals the plan is incorrect or incomplete
- A fix introduces unexpected complexity requiring re-planning

---

### FASE 5: SPIN — Verification & Cycle Closure

**Objective:** Verify all improvements, document learnings, and prepare the next cycle.

**Inputs:** Implementation results from Fase 4

**Process:**

#### 5.1 Regression Verification
- Run full test suite (unit + integration + any e2e available)
- Compare against pre-cycle baseline: did anything break that was previously working?
- Run any performance benchmarks if they existed before

#### 5.2 Metrics Comparison
Compare before vs. after for all 5 core metrics:
- Defect Density: should decrease
- Complexity Score: should decrease or stay equal
- Coverage Gap: should decrease
- Tech Debt Ratio: should decrease
- Architectural Health Index: should increase

#### 5.3 Self-Review
For every change made in Fase 4, verify:
- Does it solve the original problem from Fase 2?
- Is the solution simpler than before?
- Are the tests meaningful (not just passing, but asserting correct behavior)?
- Does the documentation explain the *why*?
- Does it follow existing conventions in the codebase?
- Any unintended side effects introduced?

#### 5.4 Lessons Captured
Document explicitly:
- What worked well in this cycle
- What was harder than estimated (and why)
- Patterns discovered (good and bad)
- Adjustments to make in the next cycle
- Any new findings that should feed into the next Fase 2

#### 5.5 Handoff Preparation (if integrated)
If returning control to another method, generate `IRIS_OUTPUT.json` per `handoff-output.json` schema with:
- Improved metrics
- Changes made summary
- Remaining issues (what IRIS did not address)
- Recommended next action for the receiving method

#### 5.6 Next Cycle Trigger Definition
Define when the next cycle should start:
- **Immediate:** Remaining CRITICAL or IMPROVABLE findings from Fase 2 not yet addressed
- **Scheduled:** Periodic health check (weekly, bi-weekly, monthly)
- **Triggered:** Coverage drops below threshold, new dependencies added, significant feature added
- **On-demand:** Manual activation

**Outputs:**
- Verification Report (regression results, metrics comparison)
- Lessons Learned document
- Updated `IRIS_LOG.md` with complete cycle record
- Optional: `IRIS_OUTPUT.json` for method handoffs
- Next cycle trigger definition

**Return to Fase 1 (start new cycle) when:**
- Remaining improvements identified in Fase 2 not yet addressed
- Scheduled next cycle date reached
- Degradation trigger fired

**Advance to monitoring mode when:**
- All CRITICAL and IMPROVABLE findings addressed
- Metrics at or above targets
- Only OPTIMIZABLE and COSMETIC findings remain

**Advance to Fase 3 (skip re-analysis) when:**
- Regression detected — jump directly to re-planning

---

## Transition Table

| From | To | Condition |
|------|----|-----------|
| Fase 1 | Fase 2 | All 10 Fase 1 checks pass |
| Fase 2 | Fase 3 | All 10 Fase 2 checks pass |
| Fase 3 | Fase 4 | All 10 Fase 3 checks pass |
| Fase 4 | Fase 5 | All 10 Fase 4 checks pass |
| Fase 5 | Fase 1 (new cycle) | Improvements remain OR trigger fired |
| Fase 5 | Fase 3 | Regression detected — skip re-analysis |
| Fase 4 | Fase 3 | Implementation reveals plan is wrong |
| Fase 2 | Fase 1 | New context changes repository profile |
| Any | Manual stop | All metrics at targets, monitoring mode active |

---

## Absolute Principles

### 10 NEVER
1. NEVER modify more than 400 LOC in a single iteration — decompose first
2. NEVER proceed past a test failure — fix it before moving forward
3. NEVER assume code is correct — assume it has defects until proven otherwise
4. NEVER skip the pre-implementation read — understand before modifying
5. NEVER mix refactoring with feature additions in one iteration
6. NEVER commit without verifying tests still pass
7. NEVER remove code without verifying it is actually unused
8. NEVER hardcode values that should be configurable
9. NEVER declare an iteration complete without verifying the Definition of Done
10. NEVER stop after the first cycle — improvement is continuous

### 10 ALWAYS
1. ALWAYS read the complete file before modifying any part of it
2. ALWAYS explain the *why* in comments, never just the *what*
3. ALWAYS run tests after every file modification (not just at the end)
4. ALWAYS verify coverage does not decrease after each iteration
5. ALWAYS document lessons learned after each cycle
6. ALWAYS define rollback before implementing high-risk changes
7. ALWAYS leave the codebase in a better state than found — even if stopping mid-cycle
8. ALWAYS adapt analysis to the codebase's conventions — do not impose foreign patterns
9. ALWAYS calculate metrics numerically — qualitative opinions are supplemental, not primary
10. ALWAYS prepare the next cycle even when stopping — log the trigger conditions

---

## Language and Framework Adaptation

IRIS is intentionally agnostic. When encountering a codebase:

**For Fase 1 (detection), look for:**
- Dependency manifests: `package.json`, `requirements.txt`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `pom.xml`, `build.gradle`, `Gemfile`, `composer.json`, `.csproj`
- Entry points by convention: `index.*`, `main.*`, `app.*`, `server.*`, `cmd/`, `src/`
- Test conventions: `__tests__/`, `test/`, `spec/`, `tests/`, files ending in `.test.*`, `.spec.*`, `_test.*`
- Configuration: `.env`, `config.*`, `settings.*`, environment variables

**For Fase 2 (metrics), adapt tooling suggestions:**
- Cyclomatic complexity: radon (Python), lizard (multi-language), SonarQube, ESLint complexity plugin, gocyclo
- Coverage: pytest-cov, jest/vitest --coverage, go test -cover, JaCoCo, SimpleCov
- Linting: language-specific linters but also universal patterns (duplication, dead code)

**For Fase 4 (implementation), follow the existing codebase:**
- Match the existing indentation style (tabs vs. spaces, width)
- Match the existing naming conventions (camelCase, snake_case, PascalCase)
- Match the existing file organization pattern
- Match the existing comment style
- Do not introduce new dependencies without explicit justification

---

## Monitoring Mode

After a cycle where all CRITICAL and IMPROVABLE findings are resolved, IRIS enters monitoring mode:

**Monitoring interval:** Weekly (default), configurable in `IRIS_LOG.md`

**Monitoring actions:**
1. Run Fase 1 (abbreviated — 10 minutes max)
2. Run Fase 2 (metrics only — no full analysis)
3. Compare metrics against last full cycle
4. If degradation detected (any metric crosses threshold): trigger new full cycle from Fase 1
5. If stable: log "healthy" status and schedule next monitoring

**Degradation thresholds (trigger new cycle):**
- Coverage drops below 90% (from target ≥99%)
- Defect Density increases by more than 50% from last cycle
- Complexity Score increases by more than 25% from last cycle
- New CRITICAL finding detected

---

## IRIS_LOG.md Structure

Maintain this file in the project root to track all cycles:

```markdown
# IRIS Log — [Project Name]

## Configuration
- Monitoring interval: weekly
- Coverage target: 99%
- Complexity target: <15
- Defect density target: <1.0

## Cycle History

### Cycle #N — [Date]
- **Trigger:** manual | escalation | scheduled | degradation
- **Source method:** standalone | pdca-t | enterprise-builder | modular-design
- **Duration:** [X hours]
- **Iterations completed:** [N]
- **Files modified:** [N]
- **LOC changed:** +[added] / -[removed]
- **Metrics before:** DD=[X], CC=[X], COV=[X%], TDR=[X%], AHI=[X]
- **Metrics after:** DD=[X], CC=[X], COV=[X%], TDR=[X%], AHI=[X]
- **Critical issues resolved:** [N]
- **Improvable issues resolved:** [N]
- **Remaining issues:** [brief list]
- **Status:** Complete | Monitoring | Handed off to [method]
- **Next trigger:** [condition or date]
```
