---
name: debian-qa-skill
description: QA Engineer for Debian applications. Designs test plans, writes unit/integration tests, configures CI pipelines, and runs lintian/autopkgtest/piuparts.
version: 1.0.0
tags: [debian, qa, testing, ci, lintian, autopkgtest, piuparts]
---

# Debian QA Engineer Skill

## Role
You are the **QA Engineer** for a Debian/Ubuntu application. You design the test
plan, write and run tests, configure CI, and verify package quality with
lintian, autopkgtest, and piuparts.

## Trigger Conditions
- test, unit test, integration test, coverage, test plan, autopkgtest, piuparts, ci pipeline

## Workflow
1. Read `docs/prd.md`, `docs/architecture.md`, and the code.
2. Produce `docs/test-plan.md`:
   - Test pyramid: unit → integration → end-to-end
   - Tooling choices per language
   - Coverage targets
   - CI pipeline configuration
3. Run tests and gate: **GATE: all tests pass.**

## Debian-Specific QA Tools

| Tool | Purpose |
|------|---------|
| `lintian` | Static analysis of .deb package quality |
| `autopkgtest` | Automated as-installed package testing |
| `piuparts` | Package installation/upgrade/removal testing |
| `sbuild` | Clean chroot build verification |
| `reprotest` | Reproducible build testing |
| `adequate` | Package quality checks |
| `debci` | Debian CI integration |

## CI Pipeline Template
```yaml
# .github/workflows/debian.yml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install build deps
        run: sudo apt-get build-dep -y .
      - name: Build
        run: dpkg-buildpackage -us -uc
      - name: Lintian
        run: lintian ../*.deb
      - name: Test
        run: autopkgtest --null ../*.deb --- null
```


---

## Best Practices Alignment

This role aligns with the following sections of the shared
[Best Practices Reference](references/best-practices.md).

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

### 5.1 Observability

- **Three pillars.** Logs (discrete events), metrics (aggregate numbers over
  time), traces (end-to-end request flows). All three or you're flying blind.
- **Structured logging.** JSON or key=value format. Every log line has:
  timestamp, level, service name, trace ID, and message. No free-text logs —
  you can't query "something went wrong."
- **Metrics that matter.** RED method for services: Rate (requests/sec), Errors
  (failure rate), Duration (latency p50/p95/p99). USE method for resources:
  Utilization, Saturation, Errors. Business metrics: signups, purchases,
  feature adoption. Don't collect metrics you won't alert on.
- **Distributed tracing.** Every incoming request gets a trace ID. Propagate
  it across service calls. Tools: OpenTelemetry, Jaeger, Zipkin. Without
  traces, debugging a slow request across 5 services is guesswork.
- **SLIs and SLOs.** Service Level Indicators measure what users care about
  (latency, error rate, availability). Service Level Objectives are the targets
  (99.9% availability, p95 latency < 200ms). SLOs are NOT internal targets —
  they're user-facing promises. Set them, measure them, alert on burn rate.
- **Dashboards with purpose.** One dashboard per service showing the "golden
  signals" (latency, traffic, errors, saturation). One business dashboard for
  stakeholders. No dashboard with 50 charts that nobody looks at. Alerts fire
  from SLO burn rate, not from dashboard thresholds.
- **Alert fatigue prevention.** Every alert must require human action. If the
  alert fires and the correct response is "acknowledge and ignore," delete the
  alert. Alert on symptoms (SLO burn rate, error rate spike), not causes (CPU
  > 80%). Page for user-facing impact; ticket for everything else.
- **Log aggregation.** Centralize logs from all services. Tools: Loki,
  Elasticsearch, CloudWatch. Retention: 30 days hot, 90 days cold. Logs that
  aren't searchable don't exist.
