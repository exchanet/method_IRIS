# IRIS Handoff Protocols

## Overview

IRIS operates within an ecosystem of methods. When activated by another method, it receives context via `IRIS_INPUT.json`. When completing a cycle that returns control to another method, it produces `IRIS_OUTPUT.json`. Both files follow the JSON schemas in `core/schemas/`.

All handoffs are bidirectional and versionable. The `schema_version` field allows forward-compatible evolution.

---

## Protocol 1: Receiving from PDCA-T (Coverage Escalation)

### Trigger Condition
PDCA-T has attempted ≥3 cycles and cannot achieve ≥99% test coverage. Root cause is architectural (code is untestable as-is), not effort-based.

### What PDCA-T Provides (`IRIS_INPUT.json`)
```json
{
  "source_method": "pdca-t",
  "trigger_reason": "coverage-escalation",
  "escalation_data": {
    "attempts_made": 3,
    "target_coverage": 99,
    "achieved_coverage": 87,
    "failure_reason": "Tight coupling to external API makes error paths untestable",
    "problematic_modules": [
      {
        "path": "src/payments/processor.js",
        "coverage": 71,
        "issue": "Direct HTTP calls prevent mocking failure scenarios"
      }
    ]
  }
}
```

### IRIS Adaptation
1. **Fase 1:** Focus on `escalation_data.problematic_modules`. Read those files first.
2. **Fase 2:** Focus analysis on *why* the code is untestable:
   - Hidden dependencies (global state, static methods, module-level side effects)
   - Tight coupling to infrastructure (database, HTTP, filesystem)
   - Missing abstractions (no interfaces to mock)
   - God objects doing too many things
3. **Fase 3:** Plan *architectural* improvements that make code testable:
   - Introduce interfaces/protocols for external dependencies
   - Apply dependency injection
   - Separate business logic from infrastructure calls
   - Extract pure functions from impure ones
   - **Do NOT** plan "write more tests" — that's PDCA-T's job after handoff
4. **Fase 4:** Implement the architectural refactoring
5. **Fase 5:** Verify the refactoring doesn't break existing functionality, then produce `IRIS_OUTPUT.json`

### What IRIS Returns (`IRIS_OUTPUT.json` for PDCA-T)
```json
{
  "target_method": "pdca-t",
  "next_action": "handoff-to-pdca-t",
  "pdca_t_handoff": {
    "refactored_modules": [
      "src/payments/processor.js  (introduced PaymentGateway interface)",
      "src/payments/http-gateway.js  (concrete HTTP implementation)",
      "src/payments/processor.test.js  (updated to use mock gateway)"
    ],
    "new_interfaces": [
      "PaymentGateway interface in src/payments/gateway.interface.js"
    ],
    "expected_coverage_after_pdca": 99
  },
  "handoff_context": {
    "focus_areas": [
      "Mock PaymentGateway in tests to simulate error responses",
      "Test all error paths in processor.js using the mock"
    ],
    "avoided_pitfalls": [
      "Do not try to test the HTTP implementation directly — use integration tests for that"
    ],
    "urgent_attention": []
  }
}
```

### Success Criteria for this Protocol
PDCA-T should be able to reach ≥99% coverage within 2 additional cycles after receiving the IRIS output.

---

## Protocol 2: Receiving from Enterprise Builder (Post-Delivery)

### Trigger Condition
Enterprise Builder Fase 8 (Delivery Report) is complete. The system has been delivered. IRIS is activated to monitor and continuously improve the delivered system.

### What Enterprise Builder Provides (`IRIS_INPUT.json`)
```json
{
  "source_method": "enterprise-builder",
  "trigger_reason": "post-delivery-monitoring",
  "enterprise_context": {
    "delivery_report_path": "docs/enterprise-plan/phase8-delivery-report.md",
    "adr_directory": "docs/enterprise-plan/phase5-adrs/",
    "nfr_targets": {
      "coverage_target": 99,
      "latency_p95_ms": 100,
      "availability_sla": "99.99%",
      "compliance_standards": ["PCI-DSS", "GDPR"]
    },
    "residual_risks": [
      "Cache invalidation under high load not fully tested",
      "Rate limiting implementation pending"
    ]
  }
}
```

### IRIS Adaptation
1. **Fase 1:** Read the delivery report and ADRs. Ingest the full delivered system.
2. **Fase 2:** Establish baseline metrics for the delivered system. Focus on residual risks from Enterprise Builder.
3. **Fase 3:** Create a monitoring and improvement roadmap:
   - Immediate iterations: address residual risks
   - Ongoing: monitoring schedule with defined degradation thresholds
4. **Fase 4:** Address residual risks (if any are CRITICAL or IMPROVABLE)
5. **Fase 5:** Activate monitoring mode. IRIS runs periodic abbreviated cycles.

### Ongoing Monitoring Behavior
After the initial cycle:
- Weekly: Run abbreviated Fase 1 + Fase 2 (metrics only)
- If threshold crossed: trigger new full IRIS cycle
- After each full cycle: update Enterprise Builder's risk matrix with findings

