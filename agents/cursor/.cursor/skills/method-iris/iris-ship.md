# IRIS Fase 4: SHIP — Implementation

## Objective

Execute the planned improvement iterations with maximum quality, minimum risk, and zero tolerance for accumulated failures. One change at a time. Test after every file. Never move forward with a red test.

## Inputs

- Fase 3 Roadmap (specific iteration to execute, identified by `/iris:execute iter-N`)
- Fase 1 + Fase 2 context (tech stack, test framework, architecture)
- Current state of the codebase (read from files — never assume)

## Pre-Implementation Protocol (always run first)

Before touching a single line of code:

### P.1 — Working Tree Verification
Check that the working tree is clean:
```bash
git status
```
If there are uncommitted changes: STOP. Ask the user to commit or stash before proceeding. Never implement IRIS changes on a dirty working tree.

### P.2 — Baseline Snapshot
Create a recoverable reference point:
```bash
git tag iris-start-iter-[N]
```
If git is not available: note the current state of each file to be modified by reading them before any changes.

### P.3 — Iteration Review
- **Validate iteration identifier:** For `/iris:execute iter-N`, N must be a positive integer. If N is missing, non-numeric, or not an integer → STOP and ask: "Please specify a valid iteration number (e.g. iter-1, iter-2)."
- Re-read the iteration plan from Fase 3:
  - What is the single objective?
  - Which files are in scope?
  - What is the Definition of Done?
  - What is the rollback plan?

### P.4 — File Reading (mandatory before any edit)
Read every file listed in the iteration plan. Do not rely on memory from Fase 2. Code may have changed since analysis.

## Per-File Implementation Protocol

For each file in the iteration (follow the dependency order from Fase 3):

### Step 4.1 — Read the Complete File
Use the read file tool. Read the entire file, not just the section to be modified.

Purpose:
- Understand the full context of the change
- Identify callers and dependents not visible in isolation
- Verify the file matches what was analyzed in Fase 2 (flag if significant drift)

### Step 4.2 — Read Corresponding Tests (if they exist)
If tests exist for this module:
- Read the test file to understand current test coverage
- Identify which behaviors are already tested
- Identify which behaviors will be affected by the change

### Step 4.3 — Implement the Change

**For bug fixes:**
1. Write a failing test that reproduces the bug (test-first)
2. Verify the test fails with the current code
3. Implement the fix
4. Verify the test now passes
5. Check that no other tests broke

**For refactoring (no behavior change):**
1. Verify existing tests cover the code before touching it
2. If not covered: write characterization tests first (tests that document current behavior)
3. Refactor
4. Verify all tests still pass (same behavior)

**For new test additions:**
1. Read the source module to understand all public behaviors
2. Write tests for: happy path, error conditions, edge cases (null/empty/max/min), security inputs
3. Run the tests — they must pass if testing correct behavior, fail if testing wrong assumptions

**For architecture improvements (introducing abstractions):**
1. Write the new interface/abstraction
2. Implement the concrete class/function
3. Update the calling code to use the new abstraction
4. Update or write tests using the new structure
5. Delete the old direct dependency if being replaced

**Implementation rules (always):**
- Match the existing code style: indentation, naming conventions, file organization
- Minimum necessary change: do not refactor code outside the iteration scope "while you're here"
- Comments explain *why*, not *what*: the code shows what; the comment explains the non-obvious reason
- No new dependencies without explicit justification in the iteration plan
- No TODO, FIXME, HACK, or TEMP in committed code — either fix it or create a new finding

### Step 4.4 — Run Module Tests (immediately after each file)
After modifying a file, run the tests for that specific module:

```bash
# Examples by ecosystem:
npx jest src/auth/service.test.js          # Jest
pytest tests/test_auth_service.py -v       # Pytest
go test ./internal/auth/... -v             # Go
./gradlew test --tests "AuthServiceTest"   # Gradle
```

**If tests fail: STOP IMMEDIATELY.**
- Do not modify the next file
- Do not continue the iteration
- Diagnose the failure
- Fix the failing test or revert the change that broke it
- Only continue after all tests pass

