# Local LLM

The appliance runs [Ollama](https://ollama.com/) as shared infrastructure under
the `full` profile. It is not a Philterd product and is not wrapped in one: it
is a backing service, like MongoDB and OpenSearch, that several products point
at.

Nothing leaves the machine. Because inference happens on the box, prompts are
not routed through Philter AI Proxy, which exists to redact prompts before they
cross your boundary to a third-party provider. That remains the right tool when
a product talks to OpenAI, Bedrock or Gemini; it has no job to do here.

## Consumers

| Product | Feature | How it is configured |
|---|---|---|
| Philter Scope | `--ai` policy recommendations | `PHILTERSCOPE_OLLAMA_URL` and `PHILTERSCOPE_OLLAMA_MODEL`, set by the appliance |
| Arbiter | LLM-as-a-Judge, "Second Opinion" | Registered at runtime in the admin UI |

## The model

Ollama starts with no models, so the appliance runs a one-shot `ollama-init`
that pulls the configured one and exits.

```
OLLAMA_MODEL=gemma3:4b
```

This drives both the pull and the model Philter Scope asks for, so the two
cannot drift apart. `gemma3:4b` is about 3 GB, downloaded the first time the
`full` profile starts.

Philter Scope's own default is `gemma4`, which is better and about 9 GB. The
appliance picks the smaller one so a first run is not a 9 GB download; set
`OLLAMA_MODEL=gemma4` before that first start to match Philter Scope standalone.

Models are kept in the `ollama-models` volume and survive `make down`.
`make destroy` deletes them, and the next start downloads again.

## Wiring Arbiter to it

Arbiter stores its Ollama instances in MongoDB, registered through the admin UI,
so the appliance cannot pre-configure that part. One admin step after
`make up-full`:

**Admin → LLM-as-a-Judge**, register an instance at `http://ollama:11434` and set
it as the default for Second Opinion.

The host allow-list is already handled. Arbiter refuses private-range hosts as an
SSRF guard, which every appliance service resolves to, so the compose file sets
`ARBITER_DATASOURCES_ALLOWEDHOSTS` to `ollama,philter,opensearch`. Without that,
a registered instance would be created and then rejected at call time.

Removing the remaining manual step is tracked in
[philterd/arbiter#9](https://github.com/philterd/arbiter/issues/9).

Arbiter audits every call that sends PII to an LLM, so those records appear in
its audit log even though the model is local.

## Hardware

Inference on CPU works but is slow. Ollama will use an NVIDIA GPU when the
container runtime exposes one.

PhEye also has `-gpu` image variants. On a single box both compete for the same
device, so decide which one gets it rather than discovering the contention under
load. Detection latency affects every redaction request; the LLM features are
occasional and interactive, so PhEye usually has the stronger claim.

## Not exposed to the host

Ollama has no web interface, so nothing is proxied and no host port is bound. It
is reachable only from inside the appliance network as `http://ollama:11434`.
The console shows its status by listing loaded models, which proves the API
works rather than only that the port is open.
