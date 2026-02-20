# IRIS Fase 5: SPIN — Verification & Cycle Closure

## Objective

Verify that all improvements held, document what was learned, update the cycle log, and either close the cycle or prepare the next one. This phase also generates the `IRIS_OUTPUT.json` handoff file when returning control to another method.

## Inputs

- Fase 4 Implementation Log (all changes made, test results)
- Fase 2 baseline metrics (to compare against)
- Fase 3 success metrics targets (to evaluate against)
- Current codebase state (post all iterations)

## Step-by-Step Execution

### Step 5.1 — Full Regression Verification

Run the complete test suite one final time on the full codebase (not just modified modules):

```bash
# Run with coverage to capture final state
npm test -- --coverage       # Jest
pytest --cov=src             # Pytest
go test ./... -coverprofile  # Go
./gradlew test jacocoTestReport  # Gradle
```

**Check for regressions:**
- Any test that was passing before Fase 4 must still pass
- If any previously-passing test now fails → regression detected
  - If regression is in modified code → fix immediately
  - If regression is in unmodified code → unusual, investigate dependency change
  - If cannot fix within this cycle → document as a new finding for next cycle AND revert the change that caused it

### Step 5.2 — Metrics Calculation (Post-Cycle)

Recalculate all 5 metrics using the same methods as Fase 2:

| Metric | Formula | Note |
|--------|---------|------|
| Defect Density | (new_findings / LOC) × 1000 | Re-run static analysis; count only new findings |
| Test Coverage | (covered_lines / total) × 100 | From coverage report |
| Complexity Score | (cyclomatic × 0.6) + (cognitive × 0.4) | Re-estimate for changed modules |
| Tech Debt Ratio | (remaining_fix_hours / dev_hours) × 100 | Re-estimate remaining issues only |
| Arch Health Index | avg(coupling, cohesion, solid, duplication) | Re-evaluate changed modules |

**Compute deltas** (after − before for coverage/AHI; before − after for others, higher = improved):
```
Coverage delta = coverage_after - coverage_before  (positive = improved)
Defect density delta = defect_density_before - defect_density_after  (positive = improved)
Complexity delta = complexity_before - complexity_after  (positive = improved)
Tech debt delta = tech_debt_before - tech_debt_after  (positive = improved)
AHI delta = AHI_after - AHI_before  (positive = improved)
```

### Step 5.3 — Self-Review Checklist

For every change made during Fase 4, review against these questions:

1. **Solves the problem:** Does the change address the root cause identified in Fase 2, not just the symptom?
2. **Simplicity:** Is the resulting code simpler than before? (fewer paths, less nesting, shorter functions)
3. **Test quality:** Are the tests asserting correct *behavior*, not just "it ran without crashing"?
4. **Documentation:** Do comments explain *why* (non-obvious decisions), not *what* (readable from code)?
5. **Convention adherence:** Does the change follow the codebase's existing patterns?
6. **Side effects:** Could this change affect any code path not covered by tests?

Flag any answer that is "no" as a finding for the next cycle.

### Step 5.4 — Lessons Learned

Document explicitly for each category (not as generic platitudes — specific to this cycle):

```markdown
### Lessons Learned — Cycle #[N]

#### What worked well
- [Specific technique, approach, or sequence that produced good results]
- [Example: "Characterization tests before refactoring let us move confidently"]

#### Harder than estimated
- [What took longer and why]
- [Example: "Mocking the database layer required 2h extra due to factory pattern"]
- [Adjustment: how to estimate this better next cycle]

#### New patterns discovered
- Good patterns: [naming conventions, structural approaches found in the codebase worth preserving]
- Anti-patterns: [things found that should never be introduced again]

#### Process improvements
- [What to do differently in the next IRIS cycle]
- [Example: "In this codebase, check for database query patterns first in Fase 2 — they were the main issue"]
```

### Step 5.5 — IRIS_LOG.md Update

Write or update the `IRIS_LOG.md` file in the project root:

```markdown
## Cycle #[N] — [Date]

| Field | Value |
|-------|-------|
| Trigger | [manual / escalation / scheduled / degradation] |
| Source method | [standalone / pdca-t / enterprise-builder / modular-design] |
| Duration | [X hours] |
| Iterations completed | [N of N planned] |
| Files analyzed | [N] |
| Files modified | [N] |
| LOC changed | +[added] / -[removed] |

### Metrics
| Metric | Before | After | Delta | Target | Status |
|--------|--------|-------|-------|--------|--------|
| Defect Density | [X] | [Y] | [+/-Z] | <1.0 | ✅/⚠️/❌ |
| Test Coverage | [X%] | [Y%] | [+Z%] | ≥99% | ✅/⚠️/❌ |
| Complexity Score | [X] | [Y] | [+/-Z] | <12 | ✅/⚠️/❌ |
| Tech Debt Ratio | [X%] | [Y%] | [-Z%] | <5% | ✅/⚠️/❌ |
| Arch Health Index | [X] | [Y] | [+Z] | ≥90 | ✅/⚠️/❌ |

### Improvements Made
- [IMP-0001]: [brief description] — [files affected]
- [IMP-0002]: [brief description] — [files affected]

### Remaining Issues
- [ID] [SEVERITY]: [brief description] — [deferred to next cycle / monitoring]

### Status
[Complete | Monitoring | Handed off to [method]]

### Next Trigger
[Scheduled: [date] | Condition: [metric threshold] | Immediate: [remaining critical issues]]
```