### Step 4.5 — Commit the File Change
After each logical unit of change (one file or a tightly coupled pair):
- **Sanitize commit message:** Use a single line; no newlines or control characters. Escape or strip internal double quotes. Safe format: `IRIS-iter-[N]: [brief description]` (e.g. replace newlines with space, max length ~72 chars for readability).
```bash
git add [modified files]
git commit -m "IRIS-iter-[N]: [brief description of this specific change]"
```

Using small commits means rollback is granular and the git log explains the improvement history.

## Post-Iteration Validation

After all files in the iteration are implemented and committed:

### V.1 — Full Test Suite
Run the complete test suite:
```bash
npm test        # Node.js
pytest          # Python
go test ./...   # Go
./gradlew test  # Gradle/Maven
```
All tests must pass. Zero failures allowed before declaring iteration complete.

### V.2 — Coverage Verification
Run with coverage enabled and compare to pre-iteration baseline:
```bash
npx jest --coverage          # Jest
pytest --cov=src --cov-report=term  # Pytest
go test ./... -coverprofile=coverage.out && go tool cover -func=coverage.out  # Go
```
Coverage must be ≥ the pre-iteration baseline (the value recorded at start of Fase 4).

**If coverage decreased:** This is a DoD failure. Do not advance to Fase 5 until coverage is restored.

### V.3 — Linter / Static Analysis
Run the project's linter:
```bash
npx eslint src/           # ESLint
ruff check src/           # Ruff (Python)
golangci-lint run         # Go
```
Zero new errors introduced. Zero new warnings unless the change has an explicit justification.

### V.4 — DoD Verification
Go through the iteration's Definition of Done checklist from Fase 3. Each checkbox must be physically checked based on evidence (test output, coverage report, linter output), not assumption.

## Output Format

```markdown
## IRIS Fase 4 — Implementation Log: Iteration [N]
**Date:** [date] | **Duration:** [actual hours] vs. [estimated hours]

---

### Changes Made
| File | +Lines | -Lines | Purpose |
|------|--------|--------|---------|
| [path] | [N] | [N] | [one sentence] |

### Commits
- `[hash]` IRIS-iter-[N]: [description]
- `[hash]` IRIS-iter-[N]: [description]

### Test Results
```
[Full test output pasted here]
```
- Total tests run: [N]
- Passed: [N] (100%)
- Failed: 0
- Coverage before: [X%]
- Coverage after: [Y%]
- Delta: [+Z% / same / -Z% ← PROBLEM IF NEGATIVE]

### Quality Checks
- [ ] Full test suite passes (100%)
- [ ] Coverage maintained or improved
- [ ] Linter: 0 new errors, 0 new warnings
- [ ] No TODOs/FIXMEs in committed code
- [ ] Documentation synchronized

### Definition of Done Verification
[Copy the DoD from Fase 3 and check each box with evidence]
- [x] [criterion] — verified by [test name / linter output / reading the code]

### Issues Encountered
| Issue | How Resolved | Additional Time |
|-------|--------------|-----------------|
| [description] | [resolution] | [Xmin] |

### Rollback Info
- Start tag: `iris-start-iter-[N]`
- Rollback command: `git reset --hard iris-start-iter-[N]`

---

**→ Iteration [N] complete. Ready for Fase 5: VERIFY** ✅
OR
**→ Iteration [N] blocked: [specific failure]. Cannot advance.** ❌
```

## Abort Conditions (STOP and report)

Stop the iteration and report immediately if:
1. Tests fail after a change and cannot be fixed within the iteration's scope
2. The change reveals a CRITICAL finding not in the iteration plan (new security issue, data loss risk)
3. The LOC budget (≤400) is exceeded before all planned changes are made
4. The change requires modifying files outside the iteration's scope list
5. A dependency between files creates a circular modification requirement

When stopping: commit the partial work, note the abort reason, and request replanning (return to Fase 3).
