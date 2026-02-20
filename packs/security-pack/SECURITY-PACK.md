# IRIS Security Pack
# Fase 2 Extension — Deep Security Analysis

## Purpose

Extends IRIS Fase 2 with a systematic security analysis using STRIDE threat modeling and OWASP Top 10 mapping. Produces security-specific findings that integrate into the standard Fase 2 quality report.

## Activation

- `/iris:analyze --security` — activates this pack alongside standard Fase 2
- Auto-activated when: source code contains auth, payment, crypto, session, or token-related modules
- Can be applied to a specific module: `/iris:analyze src/auth/ --security`

## Analysis Dimensions

---

### Dimension S1: STRIDE Threat Modeling

For each **module** that handles user input, authentication, data persistence, or external communication, complete a STRIDE analysis:

#### S — Spoofing (Identity Forgery)
Check for:
- Authentication bypass: is identity verified at all entry points?
- Token validation: are JWT signatures verified? Are session tokens checked?
- API key validation: are API keys checked for validity and not just presence?
- Password storage: is bcrypt/Argon2/scrypt used? Never MD5, SHA1, or plain text.
- Certificate validation: is TLS certificate pinning used where appropriate?

Findings format: `SEC-S-NNN | [file] | [line range] | [description] | [CRITICAL/IMPROVABLE]`

#### T — Tampering (Data Modification)
Check for:
- Integrity checks on data received from external sources
- HMAC or signature verification on webhooks/callbacks
- Database records: is there an audit trail for modifications?
- File upload handling: are uploaded files validated beyond filename extension?
- Serialization/deserialization: is untrusted data deserialized without type validation?

#### R — Repudiation (Denial of Actions)
Check for:
- Audit logging: are write operations (create, update, delete) logged with actor identity?
- Log completeness: do logs include timestamp, user ID, action, and affected resource?
- Log tamper-resistance: are logs written to append-only storage or external service?
- Non-repudiation for financial/legal operations: are actions signed or acknowledged?

#### I — Information Disclosure (Data Leaks)
Check for:
- Error messages: do they expose stack traces, database structure, or internal paths?
- Logging: are passwords, tokens, PII, or card numbers written to logs?
- API responses: does the API return more fields than the caller needs?
- Directory listings: are static file servers configured to disable directory browsing?
- Commented code: do comments contain credentials, internal URLs, or algorithm secrets?

#### D — Denial of Service (Resource Exhaustion)
Check for:
- Rate limiting: are endpoints protected against brute force and flooding?
- Pagination: are list endpoints bounded? Can a caller request unlimited records?
- Regex patterns: are complex regexes applied to user-controlled input (ReDoS risk)?
- File uploads: are file size limits enforced?
- External API calls: are timeouts and retry limits set?

#### E — Elevation of Privilege (Unauthorized Access Gain)
Check for:
- Authorization checks: is the caller's permission verified on every protected operation?
- Privilege escalation paths: can a regular user trigger admin-only functionality?
- IDOR (Insecure Direct Object Reference): are resource IDs validated against the current user's scope?
- Mass assignment: are POST/PUT endpoints protected against setting unexpected fields?
- Function-level authorization: is authorization checked per endpoint, not just per route group?

---

### Dimension S2: OWASP Top 10 Mapping

For each relevant OWASP category, assess the codebase:

#### A01: Broken Access Control
- Every endpoint/function that handles sensitive operations must verify authorization
- Horizontal access control: user A cannot access user B's resources
- Vertical access control: regular users cannot access admin functionality
- `Flag:` Any route without authorization check, any resource fetch without ownership verification

#### A02: Cryptographic Failures
- Sensitive data in transit: is TLS enforced? Is HTTP allowed?
- Sensitive data at rest: are passwords hashed? Are PII fields encrypted?
- Cryptographic algorithms: flag MD5, SHA1, DES, RC4, ECB mode
- Key management: are encryption keys in source code or environment variables?

#### A03: Injection
- SQL: string concatenation in queries → must use parameterized queries or ORM
- NoSQL: unsanitized objects passed to MongoDB/Mongoose queries
- Command injection: user input in shell commands (os.exec, subprocess, child_process)
- LDAP injection: user input in LDAP filter strings
- XPath injection: user input in XPath expressions
- `Flag:` Any query or command construction that includes unsanitized user input

#### A04: Insecure Design
- Threat model absence: flag modules with no evident security consideration
- Business logic flaws: can users manipulate prices, quantities, or IDs to their advantage?
- Security controls bypassed by design: flag race conditions in security-sensitive flows

