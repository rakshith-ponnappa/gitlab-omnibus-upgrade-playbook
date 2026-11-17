# Change request: GitLab upgrade window `<n>`

| Field | Value |
|---|---|
| Change type | Normal / pre-approved standard change |
| Service | GitLab (self-managed, Omnibus) at `gitlab.example.com` |
| Window | `<date>` `<start>`–`<end>` (`<timezone>`) |
| Hops in this window | `<from>` → `<stop 1>` → `<stop 2>` |
| Expected user impact | GitLab unavailable for the whole window; CI jobs paused |
| Implementer / reviewer | `<names or roles>` |

## Reason

Bring GitLab to a supported release, receive security fixes and keep the remaining upgrade path short.

## Plan

1. Pre-checks and evidence (`docs/02-pre-checks.md`).
2. Backup, secrets copy and VM snapshot.
3. For each hop: pinned install → verification → background-migration gate (`docs/03-hop-runbook.md`).
4. Post-change validation and comms.

## Risk and mitigation

| Risk | Mitigation |
|---|---|
| Migration failure | Dry-run on a clone; migration gate between hops; rollback plan |
| Longer than planned | Hops ordered so the window can stop cleanly after any hop |
| Session loss on the bastion | All work in `tmux`; terminal logging |
| Data loss | Application backup + secrets + snapshot taken and verified first |

## Rollback

Restore the VM snapshot `<snapshot id>` (estimated `<duration>`). Alternative: reinstall `<previous version>`
and restore backup `<backup name>` with the saved secrets (`docs/06-rollback.md`).
**Rollback decision deadline:** `<time>`.

## Validation

`gitlab:check` clean, 0 migrations down, background migrations at 0, smoke tests passed,
and runners online.

## Approvals

| Role | Name | Date |
|---|---|---|
| Service owner | | |
| Change manager | | |
| Security (if required) | | |
