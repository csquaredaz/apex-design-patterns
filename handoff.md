# Handoff: apex-design-patterns

Last updated: 2026-11-18 · Phase: **done and public.** Built, released (`v1.0.0`) and public on 2026-11-18.

## Done

- Plan approved 2026-11-18 (roadmap step 4):
  - Source-only, no package (ADR 0001).
  - `force-app/<family>/<pattern>/` with a card beside the code (ADR 0002).
  - Cross-link to A, B and C instead of duplicating (ADR 0003).
  - In memory first (ADR 0004).
- Repository scaffolded by hand from `apex-standards:sf-repo-scaffold` at E `6202ac1`, which includes E PR #11's `SKIP_PERMSETS` back-port. The skill is user-invoked only. Step 8 applied: no `release.yml`, no `changelog-section.sh`, no package keys.
- Builder (`ShipmentRequest` with an inner `Builder`) is the reference card. It's in PR 1 so CI deploys real metadata and proves the test path from the first PR.
- **PR #1 merged 2026-11-18 as `b54dccf`.** Ready run 44349240178: `SKIP_PERMSETS` path, 6/6 `ShipmentRequestTest`, 100% own-class coverage, org deleted, artifact scrubbed. The `main` run 44350110331 reused it (scratch-org job skipped) and published the 100% badge.
- **PR #2 merged 2026-11-18 as `010707b`:** Factory, Singleton, Adapter, Decorator, Composite, Facade. Ready run 44353254138: 35/35 from 7 test classes, 100%. The `main` run 44354403374 reused it.
- **PR #3 merged 2026-11-18 as `65a96e9`:** Strategy, Template Method, Chain of Responsibility, Observer, State, Command. Ready run 44357229796: 67/67 from 13 test classes, 100%. The `main` run 44357988813 reused it. Renamed for reserved words: `andThen`, `render`, `bestQuote`.
- **PR #4 merged 2026-11-18 as `c4f78ab`:** ready run 44362368929 (86/86 from 17 test classes, 100%); the `main` run 44363240923 reused it and published the 100% badge.
- **`v1.0.0` released 2026-11-18:** an annotated tag on `c4f78ab` and a plain GitHub release, with the CHANGELOG `## 1.0.0` section plus a source-only line as notes. No workflow runs on tags.
- **PR 4 `feat/eip-and-docs` contents:** Content-Based Router, Splitter + Aggregator, Publish-Subscribe, with cards; README link-only rows, PoEAA row and omitted-patterns table; "Built with Claude Code" example; `docs/case-study.md`; CHANGELOG `## 1.0.0`. Local gate replay in `adp-dev`: 86/86 from 17 test classes, 100% on 49 own classes. Code Analyzer 0 High, 0 Moderate. Five targeted mutants all killed. Chad approved every design call (R1–R2, S1–S4, P1–P4, the tag). One change from the approved signatures: `OrderShippedSubscriber.handle` returns the number of Tasks written.

- **Public 2026-11-18.** The pre-flip scan was clean, so no fix PR was needed and no runs were deleted:
  - All 12 CI runs' logs: no `00D`/`005` Ids, no instance hosts and no usernames. The redact filter's masks appear where expected (`<org-id>`, `<username>`, `<instance-url>`, `***`). The only email is npm's public `glob` author address; the only hosts are `developer.salesforce.com` and `login.salesforce.com`.
  - All 16 artifacts: no `orgId`, `username`, `userId` or `hostname`. The `01p`, `707` and `0Af` record Ids from the deleted scratch orgs remain; they don't identify an org (A, B and C are the same).
  - 4 PRs (0 comments or reviews), 30 commits on all refs (noreply identities only), the `v1.0.0` notes and the tree on every ref: clean, with no employer or client names. gitleaks 8.30.1 found no leaks in the history or the tree.
  - After Chad flipped visibility: the README renders anonymously; the CI, coverage (100%), API and license badges resolve; all 28 cross-links to A, B and C return 200, and no relative link is broken.
  - Known: the `apex-standards` link to `claude-code-salesforce-skills` (E) returns 404 until E goes public at roadmap step 6. A, B and C link to it the same way.

