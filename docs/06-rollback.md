# 06 · Rollback

In-place **downgrades are not supported**. Rolling back means returning the whole instance (package,
database, data and secrets) to the state from before the hop.

## Options, fastest first

| Option | When to use | Restores |
|---|---|---|
| **VM or disk snapshot** | Any failure during the window | Everything, exactly as it was |
| **Backup restore** | Snapshot unavailable or corrupt | Database, repositories, uploads, etc. Needs the **same GitLab version** installed plus the saved `gitlab-secrets.json` and `gitlab.rb` |
| **Fix forward** | Small, understood issue (e.g. a config key) with a known fix | Nothing; you stay on the new version |

## Decision points

Agree these in the change request **before** the window:

1. **Go/no-go after install:** services don't start, or `gitlab:check` fails with no quick fix → roll back.
2. **Migration gate:** background migrations fail and can't be retried or finalized inside the window → roll back.
3. **Smoke tests:** sign-in, clone/push or pipelines fail → roll back.
4. **Time box:** if the rollback must start by a fixed time to finish inside the window, start it then. Don't negotiate in the moment.

## Backup restore outline

```sh
sudo apt-get install gitlab-ee=<previous-version>-ee.0     # same version as the backup
sudo cp /secure/location/gitlab-secrets.json /secure/location/gitlab.rb /etc/gitlab/
sudo gitlab-ctl reconfigure
sudo gitlab-ctl stop puma && sudo gitlab-ctl stop sidekiq
sudo gitlab-backup restore BACKUP=<timestamp_of_backup>
sudo gitlab-ctl restart
sudo gitlab-rake gitlab:check SANITIZE=true
```

Docs: [Restore GitLab](https://docs.gitlab.com/administration/backup_restore/restore_gitlab/).

## After a rollback

- Collect the same evidence as for a successful hop.
- Write down the failure, logs (`sudo gitlab-ctl tail`, `/var/log/gitlab/`) and the decision time.
- Reproduce on the clone before rescheduling.
