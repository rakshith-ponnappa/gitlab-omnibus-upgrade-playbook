#!/usr/bin/env bash
# Read-only evidence collector for GitLab Omnibus upgrades.
# Run on the GitLab host before and after every hop, e.g.:
#   sudo ./scripts/precheck-collect.sh before-16.11
#   sudo ./scripts/precheck-collect.sh after-16.11
# Writes ./precheck-<label>-<timestamp>/ with one file per check. Changes nothing on the system.
set -euo pipefail

label="${1:-snapshot}"
out="precheck-${label}-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$out"

run() {
  # run <file> <command...>: capture stdout+stderr, never abort the whole collection
  local file="$1"
  shift
  echo "+ $*" >"$out/$file"
  if "$@" >>"$out/$file" 2>&1; then
    echo "ok    $file"
  else
    echo "WARN  $file (exit $?)"
  fi
}

run 01-version-manifest.txt head -n 1 /opt/gitlab/version-manifest.txt
run 02-env-info.txt gitlab-rake gitlab:env:info
run 03-services.txt gitlab-ctl status
run 04-gitlab-check.txt gitlab-rake gitlab:check SANITIZE=true
run 05-migrate-status.txt gitlab-rake db:migrate:status
run 06-batched-migrations.txt gitlab-rails runner -e production \
  'puts "queued=#{Gitlab::Database::BackgroundMigration::BatchedMigration.queued.count}" rescue puts "batched migrations not available on this version"'
run 07-legacy-background-migrations.txt gitlab-rails runner -e production \
  'puts "remaining=#{Gitlab::BackgroundMigration.remaining}" rescue puts "not available"'
run 08-postgresql-version.txt gitlab-psql -c 'SHOW server_version;'
run 09-disk.txt df -h
run 10-memory.txt free -h
run 11-os-release.txt cat /etc/os-release

down_count=$(grep -c ' down ' "$out/05-migrate-status.txt" || true)
echo
echo "Evidence written to: $out/"
echo "Migrations down: ${down_count}"
grep -h -E '^(queued|remaining)=' "$out"/06-*.txt "$out"/07-*.txt 2>/dev/null || true
