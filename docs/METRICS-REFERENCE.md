# IRIS Metrics Reference
## Complete Guide to Quality Measurement

All metric definitions, formulas, thresholds, and measurement tools. This is the authoritative reference for IRIS quality assessment.

---

## Core Metrics (All 5 Required)

### 1. Defect Density

**What it measures:** Concentration of problems (bugs, vulnerabilities, logic errors) per 1,000 lines of code.

**Formula:**
```
Defect Density = (total_defects_found / lines_of_code_analyzed) × 1000
```

**What counts as a defect:**
- CRITICAL findings: security vulnerabilities, crash risks, data loss paths
- IMPROVABLE findings: confirmed bugs, logic errors, significant reliability issues
- Does NOT include: OPTIMIZABLE or COSMETIC findings

**What counts as LOC:**
- Non-blank, non-comment lines of source code
- Excludes: test files, generated code, vendor/dependency directories

**Thresholds:**
| Range | Grade | Action |
|-------|-------|--------|
| < 1.0 | Excellent ✅ | Maintain — top 10% industry |
| 1.0–5.0 | Good ✅ | Continue improvement iterations |
| 5.0–10.0 | Acceptable ⚠️ | Prioritize defect resolution |
| ≥ 10.0 | Poor ❌ | Immediate action required |

**Industry context:** Average software: 15–50 defects/1000 LOC. Production-grade: 1–5.

**Tools:**
- Manual: count findings from Fase 2 analysis
- SonarQube: "Issues" count / KLOC
- CodeClimate: issue density metric
- Any static analyzer with count output

---

### 2. Test Coverage

**What it measures:** Percentage of source code exercised by the automated test suite.

**Formula:**
```
Test Coverage = (lines_covered_by_tests / total_executable_lines) × 100
```

**Coverage types (in order of value):**
| Type | Description | Recommended |
|------|-------------|-------------|
| Branch coverage | Each conditional path taken | Preferred |
| Line coverage | Each executable line runs | Minimum required |
| Function coverage | Each function called | Supplement |
| Path coverage | All execution paths | Impractical for most projects |

**IRIS uses line coverage** as the primary metric because it's universally available. Branch coverage is recorded when available.

**Thresholds:**
| Range | Grade | Action |
|-------|-------|--------|
| ≥ 99% | Target ✅ | Maintain — do not allow decrease |
| 90–99% | High ⚠️ | Improve to reach target |
| 75–90% | Medium ⚠️ | Significant improvement needed |
| < 75% | Low ❌ | Critical — write tests immediately |
| 0% | None ❌ | Emergency — establish test infrastructure first |

**Why 99% and not 100%:**
- Some code paths are genuinely unreachable in tests (defensive error handlers)
- 100% can incentivize testing the wrong things
- 99% covers all meaningful paths while allowing pragmatic exceptions

**Tools by language:**
| Language | Tool | Command |
|----------|------|---------|
| JavaScript/TypeScript | Jest | `jest --coverage` |
| JavaScript/TypeScript | Vitest | `vitest --coverage` |
| Python | pytest-cov | `pytest --cov=src --cov-report=term` |
| Go | go test | `go test ./... -coverprofile=cov.out && go tool cover -func=cov.out` |
| Java | JaCoCo | Gradle: `jacocoTestReport` |
| Ruby | SimpleCov | Add to test helper |
| PHP | PHPUnit | `phpunit --coverage-text` |
| Rust | cargo-tarpaulin | `cargo tarpaulin` |

---

### 3. Complexity Score

**What it measures:** Composite difficulty of code — both the number of paths through it (cyclomatic) and how hard it is for a human to follow (cognitive).

**Formula:**
```
Complexity Score = (cyclomatic_complexity × 0.6) + (cognitive_complexity × 0.4)
```

Applied per function/method. Report the **average across the codebase** and the **maximum** (worst function).

**Cyclomatic Complexity (CC):**
```
CC = 1 + number_of_decision_points

Decision points: if, else if, while, for, foreach, case, catch, &&, ||, ?: (ternary)
```

| CC Range | Meaning |
|----------|---------|
| 1–10 | Simple — low risk |
| 11–20 | Moderate — some risk |
| 21–50 | Complex — high risk |
| > 50 | Unmaintainable — critical |

**Cognitive Complexity:**
Adds nesting penalties: each additional level of nesting adds +1 to the structure's weight.

```
Base: +1 for each control structure (if, loop, switch, catch)
Nesting penalty: +1 per nesting level depth beyond first
Recursion: +1 for recursive calls
```

| Cognitive Range | Meaning |
|-----------------|---------|
| 0–15 | Easy to read |
| 16–30 | Moderate |
| > 30 | Hard to understand |

**Composite Thresholds (Complexity Score):**
| Range | Grade | Action |
|-------|-------|--------|
| < 12 | Excellent ✅ | No action needed |
| 12–20 | Good ✅ | Refactor when next touching |
| 20–35 | Acceptable ⚠️ | Schedule refactoring iteration |
| ≥ 35 | Poor ❌ | Immediate refactoring required |

**Tools:**
| Language | Tool |
|----------|------|
| Python | `radon cc -a src/` |
| Multi-language | `lizard src/` |
| JavaScript/TypeScript | ESLint `complexity` rule |
| Go | `gocyclo ./...` |
| Java | SonarQube, PMD |
| General | SonarQube (all languages) |

