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

## Quick start

```sh
make bootstrap   # generate .env with fresh encryption keys
make build       # build the components that are not published yet
make up          # start the core profile
```

Then open `https://localhost:8443/`.

`make bootstrap` generates a self-signed certificate, so browsers warn on first
use until it is trusted or replaced with one of your own. See [TLS](#tls).

## Profiles

| Profile | Services | Use |
|---|---|---|
| `core` (default) | console, Philter, PhEye, MongoDB, policy editor | Redaction API and policy authoring |
| `full` | core plus Arbiter and OpenSearch | Adds human-in-the-loop review |

```sh
make up        # core
make up-full   # everything
```

## Ports

Only the proxy binds to the host. Philter, PhEye, MongoDB and OpenSearch stay
on the internal network.

| Port | Service |
|---|---|
| 8443 | Console |
| 8444 | Philter API and dashboard |
| 8445 | Redaction policy editor |
| 8446 | Arbiter (`full` profile only) |

Each product gets its own port rather than a path prefix, because Philter's
Vaadin dashboard and Arbiter's Spring UI both assume they are served from the
root of their origin. This also resolves the collision where all three listen
on 8080 inside their own containers. Override any port in `.env`.

## The bill of materials

`bom.yaml` is the single source of truth for what the appliance ships. Each
component records its image reference and how that image comes into existence:

- `source: registry` is pulled as published.
- `source: build` is not published yet, so the appliance builds it and tags it
  with the exact name it will carry once its repository gains publishing CI.

Because built images are tagged with their eventual registry name, nothing
outside `bom.yaml` knows which tier a component is in. `docker-compose.yaml`
refers to every component through an `IMG_*` variable rendered by
`make images`.

```sh
make bom       # list components and their tiers
make doctor    # check that registry components resolve and builds exist
```

Several Philterd products have a working Dockerfile but no published image, and
Philter 4.0 itself is unreleased, so the build tier currently carries the
flagship. See [docs/publishing.md](docs/publishing.md) for what it takes to
promote a component.

### Building from source

`make build` prefers a sibling checkout when one exists, so iterating on a
product does not require pushing first. The appliance expects sibling clones
one level up:

```
philterd/
├── philter/
├── arbiter/
└── philterd-appliance/    <- you are here
```

Without a sibling checkout, Docker builds straight from the component's git URL
in `bom.yaml`. That needs network access and is slower, but it keeps this
repository free of submodules and vendored source.

## Secrets

Philter and Arbiter each require a base64-encoded 32-byte AES key and refuse to
start without one. `make bootstrap` generates both into `.env`, along with a
Philter bootstrap API key and an Arbiter admin password.

Back up `.env`. Losing `PHILTER_ENCRYPTION_KEY` makes Philter's encrypted data
unrecoverable. `make bootstrap` will not overwrite an existing `.env`, because
rotating these keys orphans anything already encrypted with the old ones.

## TLS

The nginx proxy terminates TLS for all four ports from a single certificate.

`make bootstrap` generates a self-signed one into `proxy/tls/`, valid for ten
years, with subject alternative names covering `localhost`, `127.0.0.1`, this
host's name and its routable addresses. Covering the addresses matters: a
browser validates the name it was given, so a certificate for `localhost` alone
would warn for anyone connecting over the network.

Nothing vouches for a self-signed certificate, so browsers warn until it is
trusted. Import `proxy/tls/appliance.crt` into your trust store to silence
that, or supply a real certificate:

```sh
make bootstrap CERT=/etc/ssl/philterd.crt KEY=/etc/ssl/philterd.key
```

That records the paths in `.env` as `APPLIANCE_TLS_CERT` and
`APPLIANCE_TLS_KEY`, which are what the proxy bind-mounts. Swapping
certificates is therefore a change of mount source, never a change of nginx
configuration, and re-running bootstrap does not touch existing secrets.

`proxy/tls/` is gitignored, since it holds a private key.

## Console

`console/` holds the appliance's own image: a launcher over the other products.
It lists each application, shows whether it is running, and links out to its
own interface. It does not embed or aggregate them.

The browser cannot reach the internal network, but the console can, so it
proxies one probe per product under `/probe/<name>` and the page polls those
same-origin every 15 seconds. That avoids both CORS and a certificate prompt
against each product's port. Any HTTP status from a product counts as running,
including a redirect to a login page; only a 502 or 504 from the console's own
nginx means unreachable.

What each probe actually reads:

| Product | Probe | Signal |
|---|---|---|
| Philter | `/actuator/health` | Real health check |
| PhEye | `/status` | Fixed string, so process liveness only |
| Policy editor | `/` | Serving or not |
| Arbiter | `/` | Serving or not |

Only Philter reports genuine health. See [docs/observability.md](docs/observability.md)
for the gaps and what closing them requires.

MongoDB and OpenSearch are not shown, since neither is reachable over HTTP in a
way the console can probe meaningfully.

## What is not here yet

- **Kubernetes.** The appliance targets a single machine. A Helm chart can read
  the same `bom.yaml` later; `philter-ai-proxy/deploy/helm` is the pattern to
  follow. Compose-specific features are avoided so that stays cheap.
- **Phinder, Philter AI Proxy, Philter MCP.** Present in `bom.yaml` under the
  `full` profile but not yet wired into `docker-compose.yaml`.
- **Philter Scope and PhiSQL.** Neither repository has a Dockerfile, so there is
  nothing to containerize yet.
