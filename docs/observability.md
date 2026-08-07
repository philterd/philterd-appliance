# Health and metrics coverage

What the appliance console can actually tell you about each product, and where
that falls short. Verified against the local checkouts on 2026-08-07.

## Current state

| Product | Health endpoint | Metrics | Notes |
|---|---|---|---|
| Philter 4.0 | `/actuator/health` | `/actuator/prometheus` | Fully instrumented. `management.endpoints.web.exposure.include=health,prometheus`, and `SecurityConfig` permits `/actuator/**` without authentication. |
| PhEye | `/status` | none | The handler returns the literal string `healthy` with no check behind it. |
| Redaction policy editor | none | none | Spring Boot with `web` and `thymeleaf` starters, no actuator dependency. |
| Arbiter | none | none | No actuator dependency in any of its three modules. |
| MongoDB | not HTTP | none | Probed by compose with `mongosh`, not visible to the console. |
| OpenSearch | `/` on 9200 | available but off | Not currently surfaced. |

## The gaps

**Arbiter has no health endpoint or metrics at all.** It is a Spring Boot
application, so adding `spring-boot-starter-actuator` and exposing
`health,prometheus` is close to the change already made in Philter 4.0. This is
the largest gap: Arbiter is the only appliance application whose status cannot
be distinguished from "the port answers".

**The redaction policy editor has no health endpoint or metrics.** Same
situation and same fix as Arbiter, though it is a smaller and more stateless
application, so the health signal matters less than the metrics one.

**PhEye's `/status` cannot fail.** It returns a constant, so it reports the
process is serving and nothing else. It cannot distinguish a loaded, working
model from one that is broken. PhEye also exposes no metrics, which means the
appliance has no visibility into inference latency or throughput, the numbers
most likely to explain a slow redaction.

**Only Philter can be scraped.** An appliance-wide Prometheus and dashboard is
not worth building until at least Arbiter and PhEye expose metrics.

## Why this matters for the appliance

The console currently reports "running" for three of four products purely
because their root path answers. That is honest but thin: a product can be
serving its login page while its database connection is broken, and the console
would still show it green.

Closing these gaps also benefits each product standalone, not just the
appliance, since health and metrics endpoints are what anyone running these in
production needs regardless of how they were deployed.
