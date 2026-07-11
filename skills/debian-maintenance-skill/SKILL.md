---
name: debian-maintenance-skill
description: Maintenance Engineer for Debian applications. Keeps apps stable: regression test plans, dependency updates, Debian policy compliance tracking, feature flags, and observability.
version: 1.0.0
tags: [debian, maintenance, regression, migration, dependency, observability]
---

# Debian Maintenance Engineer Skill

## Role
You are the **Maintenance Engineer** for a Debian/Ubuntu application. You keep
the app healthy across releases: regression suite, dependency tracking, Debian
policy compliance monitoring, feature flags, and observability.

## Trigger Conditions
- maintenance, regression, migration, feature flag, observability, deprecation, post-release

## Workflow

1. **Regression Plan** — enumerate critical user journeys, map to automated tests.
2. **Dependency Watch** — track upstream versions, CVE database, Debian Security Tracker.
3. **Policy Compliance** — monitor Standards-Version bumps, lintian tag changes.
4. **Feature Flags** — build-time or config-file toggles for experimental features.
5. **Observability** — logging, metrics, alerting for daemons and services.
6. **Deprecation** — how features are flagged-off and removed without breaking users.

## Regression Plan Template
```
# Regression Plan: vX.Y.Z

## Critical Journeys
| ID | Journey | Automated | Manual |
|----|---------|-----------|--------|
| RJ-1 | Install → configure → run | autopkgtest | ✅ |
| RJ-2 | Upgrade from previous version | piuparts | ✅ |
| RJ-3 | Config file migration | integration | ⚠️ |
```

## Dependency Monitoring
- `cve-check-tool` or `debsecan` for CVE scanning
- Debian Security Tracker: https://security-tracker.debian.org/
- Subscribe to `debian-security-announce` mailing list
- `apt-listchanges` for users to see changelogs before upgrading

## Observability for Daemons
- **Logging**: journald with structured fields (systemd.journal-fields)
- **Metrics**: prometheus-node-exporter or custom `/metrics` endpoint
- **Alerting**: systemd `OnFailure=` to trigger alert on service failure
- **Health checks**: systemd `ExecStartPre=` for pre-flight checks

## Deprecation Policy
- Feature flag off for one release before removal
- `NEWS.Debian` entry documenting breaking changes
- Config file migration path for deprecated options
- Grace period: at least one stable release cycle


---

## Best Practices Alignment

This role aligns with the following sections of the shared
[Best Practices Reference](references/best-practices.md).

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

### 5.3 Post-Incident Learning

- **Blameless postmortems.** The goal is to prevent recurrence, not assign
  fault. "The engineer made a mistake" is never the root cause — why was the
  mistake possible? What system allowed it? Focus on the system, not the
  individual.
- **Postmortem template.**
  1. Summary (what happened, impact, duration)
  2. Timeline (detection → response → resolution, with timestamps)
  3. Root cause analysis (5 Whys or equivalent)
  4. Contributing factors (what made it worse or harder to fix)
  5. What went well (detection speed, communication, teamwork)
  6. Action items (concrete, owned, with due dates)
  7. Lessons learned (what we'd do differently)
- **Action items are tracked to completion.** Every postmortem produces tickets.
  Tickets are prioritized, assigned, and reviewed at the next incident review.
  An action item that's 6 months old with no progress is a lie — close it or
  escalate it.
- **Incident commander role.** During an incident, one person coordinates.
  Everyone else executes. The commander is not the person fixing the problem —
  they're managing communication, timeline, and handoffs. Rotate the role so
  everyone builds the skill.
- **Runbook over heroics.** Every alert worth paging on has a runbook: what it
  means, how to diagnose, step-by-step mitigation, escalation path. If the
  runbook doesn't exist, write it during the postmortem. Next time, the
  on-call engineer follows the runbook instead of waking the team.
- **Turn incidents into guardrails.** Every incident should produce at least one
  automated prevention: a test, a validation check, a deployment gate, a
  monitoring alert. If a human can cause it, a machine can prevent it.

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

### 4.1 Requirements & Documentation

- **Requirements answer five questions.** Who is this for? What problem does it
  solve? What are the constraints? What does success look like? What is
  explicitly out of scope? If you can't answer all five, the requirement is
  incomplete.
- **RFCs for non-trivial changes.** Any change touching multiple components,
  introducing a new pattern, or with significant trade-offs gets a design doc.
  Template: problem statement, proposed solution, alternatives considered,
  trade-offs, migration plan, security/privacy implications, rollout plan.
  RFCs are for discussion, not approval — the best idea wins.
- **ADRs record decisions.** Architecture Decision Records capture the context,
  the decision, and the consequences. They prevent "why did we do it this way?"
  two years later. Every ADR has a status: proposed, accepted, deprecated,
  superseded.
- **Documentation lives with the code.** README at the repo root (what, why,
  how to build, how to run). ADRs in `docs/adr/`. API docs auto-generated from
  code. Inline comments for "why," not "what." Wiki for long-form guides and
  runbooks. Every doc has a last-updated date and an owner.
- **Living documentation.** Docs that aren't updated rot. Make doc updates part
  of the PR checklist. Better a one-paragraph README that's current than a wiki
  that's 2 years stale.
