# Philterd Appliance

> [!WARNING]
> **This project is under active development and is not ready for production
> use.** Interfaces, service layout, ports and configuration all change without
> notice, and there is no upgrade path between revisions. Philter 4.0 is
> unreleased, so most components are still built from source rather than pulled
> from a registry. Treat it as a preview.

Philterd's open source PII and PHI tools assembled into one self-hosted box.
Everything runs on a single machine, on your own infrastructure. No data leaves
your boundary.

Documentation: <https://philterd.github.io/philterd-appliance/>

## Quick start

```sh
make bootstrap   # generate .env and a TLS certificate
make build       # build the components that are not published yet
make up          # start the core profile
```

Then open `https://localhost:8443/`.

`make bootstrap` generates a self-signed certificate, so browsers warn on first
use until it is trusted or replaced with one of your own.

## What it runs

| Product | Port | Role |
|---|---|---|
| Console | 8443 | Launcher and status view over the rest |
| Philter | 8444 | Redaction API and dashboard |
| Redaction Policy Editor | 8445 | Building and editing policies |
| Arbiter | 8446 | Human review of detected spans (`full` profile) |
| Philter Scope | 8447 | Scoring policies against a golden dataset |
| PhEye | internal | Detection models used by Philter |
| Ollama | internal | Local LLM for Philter Scope and Arbiter (`full` profile) |

MongoDB and OpenSearch back the products that need them. An nginx proxy
terminates TLS in front of everything, and is the only service that binds to the
host.

```sh
make up        # core
make up-full   # everything, including Arbiter
```

## How it is put together

`bom.yaml` is the single source of truth for what ships. Each component records
its image reference and whether it is pulled from a registry or built locally,
so an unpublished product sits alongside a published one with no special casing
anywhere else.

```sh
make bom       # list components and their tiers
make doctor    # check that components resolve
```

Seven of ten components are built from source today, Philter among them. See
[Image publishing](docs/docs/publishing.md).

## Documentation

Built with mkdocs from `docs/`, published to GitHub Pages on every push to
`main`. To preview locally:

```sh
pip install -r docs/requirements.txt
mkdocs serve -f docs/mkdocs.yml
```

## Contributing

Issues and roadmap are tracked in this repository. The appliance's outstanding
work is collected in
[#2](https://github.com/philterd/philterd-appliance/issues/2).

## License

Copyright 2026 Philterd, LLC. Licensed under the Apache License, Version 2.0.
