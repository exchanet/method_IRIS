# IRIS Architecture Pack
# Fase 2 Extension — Deep Architectural Analysis

## Purpose

Extends IRIS Fase 2 with a comprehensive architectural quality analysis using SOLID principles, coupling/cohesion metrics, package design principles, and technical debt mapping. Produces actionable architectural findings integrated into the standard Fase 2 quality report.

## Activation

- `/iris:analyze --architecture` — activates alongside standard Fase 2
- Auto-activated when: Modular Design method detected, AHI < 60, or codebase is Large/Enterprise size
- Particularly valuable when: planning a refactoring sprint, evaluating architectural health before a major feature

---

## Analysis Dimensions

### Dimension A1: SOLID Principles Assessment

#### S — Single Responsibility Principle
**Test:** Can you describe what this class/module does in one sentence without using "and"?

Violation indicators:
- Class with more than 5–7 public methods spanning unrelated concerns
- Module that imports from 3+ different infrastructure layers (database AND HTTP AND filesystem)
- File name that uses "Manager", "Handler", "Utility", "Helper" (common SRP violation signals)
- Constructor injection of more than 4–5 dependencies

For each violation: identify the distinct responsibilities and name them. Each will become a separate class in the refactoring plan.

#### O — Open/Closed Principle
**Test:** Adding a new type/case requires modifying existing code?

Violation indicators:
- Long `switch` or `if-else if` chains that check type fields: `if type == "A" else if type == "B"`
- Conditionals with `instanceof` checks in multiple places
- Adding a new feature requires editing an existing core class

OCP-friendly patterns (detect as positives):
- Strategy pattern (behavior passed as parameter)
- Plugin/registry pattern (behaviors registered, not hardcoded)
- Polymorphism (method dispatch based on type, not manual checking)

#### L — Liskov Substitution Principle
**Test:** Can a subclass be used anywhere the parent is used without behavioral surprises?

Violation indicators:
- Override methods that throw `NotImplementedException` or return completely different behavior
- Subclass that removes constraints the parent had (e.g., parent requires non-null, subclass allows null)
- Tests that check `instanceof` before calling a method

#### I — Interface Segregation Principle
**Test:** Are clients forced to depend on methods they don't use?

Violation indicators:
- Interface with more than 5–7 methods where no single client uses all of them
- Abstract base class with many abstract methods, each subclass only implementing a subset
- Method signatures with many optional/nullable parameters

#### D — Dependency Inversion Principle
**Test:** Does high-level code depend on concrete low-level implementations?

Violation indicators:
- Business logic classes directly instantiating database connections, HTTP clients, or file readers
- `new DatabaseRepository()` or `new HttpClient()` inside domain/service classes
- Imports from infrastructure layers directly into domain/business layers
- Hard-coded class instantiation in factory methods where injection should be used

---

### Dimension A2: Coupling Analysis

#### Afferent Coupling (Ca)
Number of modules that depend on this module. High Ca = this module is widely used = high change risk.

For each module, count: how many other source files import this file?

| Module | Ca | Risk |
|--------|----|------|
| [path] | [N] | HIGH if Ca > 10 |

#### Efferent Coupling (Ce)
Number of modules this module depends on. High Ce = this module knows too much = fragile.

For each module, count: how many other source files does this file import?

| Module | Ce | Risk |
|--------|----|------|
| [path] | [N] | HIGH if Ce > 10 |

#### Instability Index
```
I = Ce / (Ca + Ce)
```
- I near 0: Stable (many dependents, few dependencies) — should be abstract/interfaced
- I near 1: Unstable (few dependents, many dependencies) — OK for leaf implementations
- Problem: high Ca + high Ce simultaneously (god module)

#### Circular Dependencies
Trace import chains. A cycle of any length is a finding.

```
Module A imports B → B imports C → C imports A  ← CIRCULAR (flag)
```

Document each cycle:
```markdown
**Cycle:** A → B → C → A
**Impact:** Cannot independently test, deploy, or version any of these modules
**Recommended break point:** [which import to invert or extract to a new module]
```

---

### Dimension A3: Cohesion Metrics

#### LCOM (Lack of Cohesion of Methods) — Conceptual Assessment
Without running static analysis tools, assess cohesion conceptually:

For each class/module:
1. List all public methods
2. Group methods by the data/state they operate on
3. If there are 2+ distinct groups → LOW cohesion → SRP likely violated

