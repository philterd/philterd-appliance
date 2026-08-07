# Image publishing

The appliance builds any component whose image is not published, tagging it
with the name it will eventually carry. That keeps the appliance shippable, but
every component still on the build tier costs users a local build on first run,
so the tier should shrink over time.

## Status as of 2026-08-07

Verified against Docker Hub and the local checkouts.

### Published, with tags

| Component | Newest tag |
|---|---|
| `philterd/philter` | 3.4.1 |
| `philterd/ph-eye` | 1.3.0 (per-model and `-gpu` variants) |
| `philterd/philterd-redaction-policy-editor` | 1.0.0 |
| `philterd/philter-api-ref` | latest |

### Built locally

| Component | Why | Distance to promotion |
|---|---|---|
| `philter` | 4.0 is unreleased. Newest git tag is 3.4.0, newest Hub tag is 3.4.1, local tree is `4.0.0-SNAPSHOT`. | Release 4.0.0. |
| `philter-mcp` | Has a Docker workflow that already tags `philterd/philter-mcp:latest`, but nothing is on Hub, so the job builds without pushing. | Add push and registry credentials. Closest to done. |
| `philter-ai-proxy` | Hub repository exists but carries zero tags. | Add publishing CI. |
| `arbiter` | Has a Dockerfile, no publishing CI. | Add publishing CI. |
| `phinder` | Has a Dockerfile, no publishing CI. | Add publishing CI. |
| `philterscope` | Had no Dockerfile at all. One was written for the appliance and is not yet merged upstream. | Merge the Dockerfile, then add publishing CI. |

### Not containerizable yet

`phisql` has no Dockerfile in its repository.

`phield` is not checked out locally and has not been assessed.

## Notes

`philterd/philter-ui` no longer applies. Philter 4.0 serves its own Vaadin
dashboard from the same port as the API, so the separate UI container is gone.
The Hub repository still holds 3.x tags, and the image is built from a JAR on
`artifacts.philterd.ai` rather than from a repository in the org.

`philterd/philter-router` also has a Hub repository with zero tags. It is not
currently part of the appliance.

## Promoting

1. Add publishing CI to the product repository. `philter-ai-proxy` is the
   reference for repositories that also ship a Helm chart.
2. Confirm the tag exists: `docker manifest inspect philterd/<name>:<version>`.
3. In `bom.yaml`, set `source: registry` and remove the `dir`, `repo` and `ref`
   keys.
4. Run `make images && make doctor`.

No other file changes. Nothing outside `bom.yaml` refers to a component's tier.
