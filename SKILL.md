---
name: debian-development-suite
description: >-
  A comprehensive Debian application development suite providing intent-based routing
  to nine specialized role skills: Product Manager, Software Architect, CLI/UX Designer,
  Developer, Code Reviewer, QA Engineer, Build/Packaging Engineer, Release Engineer,
  and Maintenance Engineer. Driven by an Orchestrator for end-to-end pipeline automation.
  Covers the full lifecycle: requirements → architecture → design → development →
  review → QA → deb packaging → apt repository release → maintenance.
version: 1.0.0
tags:
  - debian
  - ubuntu
  - linux
  - packaging
  - deb
  - apt
  - systemd
  - cli
  - tui
  - pipeline
  - orchestrator
  - review
  - qa
  - release
  - maintenance
---

# Debian Development Suite

## Overview

The Debian Development Suite is an integrated collection of skills, templates,
references, and tooling that covers the **entire Debian/Ubuntu application
development lifecycle** — from product requirements through architecture, CLI/UX
design, implementation, code review, testing, deb packaging, apt repository
release, and post-release maintenance.

The suite uses **intent-based routing** to direct incoming requests to the most
appropriate specialized skill based on trigger keywords. An **Orchestrator
Driver** can run all nine role skills from a single brief, with a shared
`PROJECT_CONTEXT.md` as the single source of truth.

## The Pipeline

```
0. Orchestrate  debian-orchestrator-skill    drives stages 1–9; gatekeeper
1. Product       debian-product-skill         PRD, user stories, ACs, backlog
2. Architecture  debian-architecture-skill    system design, dependencies, ADRs
3. UX/CLI        debian-ux-skill              CLI/TUI spec, man pages, config design
4. Development   debian-development-skill     feature code (Python/Rust/Go/C)
5. Review        debian-review-skill          review report (critical/major gate)
6. QA            debian-qa-skill              test plan, unit/integration, CI, lintian
7. Build         debian-build-skill           deb packaging, signing, lintian, piuparts
8. Release       debian-release-skill         apt repository, release notes, distribution
9. Maintenance   debian-maintenance-skill     regression, migration, flags, observability
```

Stages 2 and 3 can start in parallel after Product. Development can fan out per
feature. The Review → Dev(fix) → QA loop repeats until green. No feature merges
until Review approves (no open critical/major) and tests pass.

## Intent-Based Routing

| Intent | Trigger Keywords | Route To Skill |
|--------|------------------|----------------|
| **Orchestration** | orchestrate, run the pipeline, full workflow, end-to-end, agentic workflow, drive the process | `debian-orchestrator-skill` |
| **Product** | requirements, prd, user story, acceptance criteria, backlog, roadmap, feature request, mvp | `debian-product-skill` |
| **Architecture** | architecture, adr, system design, dependency graph, module structure, tech debt | `debian-architecture-skill` |
| **UX / CLI Design** | cli, tui, ux, interface design, man page, config file, flag design, help text, shell completion | `debian-ux-skill` |
| **Development** | implement, scaffold, feature, code, module, library, binary, daemon, service | `debian-development-skill` |
| **Review** | review, code review, static analysis, lint, lintian, shellcheck, architecture conformance | `debian-review-skill` |
| **QA / Testing** | test, unit test, integration test, coverage, test plan, autopkgtest, piuparts, ci pipeline | `debian-qa-skill` |
| **Build** | deb, package, dpkg, lintian, signing, build, dpkg-buildpackage, debhelper, dh_make | `debian-build-skill` |
| **Release** | release, apt, repository, apt repo, distribution, launchpad, ppa, release notes, announce | `debian-release-skill` |
| **Maintenance** | maintenance, regression, migration, feature flag, observability, deprecation, post-release | `debian-maintenance-skill` |

## Shared Project Context

Copy `templates/PROJECT_CONTEXT.md` to your repo root on day one. Every skill
reads it for tech-stack decisions, naming conventions, and architecture rules.
Keep it the single source of truth.

## Installation

```bash
cd ~/.hermes/skills/debian-development-suite
chmod +x install.sh
./install.sh
```

The installer symlinks all role skills into `~/.hermes/skills/`.

## Cross-References

Each skill's SKILL.md cross-references the next so a workflow can hand off
context cleanly. The full workflow runbook is at `references/workflow-runbook.md`.
