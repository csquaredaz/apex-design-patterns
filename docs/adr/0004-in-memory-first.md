# ADR 0004: Model patterns in memory first, and touch the platform only where the pattern is about it

- **Status:** Accepted
- **Date:** 2026-11-18
- **Deciders:** Chad Countryman

## Context

A pattern is about the shape of the code: who knows whom, and what varies. Most GoF patterns don't need the database to show that. Records, triggers and permission sets would add setup that hides the pattern, and every custom object would need a permission set and test users (`salesforce-ci-learnings`: an admin gets no FLS on new fields, and the package build org has no permission sets).

Some patterns are about the platform, though. Publish-Subscribe on Salesforce _is_ Platform Events, and a configuration-driven Factory _is_ Custom Metadata and `Type.forName`.

## Options

1. **In memory first** (chosen). Patterns use plain Apex value classes from the Orders / Shipments / Customers domain. Platform metadata appears only where the pattern is about the platform: `Carrier_Setting__mdt` for the Factory, and `Order_Shipped_Event__e` for Publish-Subscribe. For: fast, deterministic tests with no data setup, and each card shows the pattern rather than the plumbing. Against: the in-memory examples skip the CRUD, FLS and bulk concerns of real data access. Each card's "See it at scale" link covers those (ADR 0003).
2. **Every pattern on standard objects (`Order`, `Account`).** For: closer to day-to-day Apex. Against: DML setup in every test, and access setup for every user, all of it noise around the pattern.
3. **Custom objects per pattern.** For: realistic. Against: the most setup, a permission set per object, and the namespace concerns from ADR 0001.

## Decision

Option 1, because a catalog should show the pattern with as little else as possible, and the platform appears only where it is the point.

## Consequences

- Most tests are pure unit tests: no DML and no `runAs`. They still assert behaviour, include a negative path and, where a loop is involved, a 200-item case.
- Where the platform is involved, tests follow the portfolio rule: arrange data in `AccessLevel.SYSTEM_MODE`, and act as a Minimum Access user who has only this repo's permission set (CI sets `SKIP_PERMSETS=1`, so the admin has none). Custom Metadata rows are built in memory through a `@TestVisible` seam.
- Patterns that need persistence to be faithful are link-only (ADR 0003).
- The workspace rules "selectors own SOQL" and "a Unit of Work owns DML" apply to any pattern that touches data. Where a teaching example would need a full selector or Unit of Work just to show its pattern, the card says what the production form adds and links to it.
