# Bill of materials

`bom.yaml` is the single source of truth for what the appliance ships. Each
component records its image reference and how that image comes into existence.

| `source` | Meaning |
|---|---|
| `registry` | Published, pulled as-is |
| `build` | Not published yet, so the appliance builds it and tags it with the name it will carry once it is |

Because built images are tagged with their eventual registry name, nothing
outside `bom.yaml` knows which tier a component is in. `docker-compose.yaml`
refers to every component through an `IMG_*` variable rendered by
`make images`.

```yaml
components:
  - name: philter
    image: philterd/philter
    version: "4.0.0-SNAPSHOT"
    source: build
    dir: philter
    repo: https://github.com/philterd/philter.git
    ref: main
    profile: core
```

## Commands

```sh
make bom       # list components and their tiers
make doctor    # check registry components resolve and builds exist
make images    # regenerate .env.images
```

`bin/appliance-bom build --dry-run` prints what would be built and from where,
without building it.

## How a build resolves

For a `source: build` component, in order:

1. `context`, for components built from this repository, such as the console.
2. A sibling checkout at `../<dir>`, when one exists.
3. The remote git URL, as `repo#ref`.

Preferring a sibling checkout means iterating on a product does not require
pushing first. Falling back to a remote context keeps this repository free of
submodules and vendored source.

## Promoting a component

When a product gains publishing CI:

1. Confirm the tag exists: `docker manifest inspect philterd/<name>:<version>`
2. In `bom.yaml`, set `source: registry` and remove `dir`, `repo` and `ref`
3. Run `make images && make doctor`

No other file changes. See [Image publishing](../publishing.md) for what is
still on the build tier.
