# IRIS Example: Full Ecosystem Demo
## All 4 Methods Working Together

**Scenario:** Building a fintech compliance reporting API from scratch to production with continuous improvement.

**Methods used:** Enterprise Builder → Modular Design → PDCA-T → IRIS (monitoring + escalation)
**IDEs:** Cursor (primary), Claude Code (review sessions)

---

## Timeline Overview

```
Week 1–2:   Enterprise Builder — Planning (Fases 1–4)
Week 3:     Modular Design — Architecture definition
Week 4–7:   PDCA-T — Implementation (micro-tasks)
Week 7:     IRIS — Coverage escalation (one module)
Week 8:     Enterprise Builder — Fases 5–8 (ADRs, delivery)
Week 9+:    IRIS — Post-delivery monitoring (ongoing)
```

---

## Phase 1: Enterprise Builder (Weeks 1–2)

**Trigger:** `/method-enterprise_builder`

**Produces:**
- Business context: GDPR + PCI-DSS compliant transaction report generator
- Tech stack decision: Python + FastAPI + PostgreSQL + Redis
- NFRs: ≥99% test coverage, p95 latency <200ms, SOC2 compliance
- Risk matrix: 14 risks identified (STRIDE + business risks)
- Micro-task DAG: 23 tasks across 4 domains (auth, reports, exports, compliance)

**Key ADR for IRIS:** ADR-003 — "All external service calls must use abstract interfaces to enable testing"
(This ADR was inspired by a previous IRIS finding — the ecosystem learns from itself)

---

## Phase 2: Modular Design (Week 3)

**Architecture designed:**
```
core/
├── interfaces.py       (AuthGateway, ReportEngine, ExportService)
├── validators.py       (shared domain validation)
└── exceptions.py       (domain exception hierarchy)

packs/
├── auth-pack/          (JWT, OAuth2, session management)
├── reports-pack/       (report generation, templating)
├── exports-pack/       (PDF, CSV, XLSX generation)
├── compliance-pack/    (GDPR, PCI-DSS rule engine)
└── notifications-pack/ (email, webhook alerts)
```

**Key design decision:** All packs communicate through Core interfaces. No Pack imports another Pack directly.

---

## Phase 3: PDCA-T (Weeks 4–7)

Each micro-task developed with PDCA-T:
- Plan → Requirements → Micro-task (≤50 LOC) → Validate → Deliver
- Coverage maintained at ≥99% per task

**Progress by week:**
- Week 4: auth-pack complete (99.2% coverage)
- Week 5: reports-pack core complete (99.1% coverage)
- Week 6: exports-pack started — problem encountered

**Problem at Week 6:** `exports-pack/pdf_generator.py` — coverage stuck at 81%

PDF generation calls `reportlab` library directly. Error paths (font not found, memory error, corrupt template) are tied to the library's internal behavior — impossible to trigger without mocking at a deep level.

---

## Phase 4: IRIS Coverage Escalation (Week 7)

PDCA-T escalates after 3 failed cycles at 81% coverage.

### IRIS_INPUT.json:
```json
{
  "source_method": "pdca-t",
  "trigger_reason": "coverage-escalation",
  "escalation_data": {
    "attempts_made": 3,
    "achieved_coverage": 81,
    "failure_reason": "reportlab error paths require deep library state manipulation — untestable as currently structured",
    "problematic_modules": [{
      "path": "packs/exports-pack/pdf_generator.py",
      "coverage": 81,
      "issue": "lines 89-134: reportlab calls cannot be intercepted"
    }]
  }
}
```

### IRIS Analysis:

**Root cause:** `PDFGenerator` uses `reportlab.platypus.SimpleDocTemplate` directly — no abstraction layer exists for error path testing.

**ADR-003 check:** This is exactly the pattern ADR-003 prohibits! The implementation violated an architectural decision.

### IRIS Fix:

**Iteration 1:** Introduce `PDFRenderer` abstract class + `ReportlabRenderer` concrete implementation

