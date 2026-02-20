# IRIS Fase 2: REVIEW — Quality Assessment

## Objective

Systematically evaluate the current state of the codebase with quantified metrics. Every finding must reference a specific file and line range. Every metric must be calculated with the formula from `core/schemas/metrics.json`.

## Inputs

- Fase 1 Report (repository profile, tech stack, entry points, directory structure)
- Source code files (read via file tools — never assume content)
- Test files (if any exist)
- CI/CD configuration (for coverage reporting clues)

## Parallel Analysis Principle (v2.1)

Analyze each of the 5 dimensions **independently**, as if you have no knowledge of what the other dimensions found. Record findings per dimension in separate lists. Only in Step 2.7 (Synthesis) do you cross-reference and deduplicate.

**Why:** If you know security found a God class, you may unconsciously elevate its severity in the architecture dimension too. Analyzing independently and synthesizing afterward produces cleaner, non-contaminated findings and avoids double-counting in metrics.

## Analysis Strategy by Codebase Size

| Size | Strategy |
|------|----------|
| Simple (<1K LOC) | Analyze every file completely |
| Medium (1–10K LOC) | Analyze every file; note which are highest priority |
| Large (10–100K LOC) | Analyze entry points, domain core, and highest-risk modules fully; sample 20% of remaining |
| Enterprise (>100K LOC) | Define analysis scope explicitly; document sampling strategy |

**For sampled codebases:** State in the report which modules were fully analyzed and which were sampled. Metrics apply only to analyzed scope; extrapolate cautiously.

## Step-by-Step Execution

### Step 2.1 — Static Code Analysis

For each source file (prioritized by: entry points first, then domain logic, then infrastructure):

**Read the full file before analyzing it.**

Check for:

#### Dead Code
- Functions or methods never called (search for their names across the codebase)
- Imported modules that are never referenced after the import
- Variables assigned but never read
- Commented-out code blocks (potential dead code or forgotten work)

#### Hardcoded Values
- Connection strings, URLs, API endpoints in source code
- Numeric magic values without named constants
- File paths hardcoded as absolute paths
- Credentials, tokens, or keys in any form

#### Exception Handling Quality
- Broad catch-all handlers: `except Exception:`, `catch (e) {}`, `catch (Exception e)`, `recover()` without type checking
- Swallowed exceptions (caught but not logged and not re-thrown)
- Exceptions used for control flow (non-exceptional paths)

#### Code Duplication
- Identical or near-identical blocks of 6+ lines appearing in multiple places
- Copy-pasted logic with only variable name changes

#### Logging Quality
- `print()`, `console.log()`, `fmt.Println()` in production code paths (not test files)
- Sensitive data (passwords, tokens, user PII) appearing in log statements
- Unstructured log messages where structured logging exists in the project

### Step 2.2 — Security Assessment

#### Input Validation Scan
For each external boundary (HTTP endpoint, CLI argument, file read, environment variable, database query):
- Is the input validated before use?
- Is the input type-checked?
- Are boundary values handled?

#### Secrets and Credentials
Search for patterns:
- `password`, `secret`, `token`, `api_key`, `apikey`, `auth`, `credential` assigned to string literals
- Base64-encoded strings in source code that look like credentials
- `.env` files committed to the repository (check `.gitignore`)

#### SQL and Injection Risks
- String concatenation to build SQL queries
- `eval()`, `exec()`, `subprocess` with user-controlled input
- Unsafe deserialization patterns
- Path traversal risks (user input used in file operations)

#### Dependency Age (Rough Check)
- Note any dependencies that appear significantly outdated based on version numbers
- Flag major version mismatches (e.g., using v1.x when v3.x exists for critical security libraries)

### Step 2.3 — Architecture Assessment

#### Coupling Analysis
Count cross-module imports. For each module:
- How many other modules does it import? (efferent coupling)
- How many modules import it? (afferent coupling)
- Flag any module with efferent coupling > 10 as high-coupling

#### Single Responsibility Check
For each class or module, ask: "Can this be described with one sentence that doesn't use 'and'?"
- If it cannot → SRP violation
- Examples: "UserService that handles authentication AND sends email AND manages profile" → violation

#### Circular Dependency Detection
Trace import chains. Flag any cycle:
- Module A imports B, B imports C, C imports A → circular

#### Layer Violations
Identify the architecture layers (if any: API → Application → Domain → Infrastructure).
Check for:
- Domain logic in API/route handlers
- Infrastructure concerns (database queries) in domain/business logic
- UI rendering logic mixed with business calculations

### Step 2.4 — Test Coverage Audit

#### Test Infrastructure Check
- Does a test framework exist? (detected in Fase 1)
- Are there test files? (search for `.test.*`, `.spec.*`, `_test.*`, `test_*.*`)
- Is there a coverage configuration? (`jest.config.*`, `pytest.ini`, `.coveragerc`, `codecov.yml`)
- Are there CI steps that run tests?

