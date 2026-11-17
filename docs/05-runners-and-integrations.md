# 05 · Runners and integrations

## GitLab Runner compatibility

- Keep runners on the **same major.minor as the GitLab server**, or as close as possible. Older
  runners may miss features or fail against newer APIs. See
  [Runner compatibility](https://docs.gitlab.com/runner/#gitlab-runner-versions).
- Upgrade runners **after** the server reaches each major version, not before.
- Pause or drain runners before each hop so no job is interrupted mid-upgrade.

```sh
gitlab-runner --version
sudo gitlab-runner verify          # confirms each registered runner can talk to the server
```

## The runner authentication-token workflow

Newer GitLab versions replace **registration tokens** with **runner authentication tokens**
(`glrt-…`) created in the UI or API. The old registration flow is deprecated, disabled by default
in newer releases and scheduled for removal. Plan to move runners across before the stop where it
stops working for you:

1. In GitLab, create the runner (instance, group or project) and copy its `glrt-` token.
2. On the runner host:

   ```sh
   sudo gitlab-runner register \
     --non-interactive \
     --url "https://gitlab.example.com" \
     --token "<runner-authentication-token>" \
     --executor "docker" \
     --docker-image "alpine:latest"
   ```

3. Remove the old runner entry from `config.toml` and from the GitLab UI.

Docs: [Migrating to the new runner registration workflow](https://docs.gitlab.com/ci/runners/new_creation_workflow/).

## LDAP

```sh
sudo gitlab-rake gitlab:ldap:check
```

Run it before the first hop and after each one. Confirm a known LDAP user can sign in during the
smoke tests. Certificate-validation defaults have tightened over time, so test LDAPS against the CA
your directory actually uses.

## Other integrations to re-test after the final hop

- [ ] Outgoing email (password reset, notifications)
- [ ] Webhooks and system hooks
- [ ] Container registry push and pull
- [ ] Object storage (artifacts, LFS, uploads): `sudo gitlab-rake gitlab:artifacts:check`, `gitlab:lfs:check`, `gitlab:uploads:check`
- [ ] Backups still complete and are picked up by your backup tooling
- [ ] Monitoring and alerting still scrape the endpoints you use
