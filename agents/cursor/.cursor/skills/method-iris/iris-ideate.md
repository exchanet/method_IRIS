# IRIS Fase 3: IDEATE — Improvement Planning

## Objective

Transform the Fase 2 findings into a concrete, prioritized, risk-assessed improvement roadmap. Every improvement must be decomposed into iterations that modify ≤400 LOC. Every iteration must have an explicit rollback plan and Definition of Done.

## Inputs

- Fase 2 Report (all findings with IDs, metrics, root causes)
- Fase 1 context (architecture, tech stack, test framework, **IRIS_MEMORY.json loaded**)
- `IRIS_INPUT.json` if present (may contain constraints from source method)

## Step-by-Step Execution

### Step 3.0 — Memory Filter (run before scoring anything)

**Before evaluating any finding, apply the semantic memory filter from `IRIS_MEMORY.json`.**

If IRIS_MEMORY.json was not found in INGEST: skip this step.

**3.0.1 — Intentional Patterns due for revisit:**
If any `intentional_pattern` has `revisit_on ≤ today`:
- Present to user BEFORE continuing with the roadmap:
  ```
  IP-NNN "[pattern]" was marked intentional on [decided_on].
  Revisit date [revisit_on] has passed.
  Original reason: [reason]
  Decision: [Keep as-is] [Update reason/date] [Remove from memory — add to roadmap]
  ```
- Update IRIS_MEMORY.json based on user's response
- Only then continue to 3.0.2

**3.0.2 — Filter proposed improvements against rejected_changes:**
For each potential improvement from Fase 2:
- Does it closely match any `rejected_change.proposed` in scope and approach?
  - Match: same architectural direction, same modules, same type of change
  - If `permanent = true` → SKIP silently. Log in IDEATE report as "Excluded by memory: RC-NNN"
  - If `permanent = false` AND not expired → include in "Blocked Proposals" section with:
    - `rejected_reason`
    - `reconsider_when` (if set)
    - `expires_on` (if set — user can see when it will be re-evaluated)
  - If `permanent = false` AND `expires_on` has passed → re-propose it normally, note the previous rejection

**3.0.3 — Filter against architectural_constraints:**
For each potential improvement from Fase 2:
- Would implementing it require violating any `architectural_constraint.constraint`?
  - **Exception:** If the finding is CRITICAL security (e.g. SQL injection, auth bypass), do NOT block. ESCALATE to user: "CRITICAL security finding conflicts with constraint AC-NNN. User must: remove constraint, accept risk, or provide alternative fix." IRIS cannot proceed until resolved.
  - If yes (and not CRITICAL security) → mark as BLOCKED-BY-CONSTRAINT in the report with AC-NNN reference
  - Do NOT plan a fix — the constraint prevents it
  - The finding may still appear in REVIEW as awareness — it just cannot be fixed

**3.0.4 — Context change notification:**
If any `context_changes` entry was loaded in INGEST that affects existing rejected_changes:
- Note: "Context change detected: [description]. This may allow reconsidering RC-NNN."
- Present to user for decision before finalizing the roadmap

**Output of Step 3.0 — Memory Filter Report:**
```markdown
### Memory Filter Results
- Improvements excluded (permanent): [N] — IDs: RC-NNN, RC-NNN
- Improvements blocked (active rejection): [N] — see Blocked Proposals section
- Improvements blocked by constraint: [N] — AC-NNN
- Patterns due for revisit: [N] — user reviewed, decisions recorded
- Remaining improvements to score: [N]
```

---

### Step 3.1 — Cascade Analysis (run before impact scoring)

For each remaining finding (after memory filter), analyze whether resolving it eliminates other findings automatically.

**A finding B is eliminated by fixing A when:**
- B is a symptom of A's root cause: fixing A removes the underlying condition that causes B
- B exists only in code that A will delete or significantly restructure
- B is a near-duplicate of A in another module: fixing A via abstraction covers both
- B's test failures would be resolved by A's fix (test covers both behaviors)

**How to calculate cascade_score:**
```
cascade_score(A) = count of distinct findings from Fase 2 that disappear when A is resolved
```

**Adjusted Final Score:**
```
cascade_capped = min(cascade_score(A), 50)
final_score(A) = impact_score(A) + (cascade_capped × 0.4)
```

The cascade score is capped at 50 so a single finding cannot dominate the roadmap solely by cascade count. The multiplier (0.4) ensures that a finding with high individual impact still takes priority, but a medium-impact finding that eliminates several others can move up significantly.

**Cascade Elimination Map (produce this before the roadmap table):**
- Use **cascade_capped** (min of cascade_score and 50) in the map and in final_score so the roadmap is not skewed by extreme cascade counts.
```markdown
### Cascade Elimination Map
| Primary Finding | Cascade Score (capped at 50) | Findings Eliminated |
|----------------|------------------------------|---------------------|
| C-001 (SQL injection) | 0 | — (no secondary eliminations) |
| I-003 (Tight coupling in processor.js) | 3 | I-007, I-008, O-002 |
| I-005 (Missing test infrastructure) | 6 | O-001, O-003, O-004, O-005, I-009, I-010 |
```