#### Module Coverage Mapping
For each source module, check if a corresponding test file exists:
- `src/auth/service.js` → `src/auth/service.test.js` or `tests/auth/test_service.py`
- Document which modules have tests and which do not

#### Test Quality Indicators (read test files)
- Assertions present? (not just "doesn't crash")
- Edge cases visible? (empty input, null, max/min values, error conditions)
- Mocked dependencies? (tests are isolated, not integration tests labelled as unit tests)
- Tests run deterministically? (no random seeds, no time-dependent assertions without mocking)

#### Estimated Coverage
Without running the test suite:
- Modules with no test files: 0% coverage
- Modules with test files: estimate based on test file size vs. source file size
- Report as range (e.g., "estimated 60–75%") not false precision

### Step 2.5 — Performance Indicators (Static Only)

Flag these patterns without executing code:
- **N+1 risk:** Database query call inside a loop body
- **Missing pagination:** List/query operations with no limit/offset/page parameter
- **Blocking I/O in async:** `await` on CPU-bound operations, blocking calls in async functions
- **Memory allocation in loops:** Large object creation inside tight loops
- **Nested loops without early exit:** O(n²) or worse patterns on unbounded collections

### Step 2.6 — Memory Tagging

Before synthesis, apply IRIS_MEMORY.json tags to relevant findings:

- If a finding's file/scope matches an `intentional_pattern.scope`:
  → Tag the finding as `[INTENTIONAL — IP-NNN]`
  → Do NOT categorize as CRITICAL or IMPROVABLE
  → Use category NOTED — it appears in the report for awareness only

- If a finding would require violating an `architectural_constraint`:
  → Tag as `[CONSTRAINED — AC-NNN]`
  → Note the constraint text next to the finding
  → Do NOT propose a fix in IDEATE

This tagging happens **after** independent analysis of each dimension but **before** the synthesis step. Each dimension should have been analyzed as if memory did not exist; the tags are applied now.

---

### Step 2.7 — Synthesis (Parallel → Unified)

After all 5 dimensions have been analyzed independently:

**2.7.1 — Deduplication:**
Identify findings that appear in more than one dimension:
- Example: "UserService has 18 public methods" may appear in Static Analysis (dead code risk), Architecture (SRP violation), and Security (overly large attack surface)
- For each duplicated finding: keep ONE entry with the highest severity across dimensions
- Note in the finding description which dimensions detected it: `[detected by: static, architecture, security]`

**2.7.2 — Severity Resolution:**
When two dimensions assign different severities to the same finding, apply this precedence:
```
Security > Architecture > Performance > Static Analysis > Test Coverage
```
Example: Architecture rates "missing input validation" as IMPROVABLE. Security rates it as CRITICAL. → Use CRITICAL.

**2.7.3 — Cross-dimension findings (new findings from combinations):**
Sometimes combining two dimension findings reveals a third that neither found alone:
- Static Analysis finds hardcoded config values AND Test Coverage finds no config tests → combined finding: "Configuration is untestable as currently structured" (IMPROVABLE)
- Architecture finds high coupling AND Performance finds N+1 in that module → combined: "Coupling is likely the root cause of N+1 — fix coupling to enable query consolidation"

Document these as cross-dimension findings with both parent IDs noted.

**2.7.4 — Unified finding IDs:**
After deduplication, assign clean final IDs:
- C-NNN for CRITICAL
- I-NNN for IMPROVABLE
- O-NNN for OPTIMIZABLE
- K-NNN for COSMETIC
- NT-NNN for NOTED (intentional patterns)
- CN-NNN for CONSTRAINED

---

### Step 2.8 — Finding Categorization

Classify every finding (after Synthesis):
- **CRITICAL:** Direct security vulnerability (injection, auth bypass, exposed secrets), data loss risk, application crash, compliance violation
- **IMPROVABLE:** Confirmed bug, significant coupling issue, missing tests on critical paths, performance bottleneck
- **OPTIMIZABLE:** Refactoring opportunity, minor complexity reduction, test quality improvement
- **COSMETIC:** Naming convention, formatting, style inconsistency

---

### Step 2.9 — Metrics Calculation

Calculate each metric using the formulas from `core/schemas/metrics.json`:

#### Defect Density
```
total_findings = count(CRITICAL) + count(IMPROVABLE)
LOC_analyzed = count of non-blank, non-comment lines in analyzed files
Defect Density = (total_findings / LOC_analyzed) × 1000
```

#### Complexity Score
Estimate cyclomatic complexity for the most complex 10 functions:
- Count decision points (if/else/switch cases/for/while/catch/&&/||/ternary)
- Average across those 10 + the codebase average if tools are available
- Estimate cognitive complexity: add nesting depth penalty
- Apply formula: `(cyclomatic × 0.6) + (cognitive × 0.4)`

#### Coverage Gap
```
Coverage Gap = 99 - estimated_test_coverage
```

