# Philterd Appliance

!!! warning "Under active development"
    This project is not ready for production use. Interfaces, service layout,
    ports and configuration change without notice, and there is no upgrade path
    between revisions. Philter 4.0 is unreleased, so most components are built
    from source rather than pulled from a registry. Treat it as a preview.

Philterd's open source PII and PHI tools assembled into one self-hosted box.
Everything runs on a single machine, on your own infrastructure. No data leaves
your boundary.

## What it runs

| Product | Role |
|---|---|
| Philter | Redaction API and dashboard |
| PhEye | Detection models used by Philter |
| Redaction Policy Editor | Building and editing policies |
| Philter Scope | Scoring policies against a golden dataset |
| Arbiter | Human review of detected spans |
| Console | Launcher and status view over the rest |

MongoDB backs Philter, Philter Scope and Arbiter. OpenSearch backs Arbiter's
search. An nginx proxy terminates TLS in front of everything.

## Where to start

- [Getting started](getting-started.md) to run it
- [Profiles and ports](profiles-and-ports.md) for what starts and where it listens
- [Bill of materials](configuration/bill-of-materials.md) for how components are pinned and built

## Design

Two decisions shape everything else.

**The bill of materials is the source of truth.** `bom.yaml` records every
component's image reference and whether it is pulled or built. Nothing else in
the repository knows which tier a component is in, so an unpublished product
sits alongside a published one with no special casing.

**Each product gets its own port.** Philter's Vaadin dashboard and Arbiter's
Spring UI both assume they own the root of their origin, so path-prefix routing
would mean rewriting their asset and websocket paths. Distinct ports also
resolve the collision where three products all listen on 8080 internally.