---

### 4. Technical Debt Ratio

**What it measures:** How much of the codebase investment has been "borrowed" from future maintenance. Expressed as a ratio of fix cost to development cost.

**Formula:**
```
Tech Debt Ratio = (total_remediation_hours / total_development_hours) × 100
```

**Estimating remediation hours:**
- For each CRITICAL finding: estimate hours to fix (typically 1–8h)
- For each IMPROVABLE finding: estimate hours to fix (typically 0.5–4h)
- Sum all fix estimates

**Estimating development hours:**
```
development_hours = total_LOC / 75

(Industry average: 75 LOC per productive development hour)
Adjust for your team: faster teams → use 100; slower → use 50
```

**Thresholds:**
| Range | Grade | Action |
|-------|-------|--------|
| < 5% | Healthy ✅ | Sustainable velocity |
| 5–10% | Manageable ⚠️ | Schedule debt repayment in roadmap |
| 10–20% | Critical ⚠️ | Dedicate sprint to debt reduction |
| ≥ 20% | Unstable ❌ | Consider architectural reset for affected modules |

**Industry context:** SonarQube uses a similar metric. "A" rating = <5%, "E" = >50%.

---

### 5. Architectural Health Index (AHI)

**What it measures:** Structural quality of the codebase across four dimensions. Scale 0–100 (higher is better).

**Formula:**
```
AHI = (coupling_score + cohesion_score + solid_score + duplication_score) / 4
```

**Coupling Score (25%):**
```
coupling_score = 100 - (average_cross_module_imports × 5), minimum 0

average_cross_module_imports = sum(efferent_coupling) / module_count
```
Target: low efferent coupling per module (each module depends on few others).

**Cohesion Score (25%):**
```
cohesion_score = (single_responsibility_modules / total_modules) × 100
```
A module passes if it can be described in one sentence without "and".

**SOLID Score (25%):**
```
solid_score = 100 - (solid_violations_count × 10), minimum 0
```
Each SOLID principle violation costs 10 points.

**Duplication Score (25%):**
```
duplication_score = 100 - (duplicated_code_percentage × 2), minimum 0

duplicated_code_percentage = (duplicated_LOC / total_LOC) × 100
```
"Duplicated": identical or near-identical blocks of ≥6 lines appearing ≥2 times.

**AHI Thresholds:**
| Range | Grade | Action |
|-------|-------|--------|
| ≥ 90 | Excellent ✅ | Minimal intervention needed |
| 75–90 | Good ✅ | Minor improvements in next cycles |
| 60–75 | Needs Attention ⚠️ | Schedule architectural iteration |
| < 60 | Critical ❌ | Architecture blocks development velocity |

---

## Derived Metrics (Informational)

### Coverage Gap
```
Coverage Gap = 99 - test_coverage
```
Directly tells you: how many more percentage points until the target.
- Gap = 0: target met
- Gap = 12: 12 percentage points of code to cover

### Health Delta (per cycle)
For each metric, calculate the improvement from the previous cycle:
```
delta = metric_after - metric_before  (for coverage and AHI: higher is better)
delta = metric_before - metric_after  (for density, complexity, debt: lower is better)
```
A positive delta always means improvement.

---

## Measurement Frequency

| Metric | When to Measure |
|--------|----------------|
| Defect Density | Per iteration (Fase 4 end) |
| Test Coverage | Per iteration (after running tests) |
| Coverage Gap | Per iteration (derived from coverage) |
| Complexity Score | Per cycle (Fase 2 and Fase 5) |
| Tech Debt Ratio | Per cycle (Fase 2 and Fase 5) |
| Architectural Health Index | Per cycle (Fase 2 and Fase 5) |

In monitoring mode:
- Coverage and Defect Density: every monitoring check
- All 5 metrics: only when full cycle triggered

---

## Composite Health Report

When presenting an overall health summary, rate each metric and average:

| Rating | Score |
|--------|-------|
| Excellent | 4 |
| Good | 3 |
| Acceptable | 2 |
| Poor | 1 |

```
Composite Health = average(rating_1 + rating_2 + rating_3 + rating_4 + rating_5) / 5
```

| Composite Score | Label |
|----------------|-------|
| 3.5–4.0 | Elite — top 5% of codebases |
| 2.5–3.4 | Professional — production-ready |
| 1.5–2.4 | Developing — acceptable with active improvement plan |
| 1.0–1.4 | Critical — significant investment required |

---

## Reporting Template

Use this in Fase 2 and Fase 5 reports:

```markdown
### Metrics Dashboard

| Metric | Value | Target | Grade | vs. Last Cycle |
|--------|-------|--------|-------|----------------|
| Defect Density | 3.2 | <1.0 | ⚠️ Acceptable | — (first cycle) |
| Test Coverage | 72% | ≥99% | ❌ Low | — |
| Complexity Score | 18.4 | <12 | ⚠️ Good | — |
| Tech Debt Ratio | 8.1% | <5% | ⚠️ Manageable | — |
| Arch Health Index | 68 | ≥90 | ⚠️ Attention | — |

**Composite Health Score:** 2.0 / 4.0 — Developing
```