## Next

Nothing for D. The roadmap moves to step 5, `agentforce-action-pack` (F).

The remote branches `chore/scaffold`, `feat/creational-structural`, `feat/behavioral` and `feat/eip-and-docs` are merged; delete them only when Chad asks, after a merge-base check. Keep `badges`: the coverage badge reads `coverage.json` from it.

All four PRs of the plan are merged:

| PR  | Branch                       | Contents                                                                                                |
| --- | ---------------------------- | ------------------------------------------------------------------------------------------------------- |
| 1   | `chore/scaffold`             | Scaffold, ADRs 0001–0004, README with the catalog index, Builder                                        |
| 2   | `feat/creational-structural` | Factory (`Carrier_Setting__mdt` + `Type.forName`), Singleton, Adapter, Decorator, Composite, Facade     |
| 3   | `feat/behavioral`            | Strategy, Template Method, Chain of Responsibility, Observer, State, Command                            |
| 4   | `feat/eip-and-docs`          | Content-Based Router, Splitter + Aggregator, Publish-Subscribe; link-only rows; full README; case study |

## Open decisions

None. The `v1.0.0` tag (a plain GitHub release, no package) and the subscriber's Task side effect were decided at PR 4.

## Notes for the next session

- Dev org: `adp-dev`, created 2026-11-18 for 30 days, with no permission sets assigned. Iterate with `sf project deploy start --source-dir force-app --target-org adp-dev`, then `npm run org:test -- adp-dev`.
- **PR 4 probe (2026-11-18, `adp-dev`):** a Platform Event trigger runs as the Automated Process user, which, with no permission set, inserted Tasks on an Order in user mode. With no `OwnerId` it owns them; with the Order's owner as `OwnerId` the insert also worked.
- Inner classes can call the outer class's `private` constructor (proven by the Builder deploy). Use that wherever a pattern needs a guarded constructor.
- PR 2 findings:
  - `inner` and `outer` are reserved identifiers. The decorator field is `wrapped`.
  - `Type.isAssignableFrom` works at API 68.0. Check the type before `newInstance()`.
  - Enum and empty exception classes get zero-line coverage rows, so the CI gate doesn't count them as missing (replayed locally).
  - `System.StubProvider.handleMethodCall` and four-field value-object constructors trip `ExcessiveParameterList` (Moderate). Suppress them with a reason in the code.
- PR 3 findings:
  - More reserved identifiers: `then`, `export` and `select` (renamed to `andThen`, `render` and `bestQuote`). A parameter named `order` shadows the `Order` SObject; use `owner` or `row`.
  - Abstract, virtual and override methods need an explicit access modifier, even in a private inner class.
  - A test's inner class can extend a top-level abstract class and override its `protected` hooks.
- Local gate replay: `scratchpad/ci-gate-replay.sh <alias>` repeats `ci.yml`'s test step and gate. The scratchpad may be cleared; rebuild the script from `ci.yml` if it's gone.
- PR 4 findings:
  - In a test, a Task on a deleted Order still inserts, even after `Database.emptyRecycleBin`. Use an Order Id that never existed to make a Task insert fail.
  - Task DML right after a `PermissionSetAssignment` insert in the same context is `MIXED_DML_OPERATION`, even in a partial-success insert (the row just fails). Wrap it in `System.runAs(new User(Id = UserInfo.getUserId()))`.
  - `EventBus.publish` by a user without Create on the event doesn't throw: each `SaveResult` fails. A successful Publish Immediately result also lists an `OPERATION_ENQUEUED` entry in `getErrors()`, so check `isSuccess()`.
  - Platform Event fields need no field permissions in a permission set: a Minimum Access user with object Read and Create published both fields.
  - An anonymous-Apex probe that ends in `throw` rolls back its Orders, but a Publish Immediately event still goes out.
