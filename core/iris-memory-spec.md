# IRIS Memory Specification v2.1
# Semantic Memory System — IRIS_MEMORY.json

## Purpose

`IRIS_MEMORY.json` is the **active semantic memory** of IRIS for a specific project. It persists across all cycles and prevents three classes of waste:

1. **Re-proposing rejected changes** — IRIS will not suggest migrating to microservices in cycle 8 if it was explicitly rejected in cycle 2.
2. **Flagging intentional patterns** — A "God class" kept deliberately for business reasons should not appear as a new CRITICAL finding every cycle.
3. **Violating architectural constraints** — If the team decided "no ORM ever", IRIS must respect that, regardless of what static analysis suggests.

Without memory, IRIS is an intelligent agent without long-term learning. With it, IRIS compounds knowledge across cycles.

---

## File Location and Lifecycle

**Location:** Project root, alongside `IRIS_LOG.md`.

**Creation:** IRIS creates `IRIS_MEMORY.json` automatically during the first IDEATE cycle (Fase 3) if it does not exist. The file starts with empty arrays and is populated as decisions are made.

**Update triggers:**
- User rejects a proposed change during IDEATE → IRIS adds it to `rejected_changes`
- User marks a pattern as intentional → IRIS adds it to `intentional_patterns`
- User defines a new hard constraint → IRIS adds it to `architectural_constraints`
- User adds context manually (e.g. via `/iris:memory` or editing the file): e.g. new team member, major dependency update, significant feature added → entries in `context_changes` are **manually added**, not auto-detected by IRIS

**Schema:** `core/schemas/memory.json` (JSON Schema Draft-7, fully validatable)

**Identifiers:** All `id` values (IP-NNN, RC-NNN, AC-NNN) must be unique within the file. IRIS generates new IDs when adding entries (e.g. next free IP-00x, RC-00x) to avoid collisions.

---

## How IRIS Uses the Memory

### In Fase 1: INGEST (Step 1.9)

Before analyzing any source file, IRIS reads `IRIS_MEMORY.json`:

```
1. Check for IRIS_MEMORY.json in project root
2. If found:
   a. Load all intentional_patterns → note their scope files
   b. Load all rejected_changes → note their proposed actions and scope
   c. Load all architectural_constraints → note the rules
   d. Check any intentional_pattern where revisit_on ≤ today
      → Flag these for user review at start of IDEATE (not auto-skip)
   e. Check context_changes for recent additions
      → If recent context change affects rejected_changes → note for IDEATE
3. If not found:
   → Note "No IRIS_MEMORY.json — will create during IDEATE if decisions are made"
4. Add to Fase 1 Checklist:
   [ ] IRIS_MEMORY.json loaded (or confirmed absent)
   [ ] intentional_patterns reviewed (N patterns, M due for revisit)
   [ ] rejected_changes loaded (N entries)
   [ ] architectural_constraints active (N rules)
```

### In Fase 2: REVIEW

When analyzing a file that matches the `scope` of an `intentional_pattern`:
- Still report the pattern as a finding (for completeness)
- Mark it with `[INTENTIONAL — IP-NNN]` tag in the findings table
- Do NOT categorize it as CRITICAL or IMPROVABLE — use NOTED category
- Include the reason from the memory entry in the finding description

When a finding matches an `architectural_constraint`:
- Include the finding for awareness
- Tag it `[CONSTRAINED — AC-NNN]`
- Do NOT plan a fix — the constraint prevents it

### In Fase 3: IDEATE (Step 3.0 — Memory Filter)

**This is the primary enforcement point.**

Before scoring any finding:

```
For each proposed improvement P:

  1. Check rejected_changes:
     - Does P closely match any rejected_change.proposed?
     - Matching criteria (any of):
       a) Scope overlap: P affects the same files/modules as the rejected proposal
       b) Keyword similarity: same architectural direction (e.g. "microservices", "split module")
       c) Same approach: same type of change (refactor, add dependency, remove pattern)
     - If ambiguous (e.g. two rejected entries could apply): ask user "Does this proposal match a past rejection?"
     - If match found AND permanent = true → SKIP silently, log in IDEATE report
     - If match found AND permanent = false → SKIP, but show in "Blocked Proposals" section
       with rejected_reason, and show reconsider_when or expires_on if set

  2. Check architectural_constraints:
     - Would implementing P require violating any constraint?
     - If yes → SKIP, mark as BLOCKED-BY-CONSTRAINT in report with AC-NNN reference

  3. Check intentional_patterns due for revisit:
     - For each IP where revisit_on ≤ today:
       → Present to user: "IP-NNN (decided on [date]) is due for review.
          Current pattern: [pattern]. Original reason: [reason].
          Do you want to: [keep] [update] [remove]?"
     - User response updates IRIS_MEMORY.json before planning continues
```

### In Fase 5: SPIN (Step 5.8 — Memory Update)

After cycle completes, IRIS updates `IRIS_MEMORY.json`:

**If the user rejected a proposed change during Fase 3:**
```json
{
  "id": "RC-NNN",
  "proposed": "[what IRIS proposed]",
  "scope": "[files affected]",
  "rejected_reason": "[user's stated reason]",
  "rejected_by": "[user / team]",
  "cycle": [N],
  "reconsider_when": "[if user specified a condition]",
  "permanent": [true/false]
}
```

