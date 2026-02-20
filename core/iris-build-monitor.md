# IRIS Build Monitor Specification v2.1
# Delta Pipeline — Lightweight Continuous Monitoring

## Purpose

The Build Monitor is the lightweight alternative to a full IRIS cycle. It answers one question: **"Did this specific change break anything or degrade quality?"** — without re-analyzing the entire codebase.

A full IRIS cycle is expensive (it reads everything, recalculates all metrics, produces a full report). The Build Monitor runs in minutes, not hours, by operating only on the **diff** between the current state and the last verified baseline.

---

## Two Activation Modes

| Command | What runs | Cost |
|---------|-----------|------|
| `/iris:monitor:delta` | Stages 1 + 2 only — diff + impact scope + affected tests | Fast (minutes) |
| `/iris:monitor` | Full pipeline Stages 1 + 2 + 3 — includes metrics delta | Medium (10–20 min) |

Use `/iris:monitor:delta` after every commit during active development.
Use `/iris:monitor` on a scheduled basis (daily/weekly) or after significant feature additions.

---

## Pipeline Architecture

```
TRIGGER
  ├── Manual: /iris:monitor or /iris:monitor:delta
  ├── Scheduled: defined in IRIS_LOG.md monitoring section
  └── CI webhook: if CI/CD integration configured
         │
         ▼
┌─────────────────────────────────────────────────────────────┐
│  STAGE 1 — DELTA EXTRACTOR                                  │
│                                                             │
│  1.1 Read IRIS_LOG.md → find last_successful_build ref      │
│      (last commit hash or tag where all metrics were OK)   │
│      If missing, corrupted, or field absent: use            │
│      git log -1 --format=%H as baseline (HEAD as ref)       │
│                                                             │
│  1.2 Validate last_ref BEFORE any git command:             │
│      last_ref MUST match ^[a-f0-9]{7,40}$ (git hash)        │
│      or ^[a-zA-Z0-9/_.-]+$ (tag name, no shell metachars)   │
│      If invalid: abort with error, do not run git diff      │
│                                                             │
│  1.3 Compute diff from that ref to HEAD:                    │
│      git diff <validated_last_ref>..HEAD --name-only        │
│      git diff <validated_last_ref>..HEAD --stat            │
│      (pass ref as single argument, never interpolate shell)│
│                                                             │
│  1.4 Produce: DeltaReport {                                 │
│        changed_files: string[]                              │
│        commit_range: [last_ref, HEAD]                       │
│        loc_added: number                                    │
│        loc_removed: number                                  │
│        net_loc_delta: number                                │
│        new_dependencies: string[]  (if manifest changed)   │
│      }                                                      │
│                                                             │
│  Gate: if changed_files is empty → "No changes since last  │
│  build. Nothing to analyze." → STOP (healthy).             │
└─────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────┐
│  STAGE 2 — IMPACT SCOPE                                     │
│                                                             │
│  2.1 For each changed_file:                                 │
│      → If file still exists: find first-level importers     │
│      → If file was deleted (in diff): skip importer search, │
│        but include it in impact_scope; find tests that      │
│        imported it (from test dir or by name convention)   │
│      → Build: impact_scope = changed_files + direct         │
│        importers (not transitive — first level only)        │
│                                                             │
│  2.2 Find test files that cover the impact_scope:          │
│      → test files co-located with changed files            │
│      → test files that import changed files directly        │
│                                                             │
│  2.3 Run ONLY those affected tests (not full suite):       │
│      → Record: tests_run, tests_passed, tests_failed        │
│                                                             │
│  2.4 Classify result:                                       │
│      ├── ERROR: tests_failed > 0                           │
│      ├── REGRESSION: previously-passing test now fails     │
│      │   (check against last IRIS_LOG.md test record)      │
│      └── OK: all affected tests pass                        │
└─────────────────────────────────────────────────────────────┘
         │
         ├──► ERROR PATH
         │    1. Identify failing tests and their assertions
         │    2. Auto-fix attempt: analyze the failing assertion
         │       and the diff that caused it
         │    3. Generate fix. Count LOC of the fix (lines added/changed).
         │       If LOC > 50: ABORT auto-fix, escalate to human with message
         │       "Fix exceeds 50 LOC budget — manual review required."
         │    4. If LOC ≤ 50: apply minimal fix
         │    5. Re-run tests
         │    6. If pass → stage changes, DISPLAY fix to user; do NOT auto-commit.
         │       Ask user: "Auto-fix successful. Review and commit manually."
         │       Update IRIS_LOG.md only after user confirms.
         │    7. If still fail after attempt 2 → escalate to human
         │       with: failing test, diff, attempted fix, error message
         │    8. Maximum 3 auto-fix attempts → after that: ESCALATE
         │
         ├──► REGRESSION PATH
         │    1. Determine: is the test wrong, or did the code regress?
         │       → If the test was testing the OLD behavior and the change
         │          is intentional → generate test update. Count LOC of the update.
         │          If LOC > 20: ABORT auto-update, escalate with message
         │          "Test update exceeds 20 LOC budget — manual review required."
         │          If LOC ≤ 20: apply update
         │       → If the code broke something that should still work
         │          → revert the specific change, notify user
         │    2. If ambiguous → surface to user with full context:
         │          [test name] [old behavior] [new behavior] [diff]
         │          User decides: update test OR revert code
         │
         └──► OK → STAGE 3 (only for /iris:monitor, not :delta)
         │
         ▼
┌─────────────────────────────────────────────────────────────┐
│  STAGE 3 — METRICS DELTA  (/iris:monitor only)             │
│                                                             │
│  3.1 Recalculate metrics ONLY for changed modules:         │
│      → Defect Density: re-count findings in changed files  │
│      → Test Coverage: re-run with coverage for scope only  │
│      → Complexity Score: re-calculate for changed functions │
│      (Tech Debt Ratio and AHI only update in full cycles)  │
│                                                             │
│  3.2 Compare against IRIS_LOG.md baseline:                 │
│      delta = current_value - baseline_value                │
│                                                             │
│  3.3 Classify:                                             │
│      IMPROVED: delta is positive (coverage up, density down)│
│      STABLE: delta = 0                                      │
│      DEGRADED: delta is negative (coverage down, etc.)     │
│                                                             │
│  3.4 Actions by classification:                            │
│      IMPROVED → update partial baseline in IRIS_LOG.md     │
│                  log "improvement detected" entry           │
│      STABLE   → log "healthy" entry                        │
│      DEGRADED → generate degradation report:               │
│                  which metric, by how much, which files     │
│                  propose fix via /iris:plan                 │
└─────────────────────────────────────────────────────────────┘
```

