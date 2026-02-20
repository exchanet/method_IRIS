# IRIS Integration Guide
## How IRIS Connects With PDCA-T, Enterprise Builder, and Modular Design

---

## Ecosystem Overview

IRIS is the **meta-operative layer** of the Exchanet methods ecosystem. Each method has a distinct role:

| Method | Layer | Trigger | Scope | Output |
|--------|-------|---------|-------|--------|
| Enterprise Builder | Strategic | `/method-enterprise_builder` | New systems, enterprise planning | 8-phase plan + delivery report |
| Modular Design | Architectural | contextual | Core + Packs structure | Clean module boundaries |
| PDCA-T | Tactical | `always_on` | Per micro-task (≤50 LOC) | ≥99% test coverage |
| **IRIS** | **Meta-operative** | `/iris:*` | **Any existing codebase** | **Measurable quality improvement** |

**Key distinction:** PDCA-T builds new code with quality from the start. IRIS improves existing code, regardless of how it was built.

---

## Integration Patterns

### Pattern 1: PDCA-T → IRIS → PDCA-T (Coverage Escalation)

**When to use:** PDCA-T has attempted ≥3 cycles and cannot break through a coverage ceiling.

**Trigger condition:**
- PDCA-T achieves 70%, tries again → 82%, tries again → 87%. Cannot get to 99%.
- Root cause: the code architecture makes some paths untestable.

**Flow:**

```
PDCA-T Cycle 1 → coverage: 82%
PDCA-T Cycle 2 → coverage: 87% (refines tests)
PDCA-T Cycle 3 → coverage: 87% (no improvement — stuck)
           │
           ▼ Escalate
PDCA-T generates IRIS_INPUT.json:
  source_method: "pdca-t"
  trigger_reason: "coverage-escalation"
  escalation_data:
    attempts_made: 3
    achieved_coverage: 87
    problematic_modules: [src/payments/processor.js, src/auth/token.js]
           │
           ▼
IRIS Fase 1: Ingest escalation context
IRIS Fase 2: Focus on WHY code is untestable
             → found: processor.js calls HTTP directly (no abstraction)
             → found: token.js uses global crypto state
IRIS Fase 3: Plan architectural fixes
             → Iteration 1: Introduce PaymentGateway interface (200 LOC)
             → Iteration 2: Extract crypto to injectable utility (150 LOC)
IRIS Fase 4: Implement architectural fixes
IRIS Fase 5: Verify, generate IRIS_OUTPUT.json
  target_method: "pdca-t"
  pdca_t_handoff:
    refactored_modules: [processor.js, gateway.interface.js, token.js]
    new_interfaces: [PaymentGateway]
    expected_coverage_after_pdca: 99
           │
           ▼
PDCA-T Cycle 4 (with refactored code) → coverage: 99.3% ✅
```

**File exchange:**
- PDCA-T writes: `IRIS_INPUT.json` in project root
- IRIS reads: `IRIS_INPUT.json`
- IRIS writes: `IRIS_OUTPUT.json` in project root
- PDCA-T reads: `IRIS_OUTPUT.json`, resumes with `pdca_t_handoff` context

---

### Pattern 2: Enterprise Builder → IRIS → monitoring loop (Post-Delivery)

**When to use:** Enterprise Builder Fase 8 is complete. The system is delivered. Continuous improvement needed.

**Flow:**

```
Enterprise Builder Fases 1–8 complete
Enterprise Builder generates delivery report
Delivery report references IRIS for ongoing maintenance:
           │
           ▼
Enterprise Builder writes IRIS_INPUT.json:
  source_method: "enterprise-builder"
  trigger_reason: "post-delivery-monitoring"
  enterprise_context:
    delivery_report_path: "docs/enterprise-plan/phase8-delivery-report.md"
    nfr_targets: { coverage: 99, latency_p95_ms: 100 }
    residual_risks: ["Cache invalidation not tested under load"]
           │
           ▼
IRIS Cycle #1:
  Fase 1: Ingest full delivered system + delivery report
  Fase 2: Establish baseline metrics
  Fase 3: Address residual risks + create monitoring roadmap
  Fase 4: Fix critical residual risks
  Fase 5: Enter MONITORING MODE
           │
           ▼
[Weekly] IRIS monitoring check:
  Run abbreviated Fase 1+2 (15 min)
  Compare metrics against thresholds
  If stable → log "healthy" + schedule next check
  If threshold crossed → trigger new IRIS full cycle
           │
           ▼
[When new feature planned]
IRIS_OUTPUT.json → Enterprise Builder Fase 1:
  enterprise_builder_feedback:
    new_risks_identified: [found in monitoring]
    nfr_adjustments_suggested: [based on production data]
    adr_updates_recommended: [based on implementation findings]
```

---

### Pattern 3: Modular Design → IRIS → Modular Design (Architecture Health)

