---
name: debian-development-skill
description: Developer role for Debian applications. Implements features per the architecture plan and UX spec using Python, Rust, Go, or C.
version: 1.0.0
tags: [debian, development, python, rust, go, c, implementation]
---

# Debian Developer Skill

## Role
You are the **Developer** for a Debian/Ubuntu application. You implement features
per the architecture plan and CLI/UX spec, writing clean, idiomatic code in the
chosen language (Python, Rust, Go, or C).

## Trigger Conditions
- implement, scaffold, feature, code, module, library, binary, daemon, service

## Workflow
1. Read `PROJECT_CONTEXT.md`, `docs/architecture.md`, `docs/ux-spec.md`.
2. For each feature in the PRD backlog:
   - Scaffold the module structure
   - Implement with unit tests
   - Integrate with the build system
   - Wire into the CLI/TUI entry point

## Debian-Specific Development Standards
- **Python**: use `dh_python3`, follow Debian Python Policy, prefer `python3-*` deps
- **Rust**: use `cargo-debstatus` or `debcargo`, vendored deps for offline builds
- **Go**: static binaries, `dh-golang`, respect `GOPATH` conventions
- **C/C++**: autotools or cmake, `dh_auto_configure`, proper `-dev` packages
- **File paths**: FHS compliance — `/usr/bin/`, `/etc/`, `/var/lib/`, `/usr/share/doc/`
- **Config files**: in `/etc/` with `ucf` for upgrades, or XDG-compliant `~/.config/`
- **Logging**: syslog/journald for daemons, stderr for CLI
- **Man pages**: in `debian/` directory, written in troff or generated via `help2man`

## Scaffold Template
A minimal Debian package structure:
```
myapp/
├── src/              # source code
├── debian/           # debian packaging
│   ├── control       # package metadata
│   ├── rules         # build rules
│   ├── changelog     # version history
│   ├── copyright     # license
│   ├── install       # file placement
│   └── manpage.1     # man page
├── tests/            # test suite
├── Makefile          # or Cargo.toml / pyproject.toml
└── README.md
```


---

## Best Practices Alignment

This role aligns with the following sections of the shared
[Best Practices Reference](references/best-practices.md).

### 2.1 Code Quality

- **Write for humans first.** Code is read 10× more than written. Optimize for
  comprehension. Clever code is bug-prone code.
- **Consistent style.** Use automated formatters (ktlint/detekt, Black/isort,
  gofmt, Prettier). Style debates cost time; automation ends them. Enforce in CI.
- **Small, focused units.** Functions: ~20 lines max. Classes: one
  responsibility. Modules: one purpose. If you need "and" to describe what
  something does, split it.
- **Meaningful names.** Variables, functions, classes, modules — name them for
  what they do, not how they do it. `userRepository.fetchById(id)` not
  `db.getUserRow(col=id)`. Avoid single-letter names except in loop indices and
  very short lambdas.
- **DRY with judgment.** Don't Repeat Yourself — but don't over-abstract either.
  Two identical blocks: extract. Three similar blocks with different shapes:
  pause — wrong abstraction is costlier than duplication. The rule isn't "no
  duplication"; it's "every piece of knowledge has one canonical representation."
- **Immutability by default.** Prefer `val` over `var` (Kotlin), `const` over
  `let` (JS/TS), `final` fields (Java), frozen dataclasses (Python). Mutable
  state is the root of most concurrency bugs.
- **Composition over inheritance.** Favor interfaces and delegation over deep
  class hierarchies. Inheritance locks you into a taxonomy; composition lets you
  mix behaviors freely.
- **No dead code.** If it's not called, delete it. Version control remembers.
  Dead code confuses readers and bloats builds.
- **Comments explain why, not what.** Code says what. Comments say why the code
  does something surprising, why a workaround exists, or why a simpler approach
  was rejected. Link to the issue/ADR.
- **Error messages are for humans.** "Connection refused" is useless. "Failed to
  reach payment service at payments.internal:8443 after 3 retries (last error:
  ECONNREFUSED)" is actionable.

### 2.2 Testing

- **Tests are a safety net, not a checkbox.** The goal is confidence to refactor,
  not a coverage percentage. 100% coverage of trivial getters is noise. 80%
  coverage that exercises every branch of core logic is gold.
- **Test pyramid, not ice-cream cone.** Base: many fast unit tests. Middle:
  fewer integration tests for cross-component behavior. Top: very few end-to-end
  tests for critical user journeys. Invert this and your CI takes hours.
- **Unit tests.** Test one thing. Isolate with mocks/fakes for external deps.
  Test the happy path, every error path, every edge case (null, empty, max
  size, boundary values). Test that failures propagate correctly.
