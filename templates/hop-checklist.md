# Hop checklist: `<current-version>` → `<target-version>`

Change ref: `<CR-number>` · Window: `<start>`–`<end>` · Operator: `<name>` · Reviewer: `<name>`

## Before

- [ ] `tmux`/`screen` session started on the GitLab host; terminal logging on
- [ ] `scripts/precheck-collect.sh before-<target-version>` run; output saved
- [ ] `gitlab-ctl status` all services running
- [ ] `gitlab:check SANITIZE=true` clean
- [ ] Background migrations: **0 queued, 0 failed**
- [ ] Free disk ≥ backup size + package + headroom
- [ ] `gitlab-backup create` done: file `<name>`, size `<size>`
- [ ] `gitlab-secrets.json` and `gitlab.rb` copied to `<secure location>`
- [ ] VM/disk snapshot taken: `<snapshot id>`
- [ ] Runners paused or drained; broadcast message live
- [ ] Target package `<exact version>` available and checksum verified

## Upgrade

- [ ] Installed **pinned** version `<exact version>` (start `<time>`, end `<time>`)
- [ ] No errors in reconfigure or migration output

## After

- [ ] `gitlab-ctl status` all services running
- [ ] `gitlab:check SANITIZE=true` clean
- [ ] `db:migrate:status`: 0 migrations down
- [ ] Smoke tests: sign-in (local + LDAP), clone/push HTTPS + SSH, MR view, pipeline on a runner
- [ ] Background migrations reached 0 (end `<time>`)
- [ ] `scripts/precheck-collect.sh after-<target-version>` run; output saved
- [ ] Status update posted

## Decision

- [ ] **Continue** to the next stop · [ ] **Stop here** (window closing) · [ ] **Roll back** (reason: `<reason>`)

Notes:
