# Debian Development Suite — README

A comprehensive Debian/Ubuntu application development suite providing
intent-based routing to nine specialized role skills, driven by an
Orchestrator for end-to-end pipeline automation.

## Quick Start

```bash
# Install the suite into Hermes Agent skills
cd ~/.hermes/skills/debian-development-suite
chmod +x install.sh
./install.sh

# Start development
hermes -s debian-orchestrator-skill
```

## Pipeline

| Stage | Skill | Produces |
|-------|-------|----------|
| 0 | Orchestrator | PROJECT_CONTEXT.md |
| 1 | Product Manager | docs/prd.md |
| 2 | Architect | docs/architecture.md, docs/adrs.md |
| 3 | CLI/UX Designer | docs/ux-spec.md |
| 4 | Developer | Feature code |
| 5 | Code Reviewer | docs/review-report.md |
| 6 | QA Engineer | docs/test-plan.md, CI |
| 7 | Build Engineer | .deb package |
| 8 | Release Engineer | apt repository, release notes |
| 9 | Maintenance Engineer | regression plan, migration strategy |

## Intent Keywords

Just mention what you want to do — the suite routes to the right skill:

| You say... | Routes to... |
|------------|-------------|
| "write a PRD for my debian app" | Product Manager |
| "design the architecture" | Architect |
| "design the CLI interface" | CLI/UX Designer |
| "implement the feature" | Developer |
| "review my code" | Code Reviewer |
| "write tests for my package" | QA Engineer |
| "build the .deb package" | Build Engineer |
| "set up an apt repo" | Release Engineer |
| "plan maintenance for v2" | Maintenance Engineer |
| "run the whole pipeline" | Orchestrator |

## What Makes This Debian-Specific

- **FHS compliance** — files go in `/usr/bin`, `/etc`, `/var/lib`, not `/opt`
- **deb packaging** — `debian/control`, `rules`, `changelog`, `copyright`
- **lintian + piuparts** — package quality and upgrade testing
- **apt repository** — `reprepro`/`aptly` for distribution
- **systemd integration** — service units, socket activation, journald logging
- **Debian Policy** — Standards-Version tracking, DFSG licensing
- **Multi-arch** — amd64, arm64, i386 support planning

## Installation

```bash
# Clone the suite
git clone https://github.com/e-allora/debian-development-suite.git \
  ~/.hermes/skills/debian-development-suite

# Run the installer (symlinks skills)
cd ~/.hermes/skills/debian-development-suite
chmod +x install.sh
./install.sh
```

## License

MIT — same as the Android Development Suite this was modeled after.