### Step 5.6 — Handoff Preparation (when integrated)

If `source_method` was not `standalone` or `manual`, generate `IRIS_OUTPUT.json`:

Read `core/schemas/handoff-output.json` schema and populate all required fields.

**For PDCA-T handoff:**
```json
{
  "target_method": "pdca-t",
  "next_action": "handoff-to-pdca-t",
  "pdca_t_handoff": {
    "refactored_modules": ["list of modules IRIS made testable"],
    "new_interfaces": ["list of new abstractions introduced"],
    "expected_coverage_after_pdca": 99
  },
  "handoff_context": {
    "focus_areas": ["what PDCA-T should target now"],
    "avoided_pitfalls": ["approaches that failed during IRIS cycle"],
    "urgent_attention": []
  }
}
```

**For Enterprise Builder handoff:**
```json
{
  "target_method": "enterprise-builder",
  "next_action": "monitor",
  "enterprise_builder_feedback": {
    "nfr_adjustments_suggested": ["list if any"],
    "new_risks_identified": ["risks IRIS found not in original risk matrix"],
    "adr_updates_recommended": ["ADRs to revisit"]
  }
}
```

**For Modular Design handoff:**
```json
{
  "target_method": "modular-design",
  "next_action": "handoff-to-modular-design",
  "modular_design_feedback": {
    "resolved_violations": ["violations fixed"],
    "new_pack_suggestions": ["new packs that would improve structure"],
    "core_contamination_resolved": ["domain logic moved out of Core"]
  }
}
```

### Step 5.7 — Next Cycle Planning

Based on remaining issues and metrics:

**If CRITICAL or IMPROVABLE findings remain:**
- Next cycle is IMMEDIATE (or next session)
- Focus: the remaining highest-priority findings
- Note in IRIS_LOG.md: "Cycle #[N+1] should start from Fase 2 (metrics already known) or Fase 3 (plan the remaining issues)"

**If only OPTIMIZABLE or COSMETIC findings remain:**
- Enter monitoring mode
- Next cycle is SCHEDULED
- Frequency: default weekly, adjust based on codebase activity

**If all targets met:**
- Monitoring mode active
- Define degradation thresholds in IRIS_LOG.md
- State the specific conditions that will trigger a new full cycle

## Output Format

```markdown
## IRIS Fase 5 — Verification Report: Cycle #[N]
**Date:** [date] | **Cycle duration:** [total hours from Fase 1]

---

### Regression Verification
- Tests run: [N]
- Passed: [N] (100%)
- Failed: 0
- Regressions detected: None ✅ | [N regressions — see below] ❌

### Metrics Evolution
| Metric | Before | After | Delta | Target | Status |
|--------|--------|-------|-------|--------|--------|
| Defect Density | | | | <1.0 | |
| Test Coverage | | | | ≥99% | |
| Complexity Score | | | | <12 | |
| Tech Debt Ratio | | | | <5% | |
| Arch Health Index | | | | ≥90 | |

**Net improvement:** [N metrics improved / N at target / N still below target]

### Quality Gate
- [ ] All original functionality preserved (zero regressions)
- [ ] All planned iterations completed
- [ ] All DoD criteria verified
- [ ] IRIS_LOG.md updated
- [ ] Lessons documented

### Self-Review Findings
[Any "no" answers from Step 5.3, logged as new findings for next cycle]

### Lessons Learned
[From Step 5.4]

### Handoff
[If applicable: IRIS_OUTPUT.json generated for [target method]]
[If standalone: cycle complete]

### Remaining Issues
| ID | Severity | Description | Next Cycle Priority |
|----|----------|-------------|---------------------|

### Cycle Status
**[Complete / Monitoring / Handed off to [method]]**

### Next IRIS Cycle
- **When:** [date / condition / immediately]
- **Starting phase:** [Fase 1 / Fase 2 (metrics known) / Fase 3 (plan remaining)]
- **Focus:** [description]

---
**IRIS Cycle #[N] — CLOSED** ✅
```

## Monitoring Mode Activation

When entering monitoring mode (all CRITICAL + IMPROVABLE resolved):

```markdown
### Monitoring Mode Active — IRIS Cycle #[N]

**Configuration:**
- Check frequency: Weekly (every [day of week])
- Metrics tracked: Test Coverage, Defect Density, Complexity Score
- Degradation thresholds (triggers new full cycle):
  - Test coverage drops below [N]%  (current: [X]%, threshold: [X-9]%)
  - Defect density exceeds [X × 1.5]  (current: [X])
  - Complexity score exceeds [X × 1.25]  (current: [X])
  - Any new CRITICAL finding detected

**Monitoring action (weekly abbreviated cycle):**
1. Run Fase 1 structure check (10 min)
2. Run test suite and extract coverage number
3. Run static analysis tool and count new findings
4. Compare against thresholds
5. If all clear: log "healthy" status
6. If threshold crossed: trigger new full cycle from Fase 1
```
