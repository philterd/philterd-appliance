# Console

The console is the appliance's own image: a launcher over the other products. It
lists each application, shows whether it is running, and links out to its own
interface. It does not embed or aggregate them.

It is served on port 8443 and is the appliance's landing page.

## Health probes

The browser cannot reach the internal network, but the console can. It proxies
one probe per product under `/probe/<name>`, and the page polls those
same-origin every 15 seconds. That avoids both CORS and a certificate prompt
against each product's port.

Any HTTP status from a product counts as running, including a redirect to a
login page or a 401. Only a 502 or 504 from the console's own nginx means
unreachable.

| Product | Probe | Signal |
|---|---|---|
| Philter | `/actuator/health` | Real health check |
| PhEye | `/status` | Fixed string, so process liveness only |
| Policy editor | `/` | Serving or not |
| Arbiter | `/` | Serving or not |
| Philter Scope | `/` | Serving or not |

Only Philter reports genuine health. A product can be serving its login page
with a broken database connection and still show as running. See
[Health and metrics](../observability.md).

MongoDB and OpenSearch are not shown, since neither is reachable over HTTP in a
way the console can probe meaningfully.

## Ports in links

Host ports are substituted into the page at container start rather than
hardcoded, so the tiles follow whatever is set in `.env`. The hostname comes
from the browser, so links stay correct when the appliance is reached from
another machine.

## Replacing it

The console is currently a static page served by nginx. Nothing else in the
appliance depends on how it is implemented, only on the image name
`philterd/philterd-appliance-console` and that it serves port 80.
