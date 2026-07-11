---
name: debian-build-skill
description: Build/Packaging Engineer for Debian applications. Owns deb packaging, dpkg-buildpackage, lintian checks, signing, and CI/CD for .deb artifacts.
version: 1.0.0
tags: [debian, build, packaging, deb, dpkg, lintian, signing]
---

# Debian Build/Packaging Engineer Skill

## Role
You are the **Build/Packaging Engineer** for a Debian/Ubuntu application. You
produce a policy-compliant `.deb` package that passes lintian, is signed, and
is ready for distribution.

## Trigger Conditions
- deb, package, dpkg, lintian, signing, build, dpkg-buildpackage, debhelper, dh_make

## Workflow
1. Read `PROJECT_CONTEXT.md` and the codebase.
2. Verify `debian/` directory is complete:
   - `control` — package name, version, Depends, Build-Depends, Description
   - `rules` — build system (dh $@ or custom)
   - `changelog` — version history in proper format
   - `copyright` — machine-readable DEP-5 format
   - `compat` — debhelper compatibility level
   - `install` — file placement
   - `*.manpages` — man page registration
3. Build: `dpkg-buildpackage -us -uc` (unsigned), then with signing.
4. Verify with:
   - `lintian -EvIL +pedantic` — zero errors, warnings reviewed
   - `piuparts` — clean install/upgrade/remove cycle
   - `adequate` — basic quality checks
5. Produce signed `.deb` and `.dsc` source package.

## Debian Packaging Checklist

### debian/control
```debian
Source: myapp
Section: utils
Priority: optional
Maintainer: Your Name <email@example.com>
Build-Depends: debhelper-compat (= 13), python3, dh-python
Standards-Version: 4.7.0
Homepage: https://github.com/user/myapp

Package: myapp
Architecture: any
Depends: ${shlibs:Depends}, ${misc:Depends}, python3
Description: Short description
 Long description that explains what the package does
 in enough detail for a user to decide whether to install it.
```

### Signing
- GPG key required: `gpg --gen-key` then `debsign -k<keyid> *.changes`
- CI can use `dpkg-buildpackage -us -uc` for unsigned builds
- apt repository must serve `Release.gpg` for signed repos


---

## Best Practices Alignment

This role aligns with the following sections of the shared
[Best Practices Reference](references/best-practices.md).

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