**If the user marked a pattern as intentional:**
- IRIS generates a unique `id` (IP-NNN). All IDs in the file must be unique; IRIS assigns the next available number to avoid collisions.
- If the user sets `revisit_on`, IRIS must validate **revisit_on > today** (strictly in the future). If not, reject with message: "revisit_on must be a future date."
```json
{
  "id": "IP-NNN",
  "pattern": "[pattern description]",
  "scope": "[file path]",
  "reason": "[user's stated reason]",
  "decided_on": "[today]",
  "revisit_on": "[date user specified, or null]",
  "iris_cycle": [N]
}
```

**If a major context change is detected:**
```json
{
  "detected_on": "[today]",
  "description": "[what changed]",
  "affects": ["RC-NNN", "IP-NNN"],
  "iris_cycle": [N]
}
```

---

## The `/iris:memory` Command

Displays and allows editing the current `IRIS_MEMORY.json` interactively.

### Output format:
```markdown
## IRIS Memory — [Project Name]
Last updated: [date] | Cycles with memory: [N]

### Architectural Constraints ([N] active)
| ID | Constraint | Applies to | Since |
|----|-----------|------------|-------|
| AC-001 | No ORM — raw SQL only | src/ | 2026-01-10 |

### Intentional Patterns ([N] patterns, [M] due for review)
| ID | Pattern | Scope | Reason | Revisit |
|----|---------|-------|--------|---------|
| IP-001 | God class UserService | src/user/ | Deliberate until v2.0 | 2026-06-01 ⚠️ overdue |

### Rejected Changes ([N] entries)
| ID | Proposed | Cycle | Reason | Reconsider when | Permanent |
|----|---------|-------|--------|-----------------|-----------|
| RC-001 | Migrate to microservices | 3 | Team too small | Team ≥ 5 engineers | No |

### Context Changes ([N] entries)
[list]

---
Actions:
  /iris:memory add-constraint  → define a new architectural constraint
  /iris:memory add-pattern     → mark a pattern as intentional
  /iris:memory reject [IMP-ID] → manually mark an improvement as rejected
  /iris:memory edit [ID]       → edit an existing entry
  /iris:memory remove [ID]     → remove an entry (requires confirmation)
```

---

## Memory Precedence Rules

When memory conflicts with analysis findings:

| Situation | IRIS Action |
|-----------|------------|
| Finding matches `rejected_change` (permanent=true) | Skip silently — do not show in IDEATE |
| Finding matches `rejected_change` (permanent=false, not expired) | Show in "Blocked Proposals" section with reason |
| Finding matches `rejected_change` (expired) | Re-propose, note the previous rejection |
| Finding violates `architectural_constraint` (and is NOT CRITICAL security) | Show as CONSTRAINED in REVIEW — never propose removal |
| **CRITICAL security finding conflicts with `architectural_constraint`** | **ESCALATE to user IMMEDIATELY. User MUST: remove constraint, accept risk, or provide alternative fix. IRIS cannot proceed until resolved.** |
| Finding matches `intentional_pattern` (not due for revisit) | Show as NOTED in REVIEW — categorize separately |
| Finding matches `intentional_pattern` (due for revisit) | Present to user at IDEATE start for decision |
| Context change detected affecting rejected entry | Flag for user review — do not auto-unblock |

---

## Important: What Memory Does NOT Do

- Memory does not prevent IRIS from **reporting** patterns in REVIEW — it prevents IRIS from **proposing fixes** in IDEATE
- Memory does not override security findings — a CRITICAL security vulnerability is always surfaced, even if it involves an intentional pattern
- **Security overrides constraints:** If fixing a CRITICAL security finding would require violating an `architectural_constraint`, IRIS must ESCALATE to the user and not proceed until the user either removes the constraint, accepts the security risk, or provides an alternative fix. IRIS never silently blocks a CRITICAL security fix.
- Memory is per-project — it does not carry over between projects
- Memory entries with `permanent=false` and an `expires_on` date will be re-proposed after that date

---

## Example Scenario: Cycle 2 Rejects a Change, Cycle 8 Doesn't Re-Propose

**Cycle 2, IDEATE:**
```
IRIS proposes: "Refactor UserService — SRP violation, 18 public methods"
User responds: "Not now — we're launching in 3 weeks. Add to memory with revisit June 1."
IRIS adds to IRIS_MEMORY.json:
  intentional_patterns: IP-001 (UserService God class, revisit 2026-06-01)
```

**Cycles 3–7, IDEATE:**
```
REVIEW detects UserService (18 methods) → marks as [INTENTIONAL — IP-001]
IDEATE skips it → does not appear in roadmap
```

**Cycle 8 (after June 1):**
```
INGEST reads IRIS_MEMORY.json → detects IP-001 revisit_on has passed
IDEATE start: "IP-001 (UserService God class) was marked intentional on 2026-01-15.
  Revisit date 2026-06-01 has passed. Re-evaluate? [Keep] [Update] [Remove from memory]"
User: "Remove — v2.0 launched, ready to split it now."
IRIS removes IP-001 → UserService now appears as a standard IMPROVABLE finding in roadmap
```
