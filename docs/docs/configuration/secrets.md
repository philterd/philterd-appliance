# Secrets

Philter and Arbiter each require a base64-encoded 32-byte AES key and refuse to
start without one. `make bootstrap` generates both into `.env`, along with a
Philter bootstrap API key and an Arbiter admin password.

| Variable | Used by |
|---|---|
| `PHILTER_ENCRYPTION_KEY` | Philter, for encryption at rest |
| `ARBITER_CRYPTO_SECRET` | Arbiter, for credential encryption |
| `PHILTER_BOOTSTRAP_API_KEY` | Seeded onto Philter's admin user on first start |
| `ARBITER_ADMIN_INITIAL_PASSWORD` | Arbiter's bootstrap admin account |

`PHILTER_BOOTSTRAP_API_KEY` is applied only when the admin user has no keys yet,
and `ARBITER_ADMIN_INITIAL_PASSWORD` only when no admin account exists.

## Back up .env

!!! danger "Losing the encryption key loses the data"
    Data encrypted with `PHILTER_ENCRYPTION_KEY` cannot be recovered without it.
    Leaking it defeats encryption at rest entirely.

`.env` is written mode 600 and is gitignored. `make bootstrap` will not
overwrite an existing one, because rotating these keys orphans anything already
encrypted with the old ones. Delete the file deliberately if that is what you
want.

Re-running bootstrap with `CERT=` and `KEY=` updates only the certificate paths
and leaves the secrets untouched.

## Other variables

| Variable | Default | Does |
|---|---|---|
| `PHILTERSCOPE_PRIVACY` | `true` | Obfuscates PII in the Philter Scope UI |
| `PHILTERSCOPE_DATA` | `./data/philterscope` | Host directory the audit reads and writes |
| `APPLIANCE_UID` / `APPLIANCE_GID` | invoking user | Who the one-shot audit runs as |

`APPLIANCE_UID` and `APPLIANCE_GID` exist because the audit writes reports into
a bind-mounted host directory, so it has to run as the user that owns it rather
than as the image's own account.
