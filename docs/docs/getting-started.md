# Getting started

## Requirements

- Docker with Compose v2
- `openssl` and `make`
- Python 3 with PyYAML, used by the bill of materials tooling

Most components are built from source today, so the first run needs a working
Go and Java toolchain inside Docker and enough disk for the model images. See
[Image publishing](publishing.md).

## Run it

```sh
make bootstrap   # generate .env and a TLS certificate
make build       # build the components that are not published yet
make up          # start the core profile
```

Then open `https://localhost:8443/`.

`make bootstrap` generates a self-signed certificate, so browsers warn until it
is trusted or replaced. See [TLS](configuration/tls.md).

## Building from source

`make build` prefers a sibling checkout when one exists, so iterating on a
product does not require pushing first. The appliance expects sibling clones one
level up:

```
philterd/
├── philter/
├── arbiter/
└── philterd-appliance/    <- you are here
```

Without a sibling checkout, Docker builds straight from the component's git URL
in `bom.yaml`. That needs network access and is slower, but it keeps this
repository free of submodules and vendored source.

## Everyday commands

| Command | Does |
|---|---|
| `make up` | Start the core profile |
| `make up-full` | Start everything, including Arbiter |
| `make down` | Stop, keeping data volumes |
| `make destroy` | Stop and delete data volumes |
| `make logs` | Follow logs |
| `make bom` | List components and their tiers |
| `make doctor` | Check that components resolve |
| `make images` | Regenerate `.env.images` from `bom.yaml` |

`make destroy` deletes MongoDB and OpenSearch data. There is no backup step yet.
