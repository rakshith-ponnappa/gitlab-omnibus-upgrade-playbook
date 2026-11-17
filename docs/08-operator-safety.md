# 08 · Operator safety (bastions and VDI)

Many regulated environments only allow access through a privileged-access bastion, often from a VDI.
That adds failure modes that have nothing to do with GitLab.

## Sessions time out; your upgrade must not

- Run **everything** inside `tmux` or `screen` on the GitLab host, never directly in the bastion session:

  ```sh
  tmux new -s gitlab-upgrade      # reattach later with: tmux attach -t gitlab-upgrade
  ```

- Know the bastion's idle and maximum session limits before the window, and reconnect early rather than
  mid-migration.
- Log the terminal (`script -a ~/upgrade-<date>.log`) so evidence survives a dropped session.

## Copy-paste hygiene

- Paste commands into a plain-text editor first. VDI clipboards can introduce smart quotes, non-breaking
  spaces or line breaks.
- Paste **one command at a time** and read it before pressing Enter.
- Prefer scripts checked into a reviewed location over long pasted one-liners.

## Know which host you're on

- Put the hostname and environment in the prompt (`PS1`), and check it before every destructive step.
- Keep a separate, clearly labelled tab for the clone used in the dry run.

## Transfers and approvals

- Packages may need to be staged through an approved transfer path. Stage **all** packages for the
  window in advance and verify their checksums on the host.
- Some bastions require approval per session or per privileged command. Request access for the whole
  window plus the rollback buffer.

## Two-person rule

For each window, have one operator executing and one reviewing commands, timings and evidence. It
catches typos and makes the audit trail stronger.
