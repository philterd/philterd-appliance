# Philter Scope

Philter Scope measures how well a policy actually redacts, by scoring Philter's
output against a golden dataset of labelled PII. It ships as two binaries in one
image, so the appliance runs it in two pieces.

## Evaluation UI

Runs continuously on port 8447 and reads audits from the appliance's MongoDB.

Privacy mode obfuscates PII in the UI and is on by default, since an appliance
holds real data. Set `PHILTERSCOPE_PRIVACY=false` in `.env` to see unmasked
values while tuning a policy.

## Audit

A one-shot command in the `tools` profile, so it is never started by `make up`.
Put your data under `data/philterscope/` as `golden/` and `raw/`, then:

```sh
docker compose run --rm philterscope-audit \
  --golden /data/golden --input /data/raw --output /data --threshold 0.75
```

It writes `report.html` and `report.json` back to that directory and stores the
audit in MongoDB, where the UI picks it up.

The Philter URL and API token are already pointed at the appliance's own
Philter. Passing your own `--url` or `--token` overrides them, since a flag on
the command line appears later and wins.

| Flag | Does |
|---|---|
| `--golden` | Directory of labelled golden data |
| `--input` | Directory of raw text to score |
| `--output` | Where reports are written |
| `--threshold` | Recall threshold for suggestions |
| `--thresholds` | Per-entity thresholds, e.g. `NAME=0.9,SSN=1.0` |
| `--policy` | Philter policy to audit against |
| `--group` | Names the audit in the UI |
| `--ai` | Enables policy recommendations, needs Ollama |

Because it writes into a host directory, the audit runs as `APPLIANCE_UID` and
`APPLIANCE_GID` rather than as the image's own account. `make bootstrap` fills
those in from the invoking user.

## Two behaviours to know

Files that are already Philter *explain* JSON are scored directly without
calling Philter. This is how the bundled examples work offline.

!!! warning "Skipped files do not fail the run"
    A file that Philter fails to redact is skipped with a warning, and the audit
    still writes a report and exits 0. An audit against an unreachable Philter
    therefore reports a score computed over nothing. Check the file count in the
    report before trusting it. Tracked in
    [philterd/philterscope#8](https://github.com/philterd/philterscope/issues/8).