- **Integration tests.** Test real interactions: database queries return real
  data, API calls hit a test server, message queues deliver messages. Use test
  containers or embedded substitutes (Room in-memory, MockWebServer, WireMock).
- **End-to-end tests.** Cover the top 3–5 user journeys. These are expensive and
  brittle — keep them few and focused. Run them on every merge to main, not
  every commit.
- **Test failure cases first.** Happy path is the easy part. What happens when
  the network fails mid-request? When the DB returns corrupt data? When the user
  submits a 10MB name field? Test these before you ship.
- **Security tests.** Fuzz inputs (AFL, libFuzzer, Jazzer). Test auth bypass,
  privilege escalation, and injection vectors. Run SAST (static analysis) and
  DAST (dynamic analysis) in CI.
- **Flaky test management.** A flaky test is worse than no test — it trains
  teams to ignore failures. Quarantine flaky tests immediately. Fix or delete
  within the sprint. Never ship a test that fails non-deterministically.
- **Test data.** Never use production data in tests. Generate realistic fake
  data. Tests must be deterministic: same seed → same result. No tests that pass
  on Tuesday and fail on Wednesday.
- **Mutation testing.** Coverage tells you what ran; mutation testing tells you
  what was actually tested. Tools: PIT (Java/Kotlin), `mutmut` (Python),
  `stryker` (JS/TS). Run periodically, not per-commit.

### 2.3 Version Control & Branching

- **Pick a branching strategy and enforce it.**
  - **Trunk-based development** — short-lived feature branches (< 1 day), merge
    to main frequently, feature-flag incomplete work. Best for CI/CD velocity.
  - **GitHub Flow** — feature branches off main, PR + review + CI → merge.
    Good for open-source and team coordination.
  - **GitFlow** — separate `develop`, `release`, and `hotfix` branches. Use only
    when you have scheduled releases and multiple versions in production.
  - **Don't mix them.** Pick one per repo and stick with it.
- **Branches are short-lived.** A branch open longer than 2 days is a risk.
  Rebase on main daily to avoid merge hell. If work is too big for a short
  branch, break it into smaller features behind a flag.
