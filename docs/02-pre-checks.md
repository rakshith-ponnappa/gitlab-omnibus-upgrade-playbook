# 02 · Pre-checks

Run these before **every** hop and save the output (see [`scripts/precheck-collect.sh`](../scripts/precheck-collect.sh)).

## Health

```sh
sudo gitlab-ctl status                              # every service "run"
sudo gitlab-rake gitlab:check SANITIZE=true         # configuration and integrity checks
sudo gitlab-rake gitlab:doctor:secrets              # can encrypted columns be decrypted?
```

Fix anything red before you start. Upgrading a broken instance makes failures harder to diagnose.

## Background migrations must be finished

A hop is only safe when the previous hop's background migrations are done.

- **Newer versions:** Admin area → Monitoring → Background migrations (nothing *Active* or *Failed*), or:

  ```sh
  sudo gitlab-rails runner -e production \
    'puts Gitlab::Database::BackgroundMigration::BatchedMigration.queued.count'
  ```

- **Older versions** (sidekiq-based background migrations):

  ```sh
  sudo gitlab-rails runner -e production 'puts Gitlab::BackgroundMigration.remaining'
  ```

Both must return `0`. See [Background migrations](https://docs.gitlab.com/update/background_migrations/).

## Capacity

```sh
df -h / /var/opt/gitlab /var/opt/gitlab/backups
free -h
```

Allow free space for **a full backup, the new package and PostgreSQL growth**. A PostgreSQL major
upgrade temporarily needs roughly the size of the database again.

## Backups (all three)

```sh
# Application backup (on very old versions: sudo gitlab-rake gitlab:backup:create)
sudo gitlab-backup create STRATEGY=copy

# Secrets and configuration are NOT in the application backup
sudo cp -a /etc/gitlab/gitlab-secrets.json /etc/gitlab/gitlab.rb /secure/location/
sudo cp -a /etc/ssh/ssh_host_* /secure/location/ssh/
```

Plus a **VM or disk snapshot** taken with GitLab stopped or quiesced, which is the fastest rollback.

## Change readiness

- [ ] Change request approved, maintenance window confirmed
- [ ] Users notified; broadcast message scheduled in GitLab
- [ ] Runners paused or drained (no jobs mid-flight)
- [ ] Exact target package version downloaded or available in the repo
- [ ] Rollback owner and decision time agreed