```python
# core/interfaces.py (updated — +15 LOC)
class PDFRenderer(ABC):
    @abstractmethod
    def render(self, content: ReportContent) -> bytes:
        """Render content to PDF bytes."""
        ...

# packs/exports-pack/reportlab_renderer.py (new — +60 LOC)
class ReportlabRenderer(PDFRenderer):
    def render(self, content: ReportContent) -> bytes:
        # All reportlab calls isolated here
        ...

# packs/exports-pack/pdf_generator.py (modified — -45 LOC, +20 LOC)
class PDFGenerator:
    def __init__(self, renderer: PDFRenderer = None):
        self.renderer = renderer or ReportlabRenderer()
```

**IRIS returns to PDCA-T:** "Inject MockPDFRenderer that raises exceptions on demand"

### PDCA-T Cycle 4 result:
```python
# Mock that simulates all error paths:
class MockPDFRenderer(PDFRenderer):
    def __init__(self, should_fail=False, error_type='generic'):
        self.should_fail = should_fail
        self.error_type = error_type
    
    def render(self, content):
        if self.should_fail:
            if self.error_type == 'memory':
                raise MemoryError("Out of memory")
            raise PDFRenderError("Render failed")
        return b"%PDF-1.4 mock content"

# Now testable:
def test_handles_memory_error():
    generator = PDFGenerator(renderer=MockPDFRenderer(True, 'memory'))
    with pytest.raises(ExportError, match="insufficient memory"):
        generator.generate_report(sample_report)
```

**exports-pack coverage: 81% → 99.4%** ✅

**Key learning recorded in IRIS_LOG.md:** "ADR-003 compliance should be verified in PDCA-T plan phase, not discovered at escalation"

---

## Phase 5: Enterprise Builder Fases 5–8 (Week 8)

Delivery report references IRIS for ongoing monitoring.

**Baseline metrics at delivery:**
- Defect Density: 0.8 ✅ (below 1.0 target)
- Test Coverage: 99.1% ✅
- Complexity Score: 10.4 ✅
- Tech Debt Ratio: 3.2% ✅
- Arch Health Index: 91 ✅ (above 90 target)

**First delivery to hit all 5 IRIS targets at delivery** — a result of the ecosystem working together.

---

## Phase 6: IRIS Monitoring Mode (Week 9+)

### Weekly monitoring results (first 4 weeks):

**Week 9:** All metrics stable ✅ — "healthy"
**Week 10:** Coverage dipped to 97.8% (new notification feature without full tests)
- Trigger threshold (87%) NOT crossed — logged as warning
- Recommendation: PDCA-T on notification-pack next sprint

**Week 11:** Coverage recovered to 99.0% after PDCA-T sprint ✅
**Week 12:** New compliance rule added — triggered full IRIS cycle

### IRIS Cycle #2 (triggered by new compliance rule):

New EU regulation requires transaction amounts rounded to 2 decimal places in reports. IRIS detects:
- 3 places in compliance-pack with float arithmetic not rounded
- 1 test that asserts exact float equality (brittle)
- No decimal precision documented in any ADR

**IRIS response:**
- Fase 2: flags precision issues
- Fase 3: plans iteration (fix float → Decimal, update 3 modules, add precision tests)
- Fase 4: implements in 1 iteration (210 LOC)
- Fase 5: verifies, updates IRIS_LOG.md, recommends new ADR

**IRIS_OUTPUT.json → Enterprise Builder:**
```json
{
  "enterprise_builder_feedback": {
    "adr_updates_recommended": [
      "Create ADR-014: Financial arithmetic must use Decimal type, not float"
    ],
    "new_risks_identified": [
      "No decimal precision standard existed — future financial calculations at risk"
    ]
  }
}
```

Enterprise Builder creates ADR-014. Future projects start with the lesson already captured.

---

## Ecosystem Intelligence Accumulation

After 12 weeks, the ecosystem has captured:
- IRIS_LOG.md: 2 cycles, 8 iterations, 34 improvements documented
- Enterprise Builder: 3 new ADRs from IRIS findings
- PDCA-T: ADR-003 compliance check added to plan phase checklist
- Modular Design: new interface-first pattern reinforced across all packs

**This is the compounding value of the ecosystem:** each method teaches the others. IRIS is the feedback loop.
