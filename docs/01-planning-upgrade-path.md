# 01 · Planning the upgrade path

## 1. Know exactly where you are

```sh
sudo gitlab-rake gitlab:env:info          # GitLab, Ruby, PostgreSQL versions
cat /opt/gitlab/version-manifest.txt | head -1
sudo gitlab-psql -c 'SELECT version();'   # bundled PostgreSQL
cat /etc/os-release
```

Record the **edition** (CE or EE), the **exact version** (e.g. `12.1.x`), the OS release and
whether PostgreSQL is bundled or external. All four affect the path.

## 2. Generate the required stops

GitLab requires you to pass through specific versions ("required upgrade stops") so that each set
of database migrations runs in order. Don't work them out by hand. Use:

- **Upgrade Path tool:** <https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/>
- **Upgrade paths docs:** <https://docs.gitlab.com/update/upgrade_paths/>

Notes:

- Starting from 12.x you should expect **many** stops (several per major version). Always land on the
  latest patch release of each stop's minor version.
- In recent major versions GitLab schedules required stops at predictable minor versions; confirm the
  current list in the docs above, since it changes over time.
- Read the **version-specific upgrade notes** for every major version you cross. They list breaking
  changes, removed features and manual steps.

## 3. Find the non-GitLab milestones

| Milestone | Why it matters | Where to check |
|---|---|---|
| Minimum PostgreSQL version | Newer majors refuse to start on older PostgreSQL | [Requirements](https://docs.gitlab.com/install/requirements/) and [04 PostgreSQL](04-postgresql.md) |
| OS support | Packages stop being built for old OS releases | [Supported OSes](https://docs.gitlab.com/install/package/) |
| Runner compatibility | Old runners can fail against new APIs | [05 Runners](05-runners-and-integrations.md) |
| Deprecations and removals | Features you rely on may disappear | [Deprecations](https://docs.gitlab.com/update/deprecations/) |

If an OS upgrade is needed mid-path, do it at a stop **where both the old and new OS have packages**
for that exact GitLab version, and treat it as its own window.

## 4. Group stops into windows

- Put **one to three hops** in a window, depending on how long background migrations took in your
  dry run.
- Schedule PostgreSQL upgrades and OS upgrades as **separate** windows.
- Leave room for rollback in every window: snapshot restore time plus validation.

## 5. Dry-run on a clone

Restore a recent backup (plus `gitlab-secrets.json`) onto a clone VM and run the first windows end to
end. Record how long each hop and its migrations take; use those timings for the change requests.