### What IRIS Returns (`IRIS_OUTPUT.json` for Enterprise Builder)
```json
{
  "target_method": "enterprise-builder",
  "next_action": "monitor",
  "enterprise_builder_feedback": {
    "nfr_adjustments_suggested": [
      "Rate limiting implementation should be promoted to Phase 4 microtask"
    ],
    "new_risks_identified": [
      "Cache invalidation timing under concurrent writes — not in original STRIDE"
    ],
    "adr_updates_recommended": [
      "ADR-003 (caching strategy) — add cache invalidation protocol"
    ]
  },
  "next_cycle_triggers": {
    "coverage_threshold": 90,
    "complexity_threshold": 20,
    "manual_conditions": [
      "New compliance requirement added",
      "Major dependency update (major version)",
      "Significant feature addition"
    ]
  }
}
```

---

## Protocol 3: Receiving from Modular Design (Architecture Health Check)

### Trigger Condition
Modular Design detects violations of the Core/Pack architecture contracts: circular dependencies between packs, business logic contaminating Core, Pack-to-Pack direct coupling that should route through Core interfaces.

### What Modular Design Provides (`IRIS_INPUT.json`)
```json
{
  "source_method": "modular-design",
  "trigger_reason": "architecture-health-check",
  "architecture_context": {
    "core_path": "core/",
    "packs_path": "packs/",
    "circular_dependencies": [
      "packs/payment-pack → packs/fraud-pack → packs/payment-pack"
    ],
    "contract_violations": [
      "packs/fraud-pack imports directly from packs/payment-pack (should use core interface)",
      "core/engine.js contains fraud detection logic (domain logic in Core)"
    ],
    "coupling_metrics": {
      "average_afferent_coupling": 4.2,
      "average_efferent_coupling": 3.8,
      "instability_index": 0.47
    }
  }
}
```

### IRIS Adaptation
1. **Fase 1:** Map the Core/Pack structure completely. Read `core/` and each `packs/` directory.
2. **Fase 2:** Focus architecture assessment on the violations listed. Quantify coupling.
3. **Fase 3:** Plan refactoring that:
   - Preserves all existing public interfaces (no breaking changes to callers)
   - Adds contract tests for any interface that changes
   - Documents the correct dependency direction
4. **Fase 4:** Implement with care: every iteration must leave the system in a working state.
5. **Fase 5:** Verify architectural health metrics improved. Return to Modular Design.

### What IRIS Returns (`IRIS_OUTPUT.json` for Modular Design)
```json
{
  "target_method": "modular-design",
  "next_action": "handoff-to-modular-design",
  "modular_design_feedback": {
    "resolved_violations": [
      "Circular dependency broken: introduced FraudCheckService interface in core/",
      "Fraud detection logic moved from core/engine.js to packs/fraud-pack/"
    ],
    "new_pack_suggestions": [
      "Consider extracting packs/risk-assessment-pack/ from packs/fraud-pack/ (SRP violation found)"
    ],
    "core_contamination_resolved": [
      "core/engine.js: fraud detection logic (120 LOC) moved to packs/fraud-pack/engine.js"
    ]
  }
}
```

---

## Protocol 4: Standalone Operation

### Trigger Condition
User activates IRIS directly with `/iris:analyze`, `/iris:full`, or `/iris:monitor` with no `IRIS_INPUT.json` present.

### Behavior
- No context pre-loaded
- Standard 5-phase cycle from scratch
- `IRIS_OUTPUT.json` generated at end of cycle with `target_method: "none"`
- `IRIS_LOG.md` created/updated in project root

### Output at Cycle Completion
```json
{
  "target_method": "none",
  "next_action": "next-iris-cycle",
  "next_cycle_triggers": {
    "coverage_threshold": 90,
    "complexity_threshold": 20,
    "manual_conditions": ["Significant code change", "New team member onboarding"]
  }
}
```

---

## Handoff Validation Checklist

Before generating `IRIS_OUTPUT.json`:
- [ ] `schema_version` matches current IRIS version (2.1.0)
- [ ] `cycle_number` is correct (check IRIS_LOG.md)
- [ ] `metrics_before` and `metrics_after` are both populated
- [ ] All `improvements_made` have IDs in format `IMP-NNNN`
- [ ] `remaining_issues` lists everything from Fase 2 not addressed
- [ ] `next_cycle_triggers` are defined with specific, measurable conditions
- [ ] `handoff_context.focus_areas` is useful to the receiving method (not generic)
- [ ] `handoff_context.avoided_pitfalls` documents actual failures (not theoretical ones)

---

## Error Cases

### IRIS_INPUT.json present but invalid
- Warn: "IRIS_INPUT.json found but does not validate against schema v2.1.0"
- Proceed as standalone — do not fail
- Note the validation errors in the Fase 1 report for the user to fix

### Circular handoff detected
- IRIS receives input from PDCA-T, produces output for PDCA-T, PDCA-T immediately escalates back
- If this happens twice: STOP. Report: "Two-cycle escalation loop detected. Manual architectural review required."
- Do not continue automated handoffs — flag for human intervention

### Version mismatch
- `handoff-input.json` schema_version doesn't match current IRIS version
- If minor version difference: warn and proceed
- If major version difference: stop and ask user to update the source method's handoff format
