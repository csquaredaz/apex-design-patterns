# ADR 0003: Cross-link to the production forms in the other repos instead of duplicating them

- **Status:** Accepted
- **Date:** 2026-11-18
- **Deciders:** Chad Countryman

## Context

Several patterns already run at production grade in this portfolio:

- `apex-core-lib`: Builder (`CalloutRequest`), Strategy (`RetryPolicy`, `IDml`), Decorator (`StripInaccessibleDml`), Abstract Factory (`ServiceFactory`, `DomainFactory`), Template Method (`SObjectDomain`), and PoEAA's Unit of Work, Query Object (selectors), Service Layer and the DI container.
- `apex-event-ingestion`: Command and Composite dispatch (`CompositeMessageHandler`), Decorator (`GuardedMessageHandler`), Content-Based Router (`MessageRouter`), Idempotent Receiver, Claim Check, Dead Letter Channel and Message Store.
- `apex-platform-logging`: an Adapter (the Slack `IAlertSink`).

A catalog that re-implemented those at full size would duplicate thousands of lines. One that left them out would have obvious holes.

## Options

1. **A teaching-size version here, with a "See it at scale" link to the production form** (chosen), plus **link-only rows** for the patterns whose faithful version needs real infrastructure. For: each card is complete on its own, and the link shows the same pattern under real constraints (security, limits, recovery). Against: two versions of some patterns exist, and links can rot when the other repos change.
2. **Link only, for every pattern that exists elsewhere.** For: no duplication. Against: the catalog's most common patterns (Builder, Decorator, Command, Composite) would have no runnable example here.
3. **Re-implement at full size.** For: fully standalone. Against: duplication, and two versions to keep in step.

## Decision

Option 1. Link-only rows are Idempotent Receiver, Claim Check, Dead Letter Channel and Message Store, each pointing to `apex-event-ingestion`'s ADR, because a faithful version needs a custom object, ContentVersion files and permission sets, which would make it a copy of that repo. PoEAA (Unit of Work, Query Object, Service Layer, DI) gets one row pointing to `apex-core-lib`: this catalog covers GoF and EIP.

## Consequences

- Links point to `main` in the public repos, by path. If a linked class moves, the link breaks, so moving one of those classes means updating this catalog in the same change.
- This repo takes no dependency on the others (ADR 0001): a link is documentation, not a build input.
- Some GoF patterns are deliberately left out, with a one-line reason in the README (Prototype, Flyweight, Iterator, Visitor, Interpreter, Mediator, Memento). Each is either a language feature in Apex or rarely earns its weight on the platform.
