#!/usr/bin/env sh
set -eu

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
project_dir="/home/spirimi/websites/cal-diy"
backup_dir="/home/spirimi/backups/argonous-cal"
retention_days="${ARGONOUS_CAL_BACKUP_RETENTION_DAYS:-30}"
timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
target="${backup_dir}/argonous-cal-${timestamp}.sql.gz"

mkdir -p "$backup_dir"

cd "$project_dir"
docker compose -p argonous-cal exec -T argonous-cal-db \
  sh -lc 'pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB"' \
  | gzip > "$target"

test -s "$target"
find "$backup_dir" -type f -name 'argonous-cal-*.sql.gz' -mtime +"$retention_days" -delete
printf '%s\n' "$target"
