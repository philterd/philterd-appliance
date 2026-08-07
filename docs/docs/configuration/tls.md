# TLS

The nginx proxy terminates TLS for every port from a single certificate.
Products behind it serve plain HTTP on the internal network, so there is one
termination point rather than a certificate per product.

## Generated certificate

`make bootstrap` generates a self-signed certificate into `proxy/tls/`, valid
for ten years, with subject alternative names covering:

- `localhost` and `127.0.0.1`
- this host's name, long and short
- its routable addresses

Covering the addresses matters. A browser validates the name it was given, so a
certificate for `localhost` alone would warn for anyone connecting over the
network.

Addresses are read per interface rather than from `hostname -I`, which also
returns the gateway address of every Docker bridge. Interfaces named `docker*`,
`br-*`, `veth*`, `virbr*`, `cni*` and `kube*` are skipped.

Nothing vouches for a self-signed certificate, so browsers warn until it is
trusted. Import `proxy/tls/appliance.crt` into your trust store to silence that.

`proxy/tls/` is gitignored, since it holds a private key.

## Using your own certificate

```sh
make bootstrap CERT=/etc/ssl/philterd.crt KEY=/etc/ssl/philterd.key
```

Bootstrap checks the file is readable PEM, prints its subject and expiry, and
records absolute paths in `.env` as `APPLIANCE_TLS_CERT` and
`APPLIANCE_TLS_KEY`. Those are what the proxy bind-mounts.

Swapping certificates is therefore a change of mount source, never a change of
nginx configuration. Existing secrets are left alone.

Restart the proxy to pick up a new certificate:

```sh
docker compose up -d proxy
```

## Renewal

There is no automatic renewal. A certificate from your own CA has to be replaced
before it expires, either by overwriting the files the paths point at or by
re-running bootstrap against new ones.