High cohesion indicators:
- All methods operate on the same state/data
- Methods all relate to the same business concept
- Removing any method leaves an incomplete concept

Low cohesion indicators:
- Two clearly distinct groups of methods that could exist independently
- Methods that take completely different parameter types
- Mix of "compute X" and "store X" in the same module

#### Data Cohesion
- Are related data fields grouped together in structs/classes?
- Is data that belongs together passed as a structured object or as 5+ separate parameters?

---

### Dimension A4: Layer Architecture Compliance

Identify the architecture layers from the directory structure and imports:

**Common patterns:**
- Layered: `controllers/` → `services/` → `repositories/` → `database/`
- Hexagonal: `domain/` ← `application/` ← `adapters/` ← `infrastructure/`
- Clean Architecture: `entities/` ← `use_cases/` ← `interface_adapters/` ← `frameworks/`

**Violations to flag:**

| Violation Type | Example |
|----------------|---------|
| Domain → Infrastructure | `domain/order.py` imports `db/postgres_connection.py` |
| Controller → Database | `api/routes.py` directly queries the database |
| Infrastructure → Domain | `db/repository.py` contains business validation rules |

For each violation: note the two files, the import direction, and what the correct approach would be.

---

### Dimension A5: Package Design Principles

For codebases using explicit package/module boundaries:

#### REP — Reuse/Release Equivalence Principle
Packages that are released together should be reused together. Flag: modules mixed in a package that have unrelated reuse patterns.

#### CCP — Common Closure Principle
Classes that change together should be grouped together. Flag: changes that always span multiple packages (indicates wrong grouping).

#### CRP — Common Reuse Principle
Classes that are not reused together should not be grouped. Flag: importing one class from a package forces importing unrelated classes.

#### ADP — Acyclic Dependencies Principle
The dependency graph must be acyclic. Flag: any package cycle.

#### SDP — Stable Dependencies Principle
Packages should depend in the direction of stability. Flag: stable packages depending on unstable ones.

---

### Dimension A6: Technical Debt Mapping

For the architectural issues found, estimate the debt:

```
Architectural Debt = sum of (
  cost to fix now × difficulty_multiplier
)

Where difficulty_multiplier:
  1.0 = isolated change (one module)
  2.0 = ripple effect (2–5 modules affected)
  3.0 = systemic change (6+ modules, may break public APIs)
  5.0 = architectural reset (affects entire layer or package structure)
```

Produce a debt map:

| Issue | Type | Difficulty | Fix Cost | Debt Cost | Priority |
|-------|------|------------|----------|-----------|----------|
| SRP violation in UserService | Refactoring | 1.0 | 4h | 4h | Medium |
| Circular deps A↔B↔C | Breaking cycle | 2.0 | 6h | 12h | High |

**Debt repayment strategy:**
- Fix isolated issues first (highest ROI)
- Break cycles before adding new modules (prevents compounding)
- Address DIP violations when adding new implementations (natural opportunity)

---

## Output Format (appended to Fase 2 Report)

```markdown
## Architecture Pack Analysis (Fase 2 Extension)

### SOLID Compliance Summary
| Principle | Violations | Severity | Impact |
|-----------|------------|----------|--------|
| S — Single Responsibility | [N] | | |
| O — Open/Closed | [N] | | |
| L — Liskov Substitution | [N] | | |
| I — Interface Segregation | [N] | | |
| D — Dependency Inversion | [N] | | |

### Coupling Analysis
| Module | Ca | Ce | Instability | Status |
|--------|----|----|-------------|--------|

**Circular Dependencies Detected:**
- [Cycle 1]: A → B → C → A — [break point recommendation]
- [Cycle 2]: ...

### Cohesion Assessment
| Module | Cohesion | Groups Found | Recommendation |
|--------|----------|--------------|----------------|

### Layer Violations
| File (caller) | Layer | Imports from | Layer | Violation type |
|---------------|-------|--------------|-------|----------------|

### Technical Debt Map
| Issue | Difficulty | Est. Fix Cost | Debt Level |
|-------|------------|---------------|------------|

**Total Architectural Debt Estimate:** [X hours]

### Architecture Recommendations (Priority Order)
1. Break circular dependencies — prevents cascading coupling
2. [next recommendation with specific files and approach]
```
