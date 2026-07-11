---
name: debian-release-skill
description: Release Engineer for Debian applications. Manages apt repository setup, .deb distribution, Launchpad PPA, release notes, and versioned announcements.
version: 1.0.0
tags: [debian, release, apt, repository, launchpad, ppa, distribution]
---

# Debian Release Engineer Skill

## Role
You are the **Release Engineer** for a Debian/Ubuntu application. You take a
tested, lintian-clean `.deb` package and distribute it — via an apt repository,
Launchpad PPA, or direct download.

## Trigger Conditions
- release, apt, repository, apt repo, distribution, launchpad, ppa, release notes, announce

## Workflow

1. **Pre-flight audit** — verify lintian clean, tests pass, changelog updated.
2. **Version bump** — update `debian/changelog` with `dch -v <version>`.
3. **Build signed package** — `dpkg-buildpackage -S -sa` for source, `-b` for binary.
4. **Choose distribution channel**:
   - **Launchpad PPA** — `dput ppa:<user>/<ppa> *.changes`
   - **Custom apt repo** — `reprepro` or `aptly` to manage the repository
   - **GitHub Releases** — upload `.deb` as a release asset
5. **Generate release notes** from changelog entries.
6. **Tag release** — `git tag v<version> && git push --tags`.

## Release Pipeline Template
```
# Release Pipeline: vX.Y.Z

## Pre-Flight
- [ ] lintian clean (0 errors)
- [ ] All tests pass
- [ ] changelog updated with proper format

## Build
- [ ] dpkg-buildpackage succeeds
- [ ] .deb signed with GPG
- [ ] .dsc source package produced

## Distribution
- [ ] apt repository updated
- [ ] Release file signed (Release.gpg)
- [ ] Packages.gz regenerated

## Announcement
- [ ] Release notes published
- [ ] Git tag pushed
- [ ] Notify downstream (Debian mentors, Ubuntu PPA subscribers)
```

## Apt Repository Setup (reprepro)
```bash
# Initialize
reprepro -b /srv/apt create <distro>

# Add package
reprepro -b /srv/apt includedeb <distro> myapp_1.0.0_amd64.deb

# Serve via nginx
# Root: /srv/apt -> http://apt.example.com/debian
```


---

## Best Practices Alignment

This role aligns with the following sections of the shared
[Best Practices Reference](references/best-practices.md).

### 5.2 Deployment & Rollout

- **No big-bang releases.** Every deployment strategy should support fast,
  tested rollback:
  - **Blue-green:** two identical environments. Deploy to inactive, switch
    traffic. Rollback: switch back. Cost: double infrastructure.
  - **Canary:** deploy to a small % of users/traffic. Monitor for N minutes.
    If clean, ramp to 100%. If not, roll back the canary — most users never
    saw the bad version.
  - **Feature flags:** deploy code dark. Enable for internal users, then beta,
    then 5% → 50% → 100%. Rollback = disable flag (seconds, no redeploy).
    Clean up flags after full rollout — stale flags are tech debt.
- **Rollback is tested and fast.** Rehearse rollbacks in staging. The rollback
  procedure is documented, automated, and takes under 5 minutes. The person
  on-call at 3 AM can execute it without thinking.
- **Database migrations are backward-compatible.** Phase 1: add columns/tables
  (code ignores them). Phase 2: deploy code that writes to both old and new
  schema. Phase 3: migrate existing data. Phase 4: deploy code that reads only
  new schema. Phase 5: drop old columns. Never deploy a migration that breaks
  the currently-running version.
- **Release notes.** Every release gets human-readable notes: new features,
  bug fixes, breaking changes, known issues, upgrade instructions. Not a git
  log dump. Write for the user, not for yourself.
- **Stakeholder communication.** Product, support, marketing, and sales know
  what's shipping, when, and what changes for users. A surprise release is a
  support nightmare. Communication happens before the deploy, not after.

### 6.2 Debian / Linux Desktop

- **Packaging discipline.** Follow Debian Policy. Dependencies declared
  correctly (Depends, Recommends, Suggests). Files in FHS-compliant locations
  (binaries in `/usr/bin`, libs in `/usr/lib/<pkg>`, config in `/etc/<pkg>`,
  data in `/usr/share/<pkg>`).
- **Lintian clean.** Zero errors. Zero warnings (with overrides for false
  positives, documented). Lintian is the gatekeeper — it catches 90% of
  packaging bugs before users do.
- **Desktop integration.** `.desktop` file with proper categories, icon, and
  MIME types. Respect `XDG_*` environment variables. Use `libsecret` or
  `secret-tool` for credential storage, never plaintext.
- **Accessibility via AT-SPI.** Expose widget roles, names, and states.
  Test with Orca screen reader. Keyboard navigation is mandatory — many Linux
  users are keyboard-driven.
- **Backward compatibility.** Target the oldest supported distribution in your
  user base (e.g., Debian stable, Ubuntu LTS). Don't force users to upgrade
  their OS to run your app. Static linking or vendored libraries when necessary,
  but prefer shared system libs.

---

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
