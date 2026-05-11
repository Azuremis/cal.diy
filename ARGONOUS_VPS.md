# Argonous VPS Deployment

This Cal.diy checkout runs as owned Argonous scheduler infrastructure on the HSL VPS.

## Runtime

- VPS path: `/home/spirimi/websites/cal-diy`
- Compose project: `argonous-cal`
- Public preview host: `https://cal.hypersagi.com`
- Final host: `https://schedule.argonous.com`
- Web service: `argonous-cal-web`
- Database service: `argonous-cal-db`
- Redis service: `argonous-cal-redis`
- Caddy edge network: `hsl_edge`
- Private scheduler network: `argonous_cal_private`

Do not run the upstream `docker-compose.yml` directly in production. It publishes host ports and includes optional services that are not needed for the first scheduler rollout.

## Deploy

```bash
cd /home/spirimi/websites/cal-diy
docker compose -p argonous-cal up -d argonous-cal-db argonous-cal-redis
DOCKER_BUILDKIT=0 docker compose -p argonous-cal build argonous-cal-web
docker compose -p argonous-cal up -d argonous-cal-web
docker compose -p argonous-cal ps
```

## Smoke Checks

```bash
curl -fsS http://argonous-cal-web:3000 >/dev/null
curl -k -fsS --resolve cal.hypersagi.com:443:46.62.135.71 https://cal.hypersagi.com >/dev/null
curl -k -fsS --resolve cal.hypersagi.com:443:46.62.135.71 https://cal.hypersagi.com/embed/embed.js >/dev/null
```

## Backup

```bash
mkdir -p /home/spirimi/backups/argonous-cal
cd /home/spirimi/websites/cal-diy
docker compose -p argonous-cal exec -T argonous-cal-db \
  sh -lc 'pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB"' \
  | gzip > /home/spirimi/backups/argonous-cal/argonous-cal-$(date +%F).sql.gz
```

Keep secrets in `/home/spirimi/websites/cal-diy/.env`; do not commit them.

The VPS crontab runs this backup nightly at 02:17 UTC:

```cron
17 2 * * * /home/spirimi/websites/cal-diy/deploy/argonous-backup.sh >> /home/spirimi/backups/argonous-cal/backup.log 2>&1
```