**When to use:** Modular Design detects violations of Core/Pack contracts.

**Flow:**

```
Modular Design detects:
  - Circular dependency: packs/fraud-pack → packs/payment-pack → packs/fraud-pack
  - Core contamination: core/engine.js contains fraud detection logic
           │
           ▼
Modular Design writes IRIS_INPUT.json:
  source_method: "modular-design"
  trigger_reason: "architecture-health-check"
  architecture_context:
    circular_dependencies: ["packs/fraud-pack → packs/payment-pack → packs/fraud-pack"]
    contract_violations: ["core/engine.js contains domain logic"]
           │
           ▼
IRIS Cycle:
  Fase 1: Map Core/Pack structure completely
  Fase 2: Focus on architectural metrics + violations listed
  Fase 3: Plan refactoring preserving all public interfaces
          → Iteration 1: Extract fraud logic from Core to fraud-pack (350 LOC)
          → Iteration 2: Introduce FraudCheck interface in Core (100 LOC)
          → Iteration 3: Update fraud-pack to use new interface (200 LOC)
  Fase 4: Implement with contract tests at each step
  Fase 5: Verify AHI improved, generate IRIS_OUTPUT.json
           │
           ▼
IRIS writes IRIS_OUTPUT.json:
  target_method: "modular-design"
  modular_design_feedback:
    resolved_violations: ["circular deps broken", "core contamination removed"]
    new_pack_suggestions: ["consider risk-assessment-pack from fraud-pack"]
           │
           ▼
Modular Design receives feedback + updates pack documentation
```

---

### Pattern 4: Full Ecosystem Pipeline

**When to use:** Complete new feature development with maximum quality and continuous improvement.

```
Step 1: Enterprise Builder (Fases 1–4)
  → Produces: context, NFRs, risk matrix, micro-task DAG

Step 2: Modular Design
  → Assigns each micro-task to Core or Pack

Step 3: PDCA-T (per micro-task)
  → Develops each task with ≥99% coverage
  → On coverage block → escalate to IRIS (Pattern 1)

Step 4: Enterprise Builder (Fases 5–8)
  → ADRs, security mapping, test strategy, delivery report

Step 5: IRIS (post-delivery)
  → Enters monitoring mode (Pattern 2)
  → Continuous quality guard
```

---

## Decision Matrix: Which Method to Use When

| Situation | Primary Method | Secondary |
|-----------|---------------|-----------|
| New enterprise system from scratch | Enterprise Builder | → Modular Design → PDCA-T → IRIS |
| New feature with high quality bar | PDCA-T | IRIS (if coverage stuck) |
| Existing codebase, unknown quality | **IRIS** | standalone |
| Existing codebase, legacy no tests | **IRIS** | + PDCA-T after |
| Architectural degradation detected | **IRIS --architecture** | Modular Design |
| Security audit needed | **IRIS --security** | standalone |
| Performance bottleneck investigation | **IRIS --performance** | standalone |
| Post-delivery maintenance | **IRIS** (monitoring mode) | |
| Production crisis / hotfix | PDCA-T (fast cycle) | IRIS for root cause |

---

## State Files Reference

| File | Location | Purpose | Created by | Read by |
|------|----------|---------|------------|---------|
| `IRIS_INPUT.json` | project root | Handoff into IRIS | PDCA-T / EB / MD | IRIS |
| `IRIS_OUTPUT.json` | project root | Handoff out of IRIS | IRIS | PDCA-T / EB / MD |
| `IRIS_LOG.md` | project root | Cycle history | IRIS | IRIS (persistence) |
| `PDCA_T_STATE.json` | project root | PDCA-T state | PDCA-T | PDCA-T |
| `EB_STATE.json` | project root | Enterprise Builder state | EB | EB |

---

## Troubleshooting Integrations

### IRIS_INPUT.json not found
IRIS defaults to standalone mode. Activates from the current directory. No error — this is normal for direct use.

### Circular escalation (PDCA-T → IRIS → PDCA-T → IRIS ...)
If IRIS output goes back to PDCA-T and PDCA-T escalates again within 1 cycle:
- STOP the automated loop
- This signals a deeper architectural problem IRIS alone cannot solve
- Flag for manual architectural review
- IRIS should document this in `IRIS_LOG.md` as a human-review trigger

### Schema version mismatch
If `IRIS_INPUT.json` schema_version doesn't match current IRIS version:
- Minor version difference (2.1.x → 2.1.y): warn, proceed
- Major version difference (1.x → 2.x): stop, ask user to update source method

### Conflicting recommendations
If IRIS Fase 3 recommendations conflict with Enterprise Builder ADRs:
- IRIS must respect the architectural decisions recorded in ADRs
- Flag the conflict explicitly in Fase 3 report
- Propose ADR amendment rather than violating it silently
