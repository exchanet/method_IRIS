# IRIS Claude Code Commands
# These extend the CLAUDE.md configuration with slash command shortcuts

## /iris:analyze

Runs IRIS Fase 1 (Ingest) + Fase 2 (Review) on the specified path.

Usage: `/iris:analyze [path]`
If path is omitted: use current working directory.

Steps:
1. Read project structure
2. Identify tech stack
3. Run quality assessment
4. Calculate 5 core metrics
5. Produce Fase 1 + Fase 2 report

## /iris:plan

Runs IRIS Fase 3 (Ideate) — creates improvement roadmap.

Prerequisite: Fase 2 report must exist in session context.

Steps:
1. Score all findings by impact
2. Estimate effort per improvement
3. Map dependencies
4. Decompose into iterations ≤400 LOC each
5. Define DoD and rollback for each iteration

## /iris:execute

Runs IRIS Fase 4 (Ship) for a specific iteration.

Usage: `/iris:execute iter-1` (or iter-2, iter-3, etc.)

Steps:
1. Verify git status clean
2. Create recovery tag
3. Read all files to modify
4. Implement changes with immediate test validation
5. Run full suite at end
6. Commit and update IRIS_LOG.md

## /iris:verify

Runs IRIS Fase 5 (Spin) — closes the cycle.

Steps:
1. Full regression test
2. Metrics comparison (before vs. after)
3. Self-review of all changes
4. Lessons documented
5. IRIS_LOG.md updated
6. IRIS_OUTPUT.json generated if integrated

## /iris:full

Runs all 5 phases sequentially.

Usage: `/iris:full [path]`

## /iris:monitor

Activates monitoring mode: abbreviated Fase 1+2 on a scheduled basis.
Triggers full cycle if degradation thresholds are crossed.

## /iris:help

Displays the command reference from CLAUDE.md.
