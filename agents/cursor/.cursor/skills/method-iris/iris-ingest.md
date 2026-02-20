# IRIS Fase 1: INGEST — Context Acquisition

## Objective

Build a complete, accurate mental model of the repository before any analysis begins. No assumptions. No guessing. Read first, conclude second.

## Inputs

- Repository path (from `/iris:analyze [path]` or current directory)
- `IRIS_INPUT.json` if present (pre-loaded by SKILL.md orchestrator)
- `IRIS_LOG.md` if present (previous cycle data)
- `IRIS_MEMORY.json` if present (semantic memory — rejected changes, intentional patterns, constraints)

## Step-by-Step Execution

### Step 1.1 — Dependency Manifest Detection

Read the project root directory. Look for dependency manifests to identify the primary language(s) and ecosystem:

| File Found | Language/Ecosystem |
|------------|--------------------|
| `package.json` | JavaScript / TypeScript (Node.js) |
| `requirements.txt` or `pyproject.toml` or `setup.py` | Python |
| `Cargo.toml` | Rust |
| `go.mod` | Go |
| `pom.xml` or `build.gradle` or `build.gradle.kts` | Java / Kotlin (JVM) |
| `Gemfile` | Ruby |
| `composer.json` | PHP |
| `.csproj` or `.sln` | C# / .NET |
| `CMakeLists.txt` or `Makefile` | C / C++ |
| `mix.exs` | Elixir |
| `pubspec.yaml` | Dart / Flutter |
| Multiple manifests | Monorepo — list all |

Read the manifest to extract:
- Project name and version
- Key dependencies (frameworks, ORMs, test libraries)
- Build scripts and test scripts (e.g., `"test": "jest"`, `"build": "tsc"`)

### Step 1.2 — Directory Structure Mapping

List the top-level directory. Then recurse into likely source directories:
- Common source roots: `src/`, `lib/`, `app/`, `cmd/`, `pkg/`, `internal/`, `source/`
- Common test locations: `test/`, `tests/`, `__tests__/`, `spec/`, `specs/`
- Common configuration: `config/`, `.env*`, `*.config.*`, `settings.*`
- Common documentation: `docs/`, `README*`, `CHANGELOG*`, `ADR/`, `decisions/`

Document the full structure to 2–3 levels deep.

### Step 1.3 — Entry Point Identification

Locate where the application starts executing. Search for:
- **Web servers:** `index.*`, `server.*`, `app.*`, `main.*` in source root
- **CLI tools:** `cli.*`, `cmd/main.*`, files with `argparse`/`yargs`/`cobra`/`clap` imports
- **Libraries:** exported public API files (`index.*`, `mod.*`, `lib.*`)
- **Serverless/event-driven:** `handler.*`, `lambda.*`, `functions/`, `trigger.*`
- **Workers/daemons:** `worker.*`, `daemon.*`, `service.*`

Read the entry point files to understand application structure.

### Step 1.4 — Tech Stack Profiling

From the manifest and entry points, document:

```markdown
### Tech Stack Profile
- Runtime: [Node 20 / Python 3.11 / Go 1.21 / JVM 17 / etc.]
- Primary framework: [Express / FastAPI / Gin / Spring Boot / Rails / Laravel / etc.]
- Secondary frameworks: [list any significant ones]
- Database: [PostgreSQL / MySQL / MongoDB / SQLite / Redis / none]
- ORM / Query builder: [Prisma / SQLAlchemy / GORM / Hibernate / etc.]
- Test framework: [Jest / Pytest / Go testing / JUnit / RSpec / PHPUnit / etc.]
- Test helpers: [supertest / httpx / testcontainers / factory-boy / etc.]
- Build tool: [npm / yarn / pnpm / poetry / cargo / gradle / maven / make]
- Linter: [ESLint / Ruff / golangci-lint / Checkstyle / RuboCop / etc.]
- Type system: [TypeScript / mypy / Go native / Java native / etc.]
- CI/CD: [GitHub Actions / GitLab CI / Jenkins / CircleCI / none — file location]
```

### Step 1.5 — Co-existing Methods Detection

Check for:
- `.cursor/rules/METHOD-PDCA-T.md` or `.cursor/rules/METODO-PDCA-T.md` → PDCA-T active
- `.cursor/rules/METHOD-ENTERPRISE-BUILDER-PLANNING.md` → Enterprise Builder active
- Directory `core/` containing infrastructure + `packs/` containing features → Modular Design active
- `docs/enterprise-plan/` directory → Enterprise Builder previously used
- `IRIS_LOG.md` in root → Previous IRIS cycles ran

### Step 1.6 — Artifact Collection

List and briefly describe:
- `README.md` or `README.*` — project documentation
- `CHANGELOG.md` or `HISTORY.md` — recent changes
- Architecture docs in `docs/architecture/` or `docs/adr/`
- `IRIS_LOG.md` — previous IRIS cycle history
- CI/CD configuration files
- Docker/container configuration
- API documentation (`openapi.yaml`, `swagger.json`, etc.)

