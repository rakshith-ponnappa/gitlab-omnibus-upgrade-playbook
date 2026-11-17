# 07 · Evidence and comms

## Evidence per hop

Capture the same set **before and after** every hop, so a diff shows exactly what changed:

| Item | Command or source |
|---|---|
| Versions | `gitlab-rake gitlab:env:info`, `version-manifest.txt`, PostgreSQL `SHOW server_version` |
| Service state | `gitlab-ctl status` |
| Health | `gitlab-rake gitlab:check SANITIZE=true` |
| Migrations | `db:migrate:status` down count, queued batched background migrations |
| Capacity | `df -h`, `free -h` |
| Backup | Backup file name, size and checksum; location of the secrets copy |
| Timings | Start and end of install, migrations and smoke tests |

[`scripts/precheck-collect.sh`](../scripts/precheck-collect.sh) gathers most of this into a timestamped folder.

## Comms rhythm

| When | Audience | Message |
|---|---|---|
| A week before | All users | Window dates, expected impact, what to finish beforehand |
| Window start | Users + stakeholders | GitLab broadcast message; "maintenance started" |
| After each hop | Change channel | Hop N of M done, checks passed, next step |
| Window end | All | Back in service (or rolled back), what changed, how to report issues |

### Hop status template

```text
[GitLab upgrade] Hop <n>/<m> → <version>: COMPLETE
- Install: OK (<duration>)
- gitlab:check: OK
- Background migrations: 0 queued
- Smoke tests: sign-in / clone / push / pipeline OK
Next: <next step or "window closed">
```

## Audit pack

At the end, bundle the change request, approvals, the evidence folders, timings, and any deviations
from the plan with their reasons. Regulated teams usually need this before closing the change.