#### Tech Debt Ratio
```
remediation_hours = sum of estimated fix time for all CRITICAL + IMPROVABLE findings
development_hours = LOC_total / 75  (rough estimate: 75 LOC per development hour)
Tech Debt Ratio = (remediation_hours / development_hours) × 100
```

#### Architectural Health Index
```
coupling_score = 100 - (avg_cross_module_imports × 5), min 0
cohesion_score = (single_responsibility_modules / total_modules) × 100
solid_score = 100 - (solid_violations_count × 10), min 0
duplication_score = 100 - (estimated_duplication_% × 2), min 0
AHI = (coupling_score + cohesion_score + solid_score + duplication_score) / 4
```

## Output Format

```markdown
## IRIS Fase 2 Report — Quality Assessment
**Cycle:** #[N] | **Analyzed:** [N] files | **LOC analyzed:** [N]

---

### Executive Summary
| Field | Value |
|-------|-------|
| Overall Health Grade | A / B / C / D / F |
| Critical findings | [N] |
| Improvable findings | [N] |
| Optimizable findings | [N] |
| Cosmetic findings | [N] |
| Noted (intentional) | [N] |
| Constrained (no-fix) | [N] |
| Test coverage estimate | [N%] |
| Dimensions analyzed | 5 (parallel) — synthesis applied |

---

### Critical Findings (immediate action required)
| ID | File | Lines | Issue | Risk | Root Cause |
|----|------|-------|-------|------|------------|
| C-001 | [path] | [N–M] | [description] | [impact] | [why] |

### Improvable Findings
| ID | File | Lines | Issue | Effort | Impact |
|----|------|-------|-------|--------|--------|
| I-001 | [path] | [N–M] | [description] | [Xh] | [impact] |

### Optimizable Findings
| ID | File | Issue | Effort |
|----|------|-------|--------|

### Cosmetic Findings
[Brief list — no table needed]

---

### Metrics Dashboard
| Metric | Value | Threshold | Grade | Trend |
|--------|-------|-----------|-------|-------|
| Defect Density | [X.X] | <1.0 | ✅/⚠️/❌ | [↑↓→ vs last cycle] |
| Test Coverage | [XX%] | ≥99% | ✅/⚠️/❌ | [↑↓→] |
| Complexity Score | [X.X] | <12 | ✅/⚠️/❌ | [↑↓→] |
| Tech Debt Ratio | [X.X%] | <5% | ✅/⚠️/❌ | [↑↓→] |
| Arch Health Index | [XX] | ≥90 | ✅/⚠️/❌ | [↑↓→] |

*Trend column: ↑ improved, ↓ worsened, → unchanged vs. last cycle. N/A for first cycle.*

---

### Root Cause Analysis (Critical findings only)
**C-001 — [title]**
- Why it exists: [explanation]
- Contributing factors: [list]
- Prevention strategy: [how to avoid in future]

---

### Recommendations (priority order)
1. [Specific recommendation] — addresses [C-001, I-003] — estimated impact: [high/medium/low]
2. ...

---

### Noted Findings (from IRIS_MEMORY.json — intentional patterns)
| ID | File | Pattern | Memory Entry | Revisit |
|----|------|---------|-------------|---------|
| NT-001 | [path] | [pattern] | IP-NNN | [revisit_on or —] |

### Constrained Findings (from IRIS_MEMORY.json — cannot be fixed)
| ID | File | Finding | Blocked by | Constraint |
|----|------|---------|-----------|-----------|
| CN-001 | [path] | [finding] | AC-NNN | [constraint text] |

### Synthesis Notes
- Deduplicated findings: [N] (reduced from [M] raw findings across all dimensions)
- Severity upgrades applied: [list, e.g., "I-003 upgraded from IMPROVABLE to CRITICAL by security dimension"]
- Cross-dimension findings: [N]

### Fase 2 Checklist
- [ ] All source modules analyzed (or sampling documented) — each dimension analyzed independently
- [ ] Synthesis complete — findings deduplicated, severity conflicts resolved
- [ ] Memory tagging applied (IRIS_MEMORY.json) — noted and constrained findings tagged
- [ ] All 5 metrics calculated from deduplicated findings
- [ ] All CRITICAL findings have root causes
- [ ] All findings categorized (C / I / O / K / NT / CN)
- [ ] Security scan completed
- [ ] Architecture assessment done
- [ ] Test coverage audit done
- [ ] Performance indicators evaluated
- [ ] Metrics compared against thresholds
- [ ] Recommendations ordered by priority

**→ Ready for Fase 3: IDEATE** ✅ / **→ Cannot proceed: [missing items]** ❌
```

## Pack Integration

If pack modifiers were specified, integrate additional analysis:
- `--security`: run `packs/security-pack/SECURITY-PACK.md` analysis and append findings to Section 2.2
- `--performance`: run `packs/performance-pack/PERFORMANCE-PACK.md` and append to Section 2.5
- `--architecture`: run `packs/architecture-pack/ARCHITECTURE-PACK.md` and expand Section 2.3