This map changes the roadmap order. A finding like I-005 with cascade_score=6 has higher final_score than a standalone CRITICAL with cascade_score=0. Scores are capped so one finding cannot dominate purely by cascade count.

---

### Step 3.2 — Impact Scoring (previously Step 3.1)

For every finding from Fase 2 (all categories), calculate an Impact Score:

```
Impact Score = (Business_Value × 0.4) + (Technical_Urgency × 0.3) + (Risk_Reduction × 0.3)
```

**Scoring guide (1–10 each):**

| Factor | 1–3 (Low) | 4–6 (Medium) | 7–10 (High) |
|--------|-----------|--------------|-------------|
| Business Value | Minor UX issue, rarely triggered | Affects core workflow sometimes | Breaks critical path, affects all users |
| Technical Urgency | No blocking effect | Slows development | Blocking other work; actively degrading |
| Risk Reduction | Cosmetic risk | Security/stability risk in edge cases | Active exploit or data loss risk |

**Auto-score overrides:**
- CRITICAL findings: minimum Impact Score = 8 (override calculation if lower)
- Cosmetic findings: maximum Impact Score = 3 (cap if higher)

### Step 3.3 — Effort Estimation

For each improvement, estimate total effort in hours:

```
Total Effort = analysis_hours + implementation_hours + test_hours + doc_hours + risk_buffer
```

Where:
- `analysis_hours`: time to understand the code before changing it (0.5–4h)
- `implementation_hours`: time to write the actual fix or refactoring (0.5–8h)
- `test_hours`: time to write/update tests (0.5–4h)
- `doc_hours`: time to update comments, README, docs (0–1h)
- `risk_buffer`: 15% of subtotal for LOW-risk changes, 25% for MEDIUM, 40% for HIGH

**Effort categories:**
- Quick (<2h): Documentation fixes, simple constant extractions, dead code removal
- Medium (2–6h): Security fixes, test additions for existing modules, small refactors
- Significant (6–16h): Architectural changes, introducing abstractions, coverage from 0
- Large (>16h): Must be decomposed into multiple iterations before planning continues

### Step 3.4 — Dependency Mapping

Identify which improvements must precede others:

**Universal dependency rules:**
1. Security fixes first — they reduce blast radius for all subsequent changes
2. Test infrastructure before coverage improvements — need the scaffolding before writing tests
3. Architectural changes before the code they will affect
4. Remove dead code before refactoring surviving code (clearer picture)
5. Fix bugs before optimizing (the optimization may be invalid if bugs remain)

For each improvement, document:
- `depends_on`: list of improvement IDs that must be done first (or "none")
- `blocks`: list of improvement IDs that cannot start until this one completes
- `parallel_safe`: true if this improvement can run concurrently with others (no shared files)

**Produce a dependency order** (topological sort of the improvement DAG):
```
Priority 1: C-001, C-002, C-003   (all critical, no dependencies)
Priority 2: I-005                  (infrastructure — unblocks I-007, I-008)
Priority 3: I-007, I-008           (can run in parallel — different files)
Priority 4: I-003, I-004           (medium impact)
Priority 5: O-001, O-002           (optimizable)
```

### Step 3.5 — Iteration Decomposition

**Hard rules:**
- Every iteration modifies ≤400 LOC (added + removed + substantially modified)
- Every iteration has exactly one logical objective
- No iteration mixes: refactoring + feature addition, or security fix + coverage improvement
- Every iteration is independently deployable (can be committed without the next iteration)

**If an improvement requires >400 LOC:** Split it. Name the splits with `-part-1`, `-part-2`.

**Iteration template:**
```markdown
#### Iteration [N]: [Descriptive Name]
- **Objective:** [One sentence. What will be different after this iteration?]
- **Addresses findings:** [C-001, I-003, etc.]
- **Files to modify:**
  - `[path/to/file.ext]` — [what changes in this file]
  - `[path/to/test_file.ext]` — [what test changes]
- **LOC estimate:** +[added] lines / -[removed] lines (~[modified] modified)
- **Total LOC budget:** [sum, must be ≤400]
- **Risk:** LOW | MEDIUM | HIGH
- **Risk justification:** [why this risk level]
- **Dependencies:** None | [Iteration N must complete first]
- **Rollback plan:** `git reset --hard iris-start-iter-[N]`
  [Any additional manual steps if git reset is insufficient]
- **Definition of Done:**
  - [ ] [Specific, verifiable criterion 1]
  - [ ] [Specific, verifiable criterion 2]
  - [ ] All existing tests pass (100%)
  - [ ] Test coverage has not decreased from pre-iteration baseline
  - [ ] No new linter errors
  - [ ] [Stack-specific quality gate if applicable]
```

### Step 3.6 — Iteration Sequencing

Default sequence (override based on Fase 2 findings):

**Block A — Critical (must do first):**
- All CRITICAL security findings
- All CRITICAL crash/data-loss risks

