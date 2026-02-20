# IRIS Performance Pack
# Fase 2 Extension — Deep Performance Analysis

## Purpose

Extends IRIS Fase 2 with static performance analysis. Identifies algorithmic inefficiencies, database query patterns, concurrency issues, and scalability bottlenecks observable from code alone (no profiling required).

## Activation

- `/iris:analyze --performance` — activates alongside standard Fase 2
- Auto-activated when: NFR document specifies latency/throughput targets, or codebase contains database access, HTTP clients, or async patterns
- Can be scoped: `/iris:analyze src/api/ --performance`

## Analysis Dimensions

---

### Dimension P1: Algorithmic Complexity

For each function or method, estimate time and space complexity from code structure:

#### Nested Loop Detection
```
Risk levels:
- O(n²): two nested loops over same collection → flag if collection is unbounded
- O(n³): three nested loops → always flag
- O(n log n) or better: acceptable
```
Look for: `for` loops inside `for` loops, `forEach` inside `forEach`, nested `map/filter` chains.

**Flag:** Any nested loop where the outer collection is user-controlled or database-sourced.

#### Unbounded Collection Operations
Operations on collections without size limits applied before the operation:
- Sorting a collection from a database query without `LIMIT`
- Loading all records from a table, then filtering in memory
- Building a list from a recursive function without depth limit

#### Recursive Functions Without Depth Bounds
- Recursive functions with no maximum depth parameter
- Tree traversal without cycle detection
- Graph traversal without visited tracking

#### String/Array Operations in Loops
- String concatenation in a loop using `+` (creates new string each iteration) → use join/builder
- Array push in a loop when the final size is known (pre-allocate)
- RegExp.exec() or match() inside a loop (re-compile flag missing)

---

### Dimension P2: Database Query Patterns (Static)

Detectable from code without executing queries:

#### N+1 Query Pattern
```
// N+1 pattern (bad):
for (const user of users) {
  const orders = await db.orders.findMany({ where: { userId: user.id } })  // N queries
}

// Better: single query with JOIN or batch fetch
```

**Detection:** A database/ORM call inside a loop body. Even one occurrence is worth flagging.

**Languages/ORMs to check:**
- JavaScript: Prisma, Sequelize, TypeORM, Mongoose queries inside `for`, `forEach`, `map`
- Python: SQLAlchemy `session.query()`, `Model.objects.filter()` inside loops
- Go: `db.QueryRow()`, `db.Query()` inside loops
- Ruby: ActiveRecord `find()`, `where()` inside loops
- Java: JPA `entityManager.find()`, `repository.findById()` inside loops

#### Missing Pagination
List endpoints that return collections without applying LIMIT/OFFSET or cursor-based pagination:
- `findAll()`, `find({})`, `SELECT * FROM table` without a LIMIT clause
- REST endpoints `/api/users` returning the full table

**Flag:** Any query fetching a potentially unbounded list.

#### Missing Indexes (Inferred)
If query patterns are visible, flag queries that filter or sort on non-primary-key fields where an index is likely missing:
- `WHERE non_pk_field = ?` — index needed if this table is large
- `ORDER BY non_pk_field` — index improves sort performance

Note: this requires knowledge of the database schema. If schema files exist, read them.

#### Unscoped Transactions
- Write operations outside explicit transactions where atomicity is required
- Multiple sequential writes that should succeed or fail together

---

### Dimension P3: Resource Management

#### Connection Pool Issues
- Database connections opened without pool management
- HTTP clients instantiated inside request handlers (connection overhead per request)
- File descriptors opened without guaranteed close (`try/finally` or `with` / `defer`)

**Good pattern (Python):**
```python
with open("file.txt") as f:   # guaranteed close
    data = f.read()
```

**Bad pattern:**
```python
f = open("file.txt")           # may not close on exception
data = f.read()
```

#### Memory Leak Patterns
- Event listeners attached inside functions without corresponding removal
- Caches without eviction policy (unbounded map growth)
- Circular references in languages without automatic cycle collection

#### I/O in Hot Paths
- File system reads inside request handlers that could be cached
- Synchronous file reads (`fs.readFileSync`, `open()` in blocking mode) in async contexts
- Repeated reads of the same file within a single request lifecycle

---

### Dimension P4: Concurrency and Async Patterns

#### Blocking Operations in Async Contexts
Synchronous/blocking calls inside async functions negate the concurrency benefit:
- `time.sleep()` in Python async function (should be `await asyncio.sleep()`)
- `fs.readFileSync()` in Node.js async function (should be `await fs.readFile()`)
- CPU-intensive computation in Go goroutines without worker pool
- Database calls not awaited in JavaScript async functions

#### Race Conditions (Static Detection)
- Shared mutable state accessed from multiple goroutines/threads without synchronization
- Check-then-act patterns: `if !exists { create }` without atomic operation or lock
- Counter increments (`count++`) outside synchronized blocks in concurrent code

#### Promise/Future Anti-patterns
- `await` in a loop when operations could be parallelized with `Promise.all` / `asyncio.gather`
- Unhandled promise rejections (`.then()` without `.catch()`)
- `async` functions that don't actually await anything (unnecessary overhead)

#### Sequential vs Parallel Opportunities
```javascript
// Sequential (slow):
const userA = await fetchUser(idA)
const userB = await fetchUser(idB)

// Parallel (fast):
const [userA, userB] = await Promise.all([fetchUser(idA), fetchUser(idB)])
```

Flag any sequential async calls on independent resources that could be parallelized.

---

### Dimension P5: Caching Opportunities

Identify hot paths that lack caching:
- Configuration loaded from files on every request
- Database lookups for reference data that rarely changes (country list, currency codes, product categories)
- Expensive computations repeated with the same inputs
- External API calls for data that could be cached with TTL

For each identified opportunity, note: what to cache, appropriate TTL, invalidation strategy.

---

### Dimension P6: Scalability Bottlenecks

Identify patterns that prevent horizontal scaling:
- In-memory session state (scaling requires sticky sessions or external session store)
- In-memory cache (each instance has separate cache — use Redis/Memcached for shared cache)
- Scheduled jobs that run on every instance simultaneously (needs distributed locking)
- Single-threaded synchronous HTTP server in Node.js/Python blocking event loop
- Stateful WebSocket connections without coordination mechanism

---

## Output Format (appended to Fase 2 Report)

```markdown
## Performance Pack Analysis (Fase 2 Extension)

### Algorithmic Complexity Issues
| ID | File | Lines | Pattern | Complexity | Impact |
|----|------|-------|---------|------------|--------|
| PERF-001 | src/reports.js | 45–78 | Nested loop on unbounded list | O(n²) | High — grows with user count |

### Database Query Issues
| ID | File | Lines | Pattern | Impact | Fix |
|----|------|-------|---------|--------|-----|
| PERF-010 | src/orders/service.js | 23–31 | N+1: order fetch inside user loop | +N queries per request | Batch with JOIN or .include() |

### Resource Management Issues
| ID | File | Lines | Issue |
|----|------|-------|-------|

### Concurrency Issues
| ID | File | Lines | Issue | Risk |
|----|------|-------|-------|------|

### Caching Opportunities
| Data | Current | Recommended Cache | TTL | Invalidation |
|------|---------|-------------------|-----|--------------|

### Scalability Concerns
| ID | Issue | Blocking to Scale? | Recommended Fix |
|----|-------|--------------------|-----------------|

### Performance Recommendations (Priority Order)
1. N+1 queries — highest ROI: single change eliminates N database round trips
2. [next recommendation]
```
