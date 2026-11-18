# ADR 0001: Ship the catalog as source only, with no package

- **Status:** Accepted
- **Date:** 2026-11-18
- **Deciders:** Chad Countryman

## Context

This repo is a catalog: each pattern is a small, self-contained example with a card explaining when to use it and when not to. Readers are engineers who read the code and run the tests. Nobody installs "the Strategy pattern" into a production org.

The portfolio's other repos are unlocked packages with no namespace (`apex-core-lib` ADR 0001). Constraints that differ here:

1. The catalog has about 40 demo classes with domain names (`ShipmentRequest`, `FulfilmentOrder`, `CarrierClientFactory`). A no-namespace package would put all of them into a subscriber org's single global namespace, where they could clash with real classes.
2. The free Developer Edition Dev Hub allows 6 package version creates per rolling 24 hours, shared with the other repos' releases.
3. The catalog has no consumers: no other repo depends on it.

## Options

1. **Source only** (chosen). For: nothing pollutes anyone's org; there's no release workflow, no package builds and no install docs to maintain; a reader can still deploy it to a scratch org in three commands. Against: there's no versioned artifact, and anyone who wants a pattern copies its source.
2. **An unlocked package with no namespace,** like the other repos. For: consistent, installable and versioned. Against: the namespace pollution above, a release session per version, and package creates spent for a package nobody installs.
3. **An unlocked package with a namespace.** For: no name clashes. Against: a namespace needs a namespace registry org and a linked Dev Hub. It would also make this the only namespaced repo in the portfolio, for no consumer.

## Decision

Option 1: source only, because a catalog is read and run, not installed, and a package would only spread demo classes into subscriber orgs.

## Consequences

- `sfdx-project.json` has no `package`, `versionNumber` or `packageAliases` keys, and the repo has no `release.yml` or `changelog-section.sh` (scaffold SKILL.md step 8). `CHANGELOG.md` is a plain history.
- CI is otherwise the same as the packaged repos': static checks, then a scratch org, deploy, this repo's `*Test` classes, a 90% coverage gate on this repo's classes, and the badge.
- CI still sets `SKIP_PERMSETS=1`, so the running admin has none of this repo's permission sets. Tests set up their own users' access. This keeps the catalog's tests honest even though no package build will run them.
- Revisit if another repo wants to depend on a pattern here. The right move then is probably to promote that pattern into `apex-core-lib`, not to package the catalog.
