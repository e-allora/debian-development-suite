# PROJECT_CONTEXT — [App Name]

> Copy this file to your project root as `PROJECT_CONTEXT.md`.
> It is the single source of truth for tech decisions. Update it when an ADR
> changes a decision. Every role skill reads this file.

## App Identity
- **Name:** [app-name]
- **Purpose:** [one-line description]
- **Target distros:** Debian 12 (bookworm), Ubuntu 24.04 LTS
- **Architecture:** amd64 (add arm64 if needed)
- **License:** [MIT / GPL-3.0 / Apache-2.0]

## Tech Stack
- **Language:** [Python 3.11 / Rust 1.80 / Go 1.22 / C]
- **Build system:** [setuptools / cargo / go build / cmake]
- **Packaging:** dh_make + debhelper compat 13
- **Testing:** [pytest / cargo test / go test]
- **CI:** GitHub Actions (ubuntu-latest)

## Architecture Decisions (ADRs)
- **ADR-1:** [decision title] — [one-line summary]
- **ADR-2:** ...

## Standards
- **Debian Policy:** 4.7.0
- **FHS:** /usr/bin, /etc/, /var/lib/, /usr/share/doc/
- **Init:** systemd service unit
- **Logging:** journald (daemons) / stderr (CLI)

## Dependencies
- **Build-Depends:** debhelper-compat (= 13), ...
- **Depends:** python3, ...
- **Vendored:** [list any vendored deps]

## Configuration
- **System:** /etc/[app-name]/config.yaml
- **User:** ~/.config/[app-name]/config.yaml
- **Format:** YAML with schema validation
