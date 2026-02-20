# IRIS Example: Integration with Enterprise Builder
## Post-Delivery Monitoring for an E-Commerce Platform

**Scenario:** Enterprise Builder Fases 1–8 complete. A multi-tenant e-commerce platform delivered. IRIS enters monitoring mode.

**IDE:** Cursor | **Methods:** Enterprise Builder + IRIS

---

## Context

Enterprise Builder delivered a Go e-commerce platform:
- 18,000 LOC
- 6 services: catalog, orders, payments, users, notifications, gateway
- 94% test coverage at delivery
- 3 residual risks logged in Phase 8

---

## Enterprise Builder Phase 8 Output → IRIS_INPUT.json

```json
{
  "schema_version": "2.1.0",
  "source_method": "enterprise-builder",
  "trigger_reason": "post-delivery-monitoring",
  "context": {
    "repository_path": ".",
    "project_name": "ecommerce-platform",
    "previous_cycle_number": 0
  },
  "current_metrics": {
    "test_coverage": 94,
    "defect_density": 1.2,
    "architectural_health_index": 82
  },
  "enterprise_context": {
    "delivery_report_path": "docs/enterprise-plan/phase8-delivery-report.md",
    "adr_directory": "docs/enterprise-plan/phase5-adrs/",
    "nfr_targets": {
      "coverage_target": 99,
      "latency_p95_ms": 150,
      "availability_sla": "99.95%",
      "compliance_standards": ["PCI-DSS", "GDPR"]
    },
    "residual_risks": [
      "RISK-07: Cache invalidation under concurrent writes not tested at scale",
      "RISK-12: Rate limiting implementation is placeholder — real implementation pending",
      "RISK-18: GDPR data export endpoint returns all fields — PII filtering not implemented"
    ]
  },
  "requested_focus": ["security", "performance", "architecture"],
  "timestamp": "2026-02-20T09:00:00Z"
}
```

---

## IRIS Cycle #1 — Baseline + Residual Risk Resolution

### Command: `/iris:analyze --security --performance`

---

### IRIS Fase 1 Report — Context Acquisition

**Tech Stack detected:**
- Runtime: Go 1.21
- Web framework: Gin
- Database: PostgreSQL via pgx + Redis cache
- Test framework: Go testing + testify
- CI/CD: GitHub Actions (`.github/workflows/`)

**Enterprise Builder artifacts found:**
- `docs/enterprise-plan/phase8-delivery-report.md` ✅
- `docs/enterprise-plan/phase5-adrs/` — 12 ADRs ✅
- `docs/enterprise-plan/phase2-nfrs.md` ✅

**Previous IRIS cycles:** None (first cycle)

---

### IRIS Fase 2 Report — Quality Assessment

**Focused on residual risks from Enterprise Builder:**

**RISK-07: Cache invalidation (Performance Pack)**
```
Finding: internal/catalog/cache.go:145–178
Pattern: Redis SET without invalidation on catalog updates
Scenario: UPDATE catalog SET price=X; cache still has old price for up to 5 minutes
Test gap: no concurrent write test in catalog_test.go
Category: IMPROVABLE
```

**RISK-12: Rate limiting (Security Pack — A10: DoS)**
```
Finding: internal/gateway/middleware.go:89
Pattern: rate limiter initialized with in-memory map (single-instance only)
Impact: horizontal scaling breaks rate limiting (each pod has independent state)
Category: CRITICAL (blocks production scaling)
```

**RISK-18: GDPR data export (Security Pack — A02: Cryptographic Failures / A01: Broken Access Control)**
```
Finding: internal/users/export.go:45–78
Pattern: SELECT * FROM users exported directly as JSON
Impact: exports raw password_hash, internal_id, stripe_customer_id — all unnecessary
GDPR violation: data minimization principle violated
Category: CRITICAL
```

**Additional findings (not in residual risks):**
- `internal/orders/service.go:230`: N+1 query when loading order items (Performance Pack)
- `internal/catalog/handler.go:112`: Missing pagination on `/api/products` endpoint

**Metrics Dashboard:**
| Metric | Value | Target | Grade |
|--------|-------|--------|-------|
| Defect Density | 1.2 | <1.0 | ⚠️ Good |
| Test Coverage | 94% | ≥99% | ⚠️ High |
| Complexity Score | 11.8 | <12 | ✅ Excellent |
| Tech Debt Ratio | 4.8% | <5% | ✅ Healthy |
| Arch Health Index | 82 | ≥90 | ⚠️ Good |

**Composite Health:** 3.2/4.0 — Professional

---

### IRIS Fase 3 Report — Improvement Roadmap