**Block B — Foundation (unlock other improvements):**
- Test infrastructure setup (if no tests exist)
- Architectural decoupling that blocks testability
- Dead code removal

**Block C — High Impact:**
- IMPROVABLE bugs
- Major coupling reductions
- Significant coverage improvements

**Block D — Medium Impact:**
- Minor refactoring
- Documentation improvements
- Remaining coverage

**Block E — Polish:**
- OPTIMIZABLE items
- COSMETIC items (bundle into a single iteration)

### Step 3.7 — Risk Assessment

For each HIGH-risk iteration, produce:

```markdown
**Risk Mitigation for Iteration [N]:**
- **Primary risk:** [what could go wrong]
- **Probability:** Low / Medium / High
- **Impact if it fails:** [what breaks]
- **Mitigation strategy:** [what you'll do to reduce risk]
  - Write regression tests before making changes
  - Make changes incrementally within the iteration (not all at once)
  - Validate each sub-step before the next
- **Rollback trigger:** [specific condition that means "revert immediately"]
- **Recovery time:** [estimated time to rollback and restart]
```

### Step 3.8 — Success Metrics Definition

Define the target state after all iterations complete:

```markdown
### Success Metrics (Target State)
| Metric | Current | Target | How to Measure |
|--------|---------|--------|----------------|
| Defect Density | [X] | [Y] | Static analysis re-run |
| Test Coverage | [X%] | [Y%] | Coverage report |
| Complexity Score | [X] | [Y] | Complexity tool re-run |
| Tech Debt Ratio | [X%] | [Y%] | Re-estimate after fixes |
| Arch Health Index | [X] | [Y] | Re-calculate from code |
```

## Output Format

```markdown
## IRIS Fase 3 Report — Improvement Roadmap
**Cycle:** #[N] | **Total improvements:** [N] | **Total iterations:** [N] | **Estimated effort:** [X]h

---

### Memory Filter Results
- Improvements excluded (permanent): [N] — see IRIS_MEMORY.json RC entries with permanent=true
- Improvements blocked (active rejection): [N] — see Blocked Proposals section below
- Improvements blocked by constraint: [N] — see AC entries in IRIS_MEMORY.json
- Intentional patterns reviewed: [N]

### Cascade Elimination Map
| Primary Finding | Cascade Score | Findings Eliminated |
|----------------|---------------|---------------------|
| [ID] | [N] | [IDs that disappear when this is resolved] |

### Scored Improvements
| Priority | ID | Description | Impact Score | Cascade | Final Score | Effort | Risk | Iteration |
|----------|----|-------------|--------------|---------|-------------|--------|------|-----------|
| 1 | C-001 | [desc] | 9.2 | 0 | 9.2 | 2h | LOW | 1 |
| 2 | I-005 | [desc] | 7.1 | 6 | 9.5 | 4h | LOW | 2 |

### Blocked Proposals (from IRIS_MEMORY.json — excluded from roadmap)
| Proposed Improvement | Blocked by | Reason | Reconsider when |
|---------------------|-----------|--------|-----------------|
| [description] | RC-NNN | [rejected_reason] | [reconsider_when or expires_on] |

---

### Dependency Order
```
Block A (critical): C-001, C-002
Block B (foundation): I-005
Block C (high impact): I-007, I-008 (parallel)
Block D (medium): I-003, I-004
Block E (polish): O-001, O-002, cosmetics
```

---

### Iteration Plan

[Iteration template for each, as defined in Step 3.4]

---

### Risk Mitigations

[For each HIGH-risk iteration, as defined in Step 3.6]

---

### Success Metrics

[Table as defined in Step 3.7]

---

### Fase 3 Checklist
- [ ] All findings scored with Impact Score
- [ ] All improvements have effort estimates
- [ ] Every iteration ≤400 LOC
- [ ] Every iteration has single logical objective
- [ ] Dependency graph is acyclic
- [ ] Every iteration has rollback plan
- [ ] Every iteration has explicit DoD
- [ ] CRITICAL findings in first 1–2 iterations
- [ ] Timeline is realistic
- [ ] Success metrics defined

**→ Ready for Fase 4: SHIP** ✅ / **→ Cannot proceed: [issues]** ❌
```

## Special Handling for Integrated Context

### From PDCA-T (coverage-escalation)
Focus iterations on:
1. Architectural decoupling that makes code untestable
2. Introducing abstractions/interfaces for mocking
3. Separating business logic from infrastructure
Do NOT focus on simply writing more tests — that's PDCA-T's job after handoff.

### From Enterprise Builder (post-delivery)
Create a rolling roadmap, not a fixed plan:
- Iteration Block A: immediate improvements on the delivered system
- Iteration Block B (scheduled): monitoring and health checks
- Define monitoring triggers rather than specific iterations for Block C+

### From Modular Design (architecture health)
All iterations must:
- Preserve Core/Pack contracts (do not break existing module interfaces)
- Add contract tests for any interface that changes
- Document any new pack boundaries discovered
