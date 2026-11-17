# 03 · Hop runbook

Repeat this for every required stop. Copy [`templates/hop-checklist.md`](../templates/hop-checklist.md)
into the change record and tick it off as you go.

## 0. Start a resilient session

```sh
tmux new -s gitlab-upgrade        # or: screen -S gitlab-upgrade
script -a ~/upgrade-$(date +%F).log
```

## 1. Pre-hop evidence

```sh
sudo ./scripts/precheck-collect.sh before-<target-version>
```

Stop if any check fails or background migrations are not at zero.

## 2. Backup

```sh
sudo gitlab-backup create STRATEGY=copy
sudo cp -a /etc/gitlab/gitlab-secrets.json /etc/gitlab/gitlab.rb /secure/location/<target-version>/
```

If you have just taken your own backup, you can skip the package's automatic database backup:

```sh
sudo touch /etc/gitlab/skip-auto-backup
```

## 3. Install the pinned version

Never install "latest". Pin the exact version of this stop.

```sh
# Debian/Ubuntu
apt-cache madison gitlab-ee | head
sudo apt-get install gitlab-ee=<version>-ee.0

# RHEL-compatible
sudo yum --showduplicates list gitlab-ee | tail
sudo yum install gitlab-ee-<version>-ee.0.el8
```

The package runs `gitlab-ctl reconfigure` and the database migrations. Watch the output for errors.

## 4. Verify

```sh
sudo gitlab-ctl status
sudo gitlab-rake gitlab:check SANITIZE=true
sudo gitlab-rake db:migrate:status | grep -c ' down ' # expect 0
curl -fsS https://gitlab.example.com/-/readiness?all=1  # from an allowed host
```

Smoke tests (UI or API):

- [ ] Sign in (local and LDAP user)
- [ ] Clone and push over HTTPS and SSH
- [ ] Open a merge request; view a pipeline
- [ ] A runner picks up a test job

## 5. Gate before the next hop

```sh
sudo gitlab-rails runner -e production \
  'puts Gitlab::Database::BackgroundMigration::BatchedMigration.queued.count'
```

- `0` and nothing failed → collect `after-<version>` evidence and continue.
- Still running → wait. Don't start the next hop.
- Failed → retry or finalize per the [background migrations docs](https://docs.gitlab.com/update/background_migrations/),
  or roll back.

## 6. Close the hop

```sh
sudo ./scripts/precheck-collect.sh after-<target-version>
sudo rm -f /etc/gitlab/skip-auto-backup
```

Post a status update ([07 Evidence and comms](07-evidence-and-comms.md)).
