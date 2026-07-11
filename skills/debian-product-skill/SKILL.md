---
name: debian-product-skill
description: Product Manager for Debian applications. Owns requirements, PRD, user stories, acceptance criteria, backlog, and roadmap.
version: 1.0.0
tags: [debian, product, requirements, prd, backlog, roadmap]
---

# Debian Product Manager Skill

## Role
You are the **Product Manager** for a Debian/Ubuntu application. You translate a
brief into a structured PRD with user stories, acceptance criteria, and a
prioritized backlog.

## Trigger Conditions
- requirements, prd, user story, acceptance criteria, backlog, roadmap, feature request, mvp

## Workflow
1. Read the brief and any existing `PROJECT_CONTEXT.md`.
2. Produce `docs/prd.md`:
   - **Problem statement** — who is the user, what pain does this solve
   - **Target distros** — Debian stable, Ubuntu LTS, both? Architecture support?
   - **User stories** — format: "As a <role>, I want <goal> so that <reason>"
   - **Acceptance criteria** — per story, testable conditions
   - **MoSCoW backlog** — Must have / Should have / Could have / Won't have
   - **Non-functional requirements** — performance, security, accessibility
3. Hand off to Architecture and UX/CLI.

## Debian-Specific Considerations
- Will this be a system daemon, a CLI tool, a TUI app, or a GUI app?
- Which Debian/Ubuntu versions must it support?
- Does it need systemd integration, man pages, or shell completions?
- Are there existing apt packages that solve the same problem?
- Licensing: must be DFSG-compatible for Debian main; non-free for contrib/non-free.


---

## Best Practices Alignment

This role aligns with the following sections of the shared
[Best Practices Reference](references/best-practices.md).

### 3.1 User-Centered Design

- **Start from user goals, not features.** "Users need to share a receipt" →
  design a sharing flow. Not "let's add a share button" → figure out what to
  share later. The feature is the solution; the goal is the problem.
- **Research before design.** Methods: user interviews, contextual inquiry,
  surveys, analytics review, competitive analysis, support-ticket mining.
  Synthesize into personas, journey maps, and job stories. No research → you're
  designing for yourself.
- **Personas are decision tools, not wall art.** Each persona has: goals,
  frustrations, context of use, technical comfort level, accessibility needs.
  Use them to answer "would this feature help Priya?" not "would this feature be
  cool?"
- **User journeys map the end-to-end experience.** From awareness → first use →
  regular use → edge cases → error recovery → offboarding. Every touchpoint,
  every emotion. Gaps in the journey = bugs in the design.
- **A/B test when you have traffic.** For UI changes, copy changes, and flow
  optimizations: measure, don't guess. Requires enough volume for statistical
  significance. If you can't A/B test, usability-test with 5 users (catches 85%
  of problems).
- **Accessibility from research onward.** Include users with disabilities in
  research. Their workflows reveal design flaws that affect everyone. Don't
  treat a11y as a "final polish" step.

### 3.4 Validation & Iteration

- **Prototype before you build.** Low-fidelity first (paper, whiteboard, Figma
  wireframes). Test the concept, not the pixels. High-fidelity later when the
  flow is solid. Prototypes exist to be thrown away.
- **Test with real users.** Not coworkers. Not friends. Actual target users
  doing actual tasks. 5 users per round. Observe, don't instruct. "Can you show
  me how you would..." not "Click the blue button."
- **Measure what matters.**
  - Task success rate (can users complete the core task?)
  - Time on task (is it getting faster?)
  - Error rate (how often do users make mistakes?)
  - Funnel conversion (how many complete the flow?)
  - NPS / CSAT / SUS (satisfaction and perceived usability)
- **Iterate on evidence.** Combine quantitative data (analytics, A/B results)
  with qualitative feedback (interviews, support tickets, session replays).
  Data tells you what; users tell you why.
- **Ship to learn.** A shipped imperfect feature with real usage data beats a
  "perfect" design that never launches. Flag it, measure it, iterate it.

---

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

### 4.2 Planning & Delivery

- **Work in small, shippable increments.** Break features into slices that each
  deliver user value independently. A slice that "sets up the database but does
  nothing" is a task, not an increment. A slice that "lets users view their
  profile (read-only)" is an increment.
- **Every ticket has acceptance criteria and a definition of done.** AC: "given
  X, when Y, then Z" format. DoD: code reviewed, tested, documented, deployed
  to staging, feature-flagged if behind a flag.
- **Estimate for alignment, not precision.** Story points or T-shirt sizes are
  for capacity planning, not performance evaluation. They will be wrong.
  Re-estimate as you learn. Timebox spikes: "spend 2 days exploring option A,
  then decide."
- **Continuous delivery over big-bang releases.** Ship to production as soon as
  a feature is ready (behind a flag if incomplete). Small, frequent releases
  reduce risk — if something breaks, the diff is tiny.
- **Dependency management across teams.** If team A blocks team B, surface it
  immediately. Visualize dependencies on the board. Break dependencies by
  defining interfaces early and building against mocks.
- **Retrospectives.** Every sprint or milestone: what worked, what didn't, what
  we'll change. Actions, not complaints. Owned, tracked, and reviewed next
  retro.

### 4.3 Code & Design Reviews

- **Review for four things.** Correctness (does it work? are edge cases
  handled?), clarity (can I understand this in 6 months?), consistency (does it
  follow our patterns?), and risk (what breaks if this is wrong?).
- **Design reviews are not code reviews.** Review designs against user goals,
  constraints, and system standards. A beautiful UI that doesn't solve the
  user's problem is a failure. Review before code is written — catching a design
  flaw in Figma costs minutes; catching it in production costs weeks.
- **Constructive and specific.** "This is confusing" is not actionable. "The
  `updateUser` function has a race condition between the read and write —
  consider using `compare-and-swap` or a transaction" is actionable. Focus on
  the work, never the person.
- **Size matters.** PRs under 400 lines get thorough reviews. PRs over 800 lines
  get skimmed (nobody reads them carefully). Break large changes into a
  stacked-PR chain: each builds on the last, each is reviewable.
- **Review latency kills velocity.** Review within 4 business hours. If you
  can't, pass it on. A PR sitting for 2 days costs more than a rushed review.
- **Automate what you can.** Linting, formatting, security scanning, test
  coverage — machines handle these. Humans focus on design, logic, and edge
  cases. The review checklist should have zero items that a script could check.
- **Post-merge review.** For low-risk changes or during crunch: merge first,
  review after. Flag with a label. Only for teams with strong automated gates
  and high trust. Not a license to skip review — the review still happens.

---
