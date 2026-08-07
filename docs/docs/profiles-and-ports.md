# Profiles and ports

## Profiles

| Profile | Services | Use |
|---|---|---|
| `core` (default) | console, Philter, PhEye, MongoDB, policy editor, Philter Scope | Redaction API, policy authoring and scoring |
| `full` | core plus Arbiter and OpenSearch | Adds human-in-the-loop review |
| `tools` | one-shot commands, never started by `up` | Runs the Philter Scope audit |

```sh
make up        # core
make up-full   # everything
```

Services with no `profiles` key in `docker-compose.yaml` belong to `core` and
always start.

Arbiter's own compose stands up MinIO, Postgres and Elasticsearch, but those
back its demo data sources. The appliance follows its `docker-compose.prod.yaml`
instead, which needs MongoDB and OpenSearch alone with
`ARBITER_DEMO_DATA_ENABLED=false`. Configure real data sources through Arbiter's
admin UI.

## Ports

Only the proxy binds to the host. Philter, PhEye, MongoDB and OpenSearch stay on
the internal network.

| Port | Service |
|---|---|
| 8443 | Console |
| 8444 | Philter API and dashboard |
| 8445 | Redaction policy editor |
| 8446 | Arbiter (`full` profile only) |
| 8447 | Philter Scope evaluation UI |

Every port is HTTPS. Override any of them in `.env`.

Each product gets its own port rather than a path prefix, because Philter's
Vaadin dashboard and Arbiter's Spring UI both assume they are served from the
root of their origin. This also resolves the collision where Philter, Arbiter
and the policy editor all listen on 8080 inside their own containers.

Consolidating onto path prefixes is possible later, once each application is
confirmed to support a configurable base path.