- **Commit messages matter.** Structure: `<type>: <subject>` (50 chars max for
  subject). Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`,
  `perf`, `security`. Body explains why, not what. Link to issue/ticket.
  ```
  fix: prevent duplicate user registration on concurrent signup

  The email-uniqueness check and INSERT were not in a transaction,
  allowing a race condition. Wrapped both in a serializable transaction.
  Added an integration test reproducing the race.

  Fixes #1427
  ```
- **Protect main.** Require PR reviews, CI passing, and status checks before
  merge. No direct pushes. Signed commits encouraged but not required for all
  teams.
- **Atomic commits.** Each commit is one logical change. It compiles. It passes
  tests. It can be reverted cleanly. Never commit WIP ("fix stuff", "wip",
  "tmp") — squash before merging.
- **Semantic versioning.** `MAJOR.MINOR.PATCH`. Bump MAJOR for breaking changes,
  MINOR for backward-compatible features, PATCH for backward-compatible fixes.
  Tag every release. Automate version bumping in CI.
- **Changelog.** Maintain a human-readable CHANGELOG.md. Every user-facing
  change gets an entry. Link to the PR/issue. Keep it current — update in the
  same PR that makes the change.

### 2.4 Tooling & Automation

- **CI/CD is not optional.** Every push triggers: build → lint → test →
  security scan. Every merge to main triggers: build → test → package →
  deploy to staging. Deploy to production is a manual gate (or fully automated
  with canary analysis).
- **Infrastructure as Code.** Terraform, Pulumi, CloudFormation, or Ansible.
  Configuration in version control, not in a wiki or a person's head.
  Environments are reproducible. Drift is detected and corrected automatically.
- **Deterministic builds.** Same commit + same flags = identical artifact.
  Pin toolchain versions (JDK, NDK, Python, Node). Use lockfiles
  (`gradle.lockfile`, `package-lock.json`, `poetry.lock`). No `latest` tags.
  No network access during build (vendored or cached deps only).
- **Automate the boring stuff.** Linting, formatting, dead-code detection,
  dependency updates, changelog generation, release notes — script it once,
  never do it manually again.
- **Secret rotation in CI.** CI tokens and deploy keys auto-rotate. Never share
  credentials between environments. Use OIDC where possible (GitHub Actions →
  cloud provider) instead of long-lived secrets.
- **Artifact signing.** Sign every release artifact (APK, AAB, .deb, .jar,
  container image). Verify signatures before deployment. Store signing keys in
  hardware security modules or secure enclaves — never in CI config.
- **Pre-commit hooks.** Catch obvious issues before they reach CI: formatting,
  lint, trailing whitespace, merge conflict markers, large files. Keep hooks
  fast (< 5 seconds). Tools: `pre-commit` (general), `husky` + `lint-staged`
  (JS), `ktlintFormat` + `detekt` for staged files (Android).

---

### 1.2 Reliability & Performance

- **Defensive programming.** Validate inputs at every boundary. Assume external
  data is malicious until proven clean. Fail fast on internal invariants.
- **Error handling is a feature.** Distinguish recoverable from unrecoverable.
  Recoverable: retry with backoff, fall back, degrade gracefully. Unrecoverable:
  fail loudly, alert, and leave a clear trace.
- **Timeouts on every external call.** No unbounded waits. Set connect, read,
  and total timeouts. Default: 30s connect, 60s read, 120s total — tune per
  endpoint.
- **Retry with exponential backoff + jitter.** Retry on transient failures
  (network, 503, deadlock). Never retry on semantic failures (400, 404, 409).
  Cap retries (3–5). Add jitter to avoid thundering herd.
- **Circuit breaker.** After N consecutive failures, stop calling the downstream
  for a cooldown period. Return a cached or fallback response. Prevents cascade
  failures and gives downstream time to recover.
- **Bulkhead.** Isolate resources per component or tenant. One slow client
  should not starve everyone else. Use separate thread pools, connection pools,
  or rate-limit queues.
- **Graceful degradation.** When a dependency is down, serve what you can.
  Stale cache > error page. Core features > auxiliary features.
- **Idempotency.** Design write operations to be safely retried. Use
  idempotency keys for payment/order/state-mutation endpoints. `POST` with
  `Idempotency-Key` header.
- **Rate limiting.** Protect your services from abuse and accidents. Apply at
  the edge (API gateway) and at the service level. Return `429` with
  `Retry-After`.
- **Performance budgets.** Define latency and throughput targets per endpoint.
  Profile critical paths. Optimize only where data says you need to.
- **Caching with purpose.** Cache to reduce latency or load, not both.
  Document the invalidation strategy before you implement the cache. TTL,
  write-through, write-behind, cache-aside — pick one and stick with it.
  Never cache without an invalidation path.

### 1.3 Security

- **Least privilege.** Services, users, and API keys get the minimum access
  needed. Rotate credentials regularly. Revoke what isn't used.
- **Secrets vault.** Store secrets in a dedicated secret manager (Bitwarden
  Secrets Manager, HashiCorp Vault, AWS Secrets Manager, or environment-specific
  equivalents). Never in code, never in version control, never in config files,
  never in logs.
- **Secure defaults.** HTTPS everywhere (HSTS). Secure cookie flags (HttpOnly,
  Secure, SameSite=Lax). Strong TLS configuration (TLS 1.2+, modern cipher
  suites). Disable unused ports, services, and endpoints.
- **Input validation.** Validate at every trust boundary: API parameters,
  user input, file uploads, environment variables, database values. Whitelist
  what's allowed; reject everything else.
- **Output encoding.** Encode output for its context: HTML entities for HTML,
  parameterized queries for SQL, shell escaping for command execution. Prevents
  XSS, injection, and command injection.
- **Dependency management.** Pin dependencies with hash verification
  (`requirements.txt` with hashes, `package-lock.json`, Gradle lockfiles).
  Automate vulnerability scanning (SCA tools: Dependabot, Snyk, OWASP
  Dependency-Check, `pip-audit`, `npm audit`). Review every dependency before
  adding it — you ship their bugs and their vulnerabilities.
- **SBOM.** Generate a Software Bill of Materials for every release. Know
  exactly what you ship. Tools: `syft`, `cyclonedx-gradle-plugin`,
  `pip-audit --sbom`.
- **Threat modeling.** For features touching auth, payments, PII, or external
  APIs: sketch the data flow, list the trust boundaries, enumerate threats
  (STRIDE), and document mitigations. Do this during architecture, not after
  the breach.
- **Authentication & authorization.** Use standard protocols (OAuth 2.0, OIDC,
  WebAuthn). Never roll your own crypto or auth. Validate tokens on every
  request. Short-lived access tokens + refresh token rotation.
- **Mobile/desktop specifics.** Encrypt local storage (Android Keystore,
  `libsecret` on Linux). Validate deep links / custom URL schemes. Obfuscate
  sensitive code paths (ProGuard/R8 for Android). Don't trust the client —
  validate on the server.

---
