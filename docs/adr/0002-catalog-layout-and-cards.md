# ADR 0002: Lay the catalog out by family and pattern, with a card beside each pattern's code

- **Status:** Accepted
- **Date:** 2026-11-18
- **Deciders:** Chad Countryman

## Context

A reviewer should be able to open one folder and understand one pattern in a few minutes: the problem, the code, when not to use it, and the tests. Constraints:

1. Apex has a single global namespace for classes in an org. Folders organise source, but two classes with the same name in different folders still clash.
2. Salesforce DX resolves metadata by file suffix, so non-metadata files in `force-app` must not break a deploy.
3. The workspace standard organises `force-app/<feature>/…` by feature wherever that helps a reader.

## Options

1. **`force-app/<family>/<pattern>/`, with a `README.md` card beside `classes/`** (chosen). Families are `creational`, `structural` and `behavioral` (the GoF groups) and `eip` (Enterprise Integration Patterns). For: the folder tree is the catalog index, grouped the way readers look for patterns, and each card sits next to the code it explains. Against: one level deeper than a flat layout.
2. **A flat `force-app/<pattern>/`.** For: shorter paths. Against: about 16 folders in alphabetical order lose the GoF grouping a reader scans by.
3. **Code in `force-app/<pattern>/`, cards in `docs/patterns/`.** For: `force-app` holds metadata only. Against: every pattern is split across two trees, and cards drift from their code.

## Decision

Option 1, because the tree itself reads as the catalog and each pattern is reviewable from one folder.

## Consequences

- **Cards are ignored by the deploy.** A local `sf project convert source` already skipped `README.md` files inside `force-app` (checked 2026-11-18). `.forceignore` also lists `**/README.md`, so the intent is explicit.
- **Class names are unique and domain-named,** not prefixed by pattern: `ShipmentRequest`, not `BuilderShipmentRequest`. The card names the pattern, and the code reads like real code.
- **Every card follows the same headings:** Intent · The problem here · Shape in Apex (a Mermaid `classDiagram` and a snippet) · Use it when · Don't use it when · Salesforce specifics · See it at scale · What the tests prove. The Builder card is the reference.
- **Each pattern stays at about 100 lines of production code**, with its own `<Class>Test`. A pattern that needs more is a sign that its production form belongs in another repo (ADR 0003).
