# CLAUDE.md: apex-design-patterns

GoF and EIP patterns in Apex, each with when to use it and when not to, cross-linked to production-grade forms.

## Stack

- Salesforce DX source format, API 68.0, source-only, no package (ADR 0001).
- Depends on: none (standalone; links to apex-core-lib and apex-event-ingestion instead of depending on them)
- Standards plugin: `apex-standards`. Apply `apex-fflib-layers`, `apex-security` and `apex-testing` to all Apex, and run `apex-code-review` before opening a PR.

## Hard rules

1. **Clean-room.** No code, names, object models or data from any employer or client. The domain is fictional Orders / Shipments / Customers.
2. **No secrets.** No credentials, org IDs, usernames or URLs with tokens. Callouts use Named Credentials. gitleaks runs in pre-commit and CI.
3. **Bulk-safe and layered.** Selectors own SOQL, a Unit of Work owns DML, services are stateless, and nothing touches the database inside a loop.
4. **Secure by default.** Every class declares its sharing, and queries and DML run in user mode. Every exception is documented in ApexDoc and an ADR.
5. **Tests prove behaviour.** Stub API unit tests, a few real-DML integration tests, a 200-record bulk case and negative paths. Coverage is at least 90% as a floor, not a target.
6. **Done means:** CI green, zero High or Critical Code Analyzer findings, no `TODO`, ApexDoc on every public class, ADRs written, README complete, `docs/case-study.md` written.
7. **Free only.** No paid services or SaaS. Note each deliberate omission where a reader would look for it.

## Layout

`force-app/<family>/<pattern>/{README.md,classes,objects,triggers,customMetadata,permissionsets,…}`, where the family is `creational`, `structural`, `behavioral` or `eip` (ADR 0002).

- **Every pattern has a card** (`README.md`) with the Builder card's headings, in order: Intent · The problem here · Shape in Apex · Use it when · Don't use it when · Salesforce specifics · See it at scale · What the tests prove.
- **About 100 lines of production code per pattern**, with one `<Class>Test`. Class names are unique domain names (one global namespace), never pattern prefixes.
- **In memory first** (ADR 0004). Use SObjects, Custom Metadata or Platform Events only where the pattern is about the platform. Those tests arrange data in system mode and act as a Minimum Access user with the repo's permission set; CI's admin has none (`SKIP_PERMSETS=1`).
- **Cross-link, don't duplicate** (ADR 0003). When a pattern runs at production grade in `apex-core-lib`, `apex-event-ingestion` or `apex-platform-logging`, link to that class by path on `main`.

## Workflow

- Plan first: file tree, class list and test plan before code.
- Branch per feature, small Conventional Commits, PR into `main` even when working solo. Keep the `Co-Authored-By: Claude` trailer on AI-assisted commits.
- Before pushing: `npm run format:check && npm run lint && npm run analyze`.
- At the end of every session, update `handoff.md`.
