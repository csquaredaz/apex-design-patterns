# Handoff: apex-design-patterns

Last updated: 2026-11-18 · Phase: PR 2 of 4 (`feat/creational-structural`).

## Done

- Plan approved 2026-11-18 (roadmap step 4):
  - Source-only, no package (ADR 0001).
  - `force-app/<family>/<pattern>/` with a card beside the code (ADR 0002).
  - Cross-link to A, B and C instead of duplicating (ADR 0003).
  - In memory first (ADR 0004).
- Repository scaffolded by hand from `apex-standards:sf-repo-scaffold` at E `6202ac1`, which includes E PR #11's `SKIP_PERMSETS` back-port. The skill is user-invoked only. Step 8 applied: no `release.yml`, no `changelog-section.sh`, no package keys.
- Builder (`ShipmentRequest` with an inner `Builder`) is the reference card. It's in PR 1 so CI deploys real metadata and proves the test path from the first PR.
- **PR #1 merged 2026-11-18 as `b54dccf`.** Ready run 44349240178: `SKIP_PERMSETS` path, 6/6 `ShipmentRequestTest`, 100% own-class coverage, org deleted, artifact scrubbed. The `main` run 44350110331 reused it (scratch-org job skipped) and published the 100% badge.

## Next

| PR  | Branch                       | Contents                                                                                                |
| --- | ---------------------------- | ------------------------------------------------------------------------------------------------------- |
| 1   | `chore/scaffold`             | Scaffold, ADRs 0001–0004, README with the catalog index, Builder                                        |
| 2   | `feat/creational-structural` | Factory (`Carrier_Setting__mdt` + `Type.forName`), Singleton, Adapter, Decorator, Composite, Facade     |
| 3   | `feat/behavioral`            | Strategy, Template Method, Chain of Responsibility, Observer, State, Command                            |
| 4   | `feat/eip-and-docs`          | Content-Based Router, Splitter + Aggregator, Publish-Subscribe; link-only rows; full README; case study |

PR 4 also adds:

- Link-only rows: Idempotent Receiver, Claim Check, Dead Letter Channel and Message Store, linking to C's ADRs 0003, 0008, 0006 and 0002.
- One PoEAA row pointing to A.
- An omitted-patterns table (Prototype, Flyweight, Iterator, Visitor, Interpreter, Mediator, Memento).
- The "Built with Claude Code" example.

## Open decisions

| Decision                                     | Options                                     | Leaning                   | Needed by |
| -------------------------------------------- | ------------------------------------------- | ------------------------- | --------- |
| A plain `v1.0.0` GitHub release (no package) | a) tag the finished catalog b) no tag       | Decide at PR 4            | PR 4      |
| Publish-Subscribe subscriber's side effect   | a) a Task on the Order b) something lighter | a), once the probe passes | PR 4      |

## Notes for the next session

- Dev org: `adp-dev`, created 2026-11-18 for 30 days, with no permission sets assigned. Iterate with `sf project deploy start --source-dir force-app --target-org adp-dev`, then `npm run org:test -- adp-dev`.
- **Probe before PR 4:** a Platform Event trigger runs as the Automated Process user. Check that it can insert a Task on an Order with no permission set. `apex-event-ingestion` proved updating Orders, but not Tasks.
- Inner classes can call the outer class's `private` constructor (proven by the Builder deploy). Use that wherever a pattern needs a guarded constructor.