---

## Exit Conditions (Critical — Previously Missing)

These conditions control when the monitor stops cycling and escalates to a human. Without them, the monitor can run infinitely or generate noise.

### Convergence (stop — healthy)
```
Condition: delta(cycle_N vs cycle_N-1) shows <5% LOC change AND all metrics stable

Definition of "all metrics stable":
  - |coverage_delta| < 0.5 percentage points
  - |defect_density_delta| < 0.1 per 1K LOC
  - |complexity_delta| < 0.5
  - No new CRITICAL or IMPROVABLE findings in changed files

Action: Log "Convergence reached — system stable" in IRIS_LOG.md
        Set monitoring interval to 2× current frequency
        Do NOT trigger new full cycle
```

### Persistent Error (stop — escalate)
```
Condition: Same error (same test, same assertion failure) persists across 3 consecutive builds
Action: STOP auto-fix attempts
        Generate escalation report:
          - Error history: builds [N], [N-1], [N-2] — all same failure
          - Diff that introduced it (build [N-3])
          - All auto-fix attempts made and why they failed
          - Hypothesis: [root cause guess based on diff analysis]
        Flag for human review — do not attempt again until human intervenes
```

### Undo Conflict Detection (stop — human conflict)
```
Condition: Current diff REVERTS a change made by IRIS in a previous cycle
           (detectable: the removed code matches code from an IRIS commit)
Action: STOP immediately
        Do NOT attempt to re-apply the original change
        Generate conflict report:
          - Which IRIS change is being undone
          - IRIS cycle it was introduced in
          - IRIS rationale for that change
          - Note: "This may be intentional. If so, add to IRIS_MEMORY.json as
            intentional_pattern or rejected_change."
        Wait for human input before resuming monitoring
```

### Metrics Cascade Failure (escalate to full cycle)
```
Condition: 2+ metrics degrade in the same monitoring window
Action: Do NOT attempt targeted fixes
        Trigger a full IRIS cycle starting from Fase 2
        (Metrics are already collected — no need for full Fase 1)
        Log: "Cascade degradation detected — escalating to full cycle"
```

---

## IRIS_LOG.md Extensions for Build Monitor

Add these fields to the IRIS_LOG.md monitoring section:

```markdown
## Build Monitor State

- Last successful build ref: [git commit hash or tag]
- Last check: [ISO datetime]
- Consecutive stable builds: [N]
- Convergence status: [active | converged | degrading]
- Auto-fix attempts since last human review: [N]

### Build History (last 10)
| Build | Ref | Status | Tests | Coverage delta | Action taken |
|-------|-----|--------|-------|----------------|-------------|
| [N] | [hash] | OK | 142/142 | +0.3% | baseline updated |
| [N-1] | [hash] | DEGRADED | 140/142 | -1.2% | fix proposed |
```

---

## Integration with `/iris:plan`

When Stage 3 detects DEGRADED metrics, the Build Monitor can pass context directly to IDEATE:

```json
{
  "trigger": "monitor-degradation",
  "degraded_metrics": [
    { "metric": "test_coverage", "delta": -2.3, "affected_files": ["src/auth/token.js"] }
  ],
  "suggested_focus": ["src/auth/token.js"],
  "context": "Coverage dropped after commit abc1234 which removed token expiry test"
}
```

IDEATE will then focus only on the degraded modules rather than re-planning the full codebase.

---

## Difference from Full IRIS Cycle

| Dimension | Build Monitor | Full IRIS Cycle |
|-----------|--------------|-----------------|
| Scope | Changed files + direct importers | Entire codebase |
| Time | Minutes | Hours |
| Metrics | Partial (affected files only) | All 5 metrics, full calculation |
| Planning | Not included — proposes /iris:plan if needed | Full Fase 3 roadmap |
| Memory | Reads only — does not update IRIS_MEMORY.json | Reads and writes |
| Frequency | After every commit / daily | Weekly / on-demand |
| Best for | "Did I break anything?" | "What should I improve?" |
