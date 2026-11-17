# 04 · PostgreSQL

Omnibus bundles PostgreSQL, and newer GitLab majors require newer PostgreSQL majors. Treat each
PostgreSQL upgrade as its own milestone with its own backup and window.

## Check before every major GitLab version

```sh
sudo gitlab-psql -c 'SHOW server_version;'
```

Compare against the [requirements page](https://docs.gitlab.com/install/requirements/) for the GitLab
version you are about to install. A GitLab major that needs a newer PostgreSQL won't upgrade on
the old one.

## Upgrading the bundled PostgreSQL

```sh
sudo gitlab-backup create STRATEGY=copy        # fresh backup first
sudo gitlab-ctl pg-upgrade                     # to the default newer version shipped in the package
# or pick a version shipped in the package:
sudo gitlab-ctl pg-upgrade -V <major>
```

Notes:

- The upgrade needs **free disk roughly equal to the database size**.
- It stops GitLab for the duration. Time it in your dry run.
- Old data stays under `/var/opt/gitlab/postgresql/` until you remove it with
  `sudo gitlab-ctl cleanup-old-data`, after the new version has been verified.

Docs: [Omnibus database settings](https://docs.gitlab.com/omnibus/settings/database/).

## When to reindex

Rebuild indexes when the **operating system changes the C library (glibc) version**, for example
during an OS major upgrade or migration to a new VM image. Collation changes can silently corrupt
text indexes and break uniqueness. GitLab documents this under
[upgrading operating systems for PostgreSQL](https://docs.gitlab.com/administration/postgresql/upgrading_os/).

```sh
sudo gitlab-ctl stop puma && sudo gitlab-ctl stop sidekiq
sudo gitlab-psql -c 'REINDEX DATABASE gitlabhq_production;'
sudo gitlab-ctl start
```

Plan for the reindex to take a long time on large instances, and run it in `tmux`.

## Post-upgrade checks

```sh
sudo gitlab-psql -c 'SHOW server_version;'
sudo gitlab-rake gitlab:check SANITIZE=true
sudo gitlab-rake db:migrate:status | grep -c ' down '   # expect 0
```
