# Changelog

A plain history of the catalog. The repo is source-only (ADR 0001): a version is a Git tag and a GitHub release with these notes, never a package version.

## 1.0.0 (2026-11-18)

The complete catalog: 16 patterns, each with a card, tests and a link to its production form.

- Enterprise Integration Patterns: Content-Based Router (tracking scans by carrier, with an unroutable channel), Splitter + Aggregator (an order split per warehouse, confirmations correlated and reassembled), and Publish-Subscribe (`Order_Shipped_Event__e`, Publish After Commit, permission set `Order_Event_Publisher`, and a trigger subscriber that writes a Task per shipped Order).
- README: link-only rows for Idempotent Receiver, Claim Check, Dead Letter Channel and Message Store (`apex-event-ingestion`), one PoEAA row (`apex-core-lib`), the patterns deliberately left out and why, and the "Built with Claude Code" example.
- `docs/case-study.md`.
- Behavioral patterns: Strategy, Template Method, Chain of Responsibility, Observer (bulk, in-transaction), State (private inner states) and Command (an all-or-nothing queue with undo).
- Creational and structural patterns: Factory (`Carrier_Setting__mdt` + `Type.forName`), Singleton (transaction-scoped `FulfilmentCalendar`), Adapter, Decorator, Composite and Facade.
- Scaffold from `apex-standards:sf-repo-scaffold`, ADRs 0001–0004, and the Builder pattern as the reference card.