**Iteration 1: GDPR + Rate Limiting (Critical)**
- Files: `internal/users/export.go`, `internal/gateway/middleware.go`, Redis integration
- LOC: +95 / -45 (~140 total)
- DoD: [ ] Export only 8 allowed fields | [ ] Rate limiter uses Redis | [ ] All tests pass

**Iteration 2: Cache Invalidation**
- Files: `internal/catalog/cache.go`, `internal/catalog/service.go`, `catalog_test.go`
- LOC: +85 / -20 (~105 total)
- DoD: [ ] Cache invalidated on UPDATE | [ ] Concurrent write test added

**Iteration 3: N+1 Fix + Pagination**
- Files: `internal/orders/service.go`, `internal/catalog/handler.go`
- LOC: +70 / -35 (~105 total)
- DoD: [ ] Order items loaded in single JOIN | [ ] Products endpoint has cursor pagination

**Iteration 4: Coverage to 99%**
- After architecture fixed, write tests for remaining 5% gap

---

### IRIS Fase 4 — Iteration 1: GDPR + Rate Limiting

**GDPR fix (export.go):**
```go
// Allowed export fields (data minimization — GDPR Art. 5(1)(c))
var exportableFields = map[string]bool{
    "id": true, "email": true, "name": true,
    "created_at": true, "country": true,
}

func ExportUserData(userID uuid.UUID) ExportPayload {
    user := repo.GetUser(userID)
    // Only include fields the user is entitled to see
    return ExportPayload{
        ID:        user.ID,
        Email:     user.Email,
        Name:      user.Name,
        CreatedAt: user.CreatedAt,
        Country:   user.Country,
        // password_hash, stripe_customer_id, internal_id — NOT included
    }
}
```

**Rate limiter fix (middleware.go):**
```go
// Before: in-memory map (breaks with multiple pods)
// After: Redis-backed rate limiter (shared state across all pods)
func RateLimiter(redisClient *redis.Client) gin.HandlerFunc {
    return func(c *gin.Context) {
        key := "rate:" + c.ClientIP()
        count, _ := redisClient.Incr(ctx, key).Result()
        if count == 1 {
            redisClient.Expire(ctx, key, time.Minute)
        }
        if count > 100 { // 100 requests per minute
            c.AbortWithStatus(http.StatusTooManyRequests)
            return
        }
        c.Next()
    }
}
```

**Test results:** 847 tests, 847 passed ✅ | Coverage: 94% → 95%

---

### IRIS Fase 5 — Verification + Monitoring Mode Activation

**Metrics after Cycle #1:**
| Metric | Before | After | Delta | Target |
|--------|--------|-------|-------|--------|
| Defect Density | 1.2 | 0.7 | -0.5 ✅ | <1.0 |
| Test Coverage | 94% | 96% | +2% | ≥99% |
| Complexity Score | 11.8 | 11.4 | -0.4 | <12 |
| Tech Debt Ratio | 4.8% | 3.1% | -1.7% ✅ | <5% |
| Arch Health Index | 82 | 85 | +3 | ≥90 |

**Residual risks resolved:** RISK-07 ✅, RISK-12 ✅, RISK-18 ✅

**MONITORING MODE ACTIVATED**

```
Weekly monitoring schedule: every Monday 09:00
Degradation thresholds:
  - Coverage < 87% (current 96%, 9pp buffer)
  - Defect Density > 1.0 (current 0.7)
  - Complexity Score > 15 (current 11.4)
  - Any new CRITICAL finding

Next full cycle trigger: any threshold crossed OR new major feature deployment
```

---

## Enterprise Builder Feedback (IRIS_OUTPUT.json excerpt)

```json
{
  "target_method": "enterprise-builder",
  "next_action": "monitor",
  "enterprise_builder_feedback": {
    "nfr_adjustments_suggested": [
      "RISK-12 resolution requires Redis — add Redis to NFR infrastructure requirements for future projects",
      "Coverage target 94% was achieved but NFR stated 99% — increase Phase 4 coverage NFR to 99%"
    ],
    "new_risks_identified": [
      "N+1 pattern in orders service not in original STRIDE — add database access patterns to threat modeling template",
      "Products endpoint missing pagination — add bounded response size to API NFR template"
    ],
    "adr_updates_recommended": [
      "ADR-004 (caching strategy): add cache invalidation protocol for write operations",
      "ADR-009 (rate limiting): update to specify distributed implementation requirement"
    ]
  }
}
```

**Key takeaway:** IRIS absorbed the post-delivery quality responsibility from Enterprise Builder, resolved all residual risks, and now runs as an autonomous quality guard — feeding findings back to improve future Enterprise Builder planning cycles.