### Step 1.7 — Previous Metrics Loading

If `IRIS_LOG.md` exists:
- Read the most recent cycle entry
- Extract: last metrics values, last cycle number, defined trigger conditions
- Note: "Resuming from Cycle #N"

If `IRIS_LOG.md` does not exist:
- Note: "First IRIS cycle — baseline metrics to be established in Fase 2"
- Cycle number = 1

### Step 1.9 — Semantic Memory Loading (IRIS_MEMORY.json)

**This step must run before analyzing any source file.**

If `IRIS_MEMORY.json` exists in project root:
1. Read and validate against `core/schemas/memory.json`
2. Load `intentional_patterns`:
   - Note the `scope` file of each pattern — REVIEW will tag these as NOTED instead of IMPROVABLE
   - Check `revisit_on` date for each entry: if `revisit_on ≤ today` → flag for user review at IDEATE start
3. Load `rejected_changes`:
   - Note the `proposed` action and `scope` of each entry — IDEATE will filter against these
   - Check `expires_on` date: if expired, the rejection is no longer active
4. Load `architectural_constraints`:
   - Note each `constraint` rule and its `applies_to` scope — these are hard limits IDEATE must not violate
5. Load `context_changes`:
   - If any recent context change affects existing rejected_changes → flag for user review at IDEATE start
6. Produce memory summary in Fase 1 output

If `IRIS_MEMORY.json` does not exist:
- Note: "No IRIS_MEMORY.json found — will create during IDEATE if decisions are made"
- Memory state = empty (no constraints, no rejected changes, no intentional patterns)

### Step 1.10 — Complexity Estimation

Based on what was found, estimate:
- **Simple:** <1,000 LOC, single module, no external dependencies
- **Medium:** 1,000–10,000 LOC, multiple modules, standard dependencies
- **Large:** 10,000–100,000 LOC, many modules, complex dependencies
- **Enterprise:** >100,000 LOC, requires sampling strategy in Fase 2

For Large and Enterprise codebases: define a sampling strategy for Fase 2 (which modules to analyze fully, which to sample).

## Output Format

Produce this exact report before advancing to Fase 2:

```markdown
## IRIS Fase 1 Report — Context Acquisition
**Cycle:** #[N] | **Date:** [date] | **Triggered by:** [source_method / command]

---

### Repository Profile
| Field | Value |
|-------|-------|
| Name | [project name] |
| Type | [Web API / CLI / Library / Mobile / Data pipeline / Monorepo] |
| Architecture | [Monolith / Layered / Hexagonal / Microservices / Unknown] |
| Complexity | [Simple / Medium / Large / Enterprise] |
| LOC estimate | [~N lines] |

### Tech Stack
| Component | Technology | Version |
|-----------|------------|---------|
| Runtime | | |
| Framework | | |
| Database | | |
| Test framework | | |
| Build tool | | |
| Linter | | |
| CI/CD | | |

### Entry Points
1. [path] — [description]
2. [path] — [description]

### Directory Structure
```
[top 2–3 levels of key directories]
```

### Co-existing Methods
| Method | Status |
|--------|--------|
| PDCA-T | [detected / not detected] |
| Enterprise Builder | [detected / not detected] |
| Modular Design | [detected / not detected] |
| Previous IRIS | [cycle #N / not detected] |

### Existing Artifacts
- [file] — [brief description]

### Baseline Metrics
[Loaded from IRIS_LOG.md: DD=[X], COV=[X%], CS=[X], TDR=[X%], AHI=[X]]
OR
[First cycle — baseline to be established in Fase 2]

---
### Memory Status
| Component | Count | Notes |
|-----------|-------|-------|
| Intentional patterns | [N] | [M] due for revisit |
| Rejected changes | [N] | [M] expired |
| Architectural constraints | [N] | — |

### Fase 1 Checklist
- [ ] Project type and architecture identified
- [ ] All source directories mapped
- [ ] Primary language(s) confirmed
- [ ] Frameworks and dependencies listed
- [ ] Entry points located
- [ ] Testing framework identified or confirmed absent
- [ ] Build and CI/CD tooling identified
- [ ] Co-existing methods detected
- [ ] Artifacts catalogued
- [ ] Previous metrics loaded or baseline noted
- [ ] IRIS_MEMORY.json loaded or confirmed absent

**→ Ready for Fase 2: REVIEW** ✅ / **→ Cannot proceed: [specific missing information]** ❌
```

## Special Cases

**Monorepo:** Document each package/workspace separately in the Tech Stack section. Treat each with its own entry points and test configuration.

**Legacy codebase with no documentation:** Note the absence explicitly. Fase 2 analysis becomes even more critical.

**IRIS_INPUT.json present:** Read it first. The source method has already done some context work. Reference it in the report and avoid re-doing work already captured there.