#### A05: Security Misconfiguration
- Default credentials: flag any default passwords in configuration
- Debug mode: flag debug flags that should not be in production configuration
- Error handling: flag bare exception handlers that expose internal details
- CORS: flag wildcard CORS origins (`*`) on APIs handling authenticated requests
- Security headers: note absence of CSP, HSTS, X-Frame-Options where applicable

#### A06: Vulnerable and Outdated Components
- Check manifest for obviously outdated packages (major version lag)
- Flag packages known for historical CVEs in the relevant version range
- Note packages that have been deprecated in favor of secure alternatives

#### A07: Identification and Authentication Failures
- Password policy: is there a minimum length enforcement?
- Brute force protection: account lockout or rate limiting on login?
- Session management: fixed session IDs, session not regenerated after login?
- Multi-factor: is MFA available for privileged operations?

#### A08: Software and Data Integrity Failures
- Dependency integrity: are package lock files committed? Is SRI used for CDN resources?
- Deserialization: is untrusted serialized data deserialized? (pickle, JSON.parse on untrusted input, PHP unserialize)
- Auto-update mechanisms: are software updates verified before installation?

#### A09: Security Logging and Monitoring Failures
- Security events logged: failed logins, permission denials, input validation failures
- Log format: are logs structured and queryable?
- Alerting: is there any mechanism for detecting anomalous patterns?

#### A10: Server-Side Request Forgery (SSRF)
- URL fetch from user input: any feature that fetches external URLs based on user-provided input
- Internal metadata: can a user trigger requests to `169.254.169.254` or `localhost`?
- URL validation: is there an allowlist of permitted fetch domains?

---

### Dimension S3: Secrets and Credentials Scan

Search for these patterns in all source files (including tests, config files, scripts):

**High priority patterns:**
- Assignments to variables named: `password`, `passwd`, `secret`, `token`, `api_key`, `apikey`, `api_secret`, `auth_key`, `private_key`, `access_key`, `client_secret`
- Hardcoded connection strings: `mongodb://`, `postgresql://`, `mysql://`, `redis://` with embedded credentials
- AWS/cloud credentials: `AKIA`, `AWS_SECRET`, `AWS_ACCESS_KEY`
- Generic high-entropy strings: long base64 strings or hex strings assigned to variables with security-related names

**Check also:**
- `.env` files committed (should be in `.gitignore`)
- `*.pem`, `*.key`, `*.p12` files committed
- SSH keys in repository

---

### Dimension S4: Input Validation Matrix

For each external input boundary, fill this matrix:

| Endpoint / Handler | Input Source | Type Check | Range Check | Sanitized | Encoded Output |
|--------------------|--------------|------------|-------------|-----------|----------------|
| `POST /api/users` | HTTP body | ✅/❌ | ✅/❌ | ✅/❌ | ✅/❌ |
| [each endpoint] | | | | | |

External input sources to cover:
- HTTP request body, query parameters, headers, path parameters
- Environment variables read at runtime
- File system reads (filenames from user input)
- Database results (if later rendered as HTML)
- CLI arguments
- WebSocket messages
- Message queue payloads

---

## Output Format (appended to Fase 2 Report)

```markdown
## Security Pack Analysis (Fase 2 Extension)

### STRIDE Risk Summary
| Threat | Severity | Findings | Top Risk |
|--------|----------|----------|----------|
| Spoofing | CRITICAL / HIGH / MED / LOW | [N] | [brief] |
| Tampering | | [N] | |
| Repudiation | | [N] | |
| Information Disclosure | | [N] | |
| Denial of Service | | [N] | |
| Elevation of Privilege | | [N] | |

### OWASP Top 10 Coverage
| Category | Status | Findings |
|----------|--------|----------|
| A01: Broken Access Control | ✅ Clear / ⚠️ Concerns / ❌ Violations | [N] |
[... all 10 categories ...]

### Critical Security Findings
| ID | Category | File | Lines | Issue | Remediation |
|----|----------|------|-------|-------|-------------|
| SEC-001 | A03: Injection | src/db/query.js | 45–52 | SQL string concat | Use parameterized queries |

### Secrets Detected
| File | Type | Line | Action Required |
|------|------|------|-----------------|
[If none: "No secrets detected in source files" ✅]

### Input Validation Gaps
[Matrix from Dimension S4 for all identified endpoints]

### Security Recommendations (Priority Order)
1. [Highest priority first — always fix injection and auth bypass first]
```
