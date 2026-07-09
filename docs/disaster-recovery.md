# Disaster recovery

How the production database is backed up off-site, and how to restore it.

## What is (and isn't) protected

| Data | Where | Backed up? |
|---|---|---|
| **Primary database** (`storage/production.sqlite3` — users, charts, grids, tiles) | Kamal volume `mandala_rails_storage` | **Yes** — Litestream → Scaleway Object Storage (EU, `fr-par`), continuous |
| Solid Cache / Queue / Cable databases | same volume | No — disposable (canon C2.11); recreated from `db/*_schema.rb` by `db:prepare` on restore |
| **Active Storage blobs** (uploaded images) | same volume, `storage/xx/…` | **NOT YET** — see "Known gap" below |

> **This is structured-data DR, not full DR.** Until Active Storage blobs move
> off-server (#82 Part 2), a restore recovers the database but not uploaded
> images. Do not treat #74 as closed for full recovery.

## How it works

- A single long-lived **Litestream sidecar** (Kamal accessory `litestream`) is
  the *sole* replicator. It continuously ships WAL frames for the primary
  database to the Scaleway bucket `mandala-backups`, path `production`.
- The **web container restores on boot only when the database is missing**
  (`bin/docker-entrypoint`): restore to a temp file → `PRAGMA integrity_check`
  → atomic move. An existing live database is never overwritten; a partial or
  corrupt restore never boots (fail-closed, `set -e`).
- Retention: **30-day** point-in-time window (`config/litestream.yml`).

## Critical assumptions

- **WAL journal mode is required.** Rails 8 sets it by default for the SQLite
  adapter and the config does not override it. If `journal_mode` is ever
  changed, Litestream replication silently breaks — do not change it.
- **Fail-closed on S3 errors (verified).** On a credential/transport error the
  boot-time `restore -if-replica-exists` exits non-zero and creates no file, so
  `set -e` aborts the boot rather than starting fresh and clobbering a good
  replica. Verified: bad credentials → exit 1, no output file.

## Restore scenarios

### 1. Verify the backup any time (off-box, non-destructive)
Proves the replica is restorable without touching production. Needs the
Litestream binary and the Scaleway credentials in the environment.

```sh
export LITESTREAM_ENDPOINT=https://s3.fr-par.scw.cloud LITESTREAM_REGION=fr-par LITESTREAM_BUCKET=mandala-backups
export LITESTREAM_ACCESS_KEY_ID=… LITESTREAM_SECRET_ACCESS_KEY=…
litestream restore -config config/litestream.yml -o /tmp/check.sqlite3 /rails/storage/production.sqlite3
sqlite3 /tmp/check.sqlite3 'PRAGMA integrity_check;'   # expect: ok
sqlite3 /tmp/check.sqlite3 'SELECT count(*) FROM charts;'
```

### 2. Wiped volume / corrupted database on the existing box
Stop the app, remove the bad database file, redeploy. The entrypoint restores
automatically because the file is now missing:

```sh
kamal app stop
ssh <box> 'docker run --rm -v mandala_rails_storage:/s alpine rm -f /s/production.sqlite3 /s/production.sqlite3-wal /s/production.sqlite3-shm'
kamal deploy      # entrypoint: restore-if-db-not-exists → integrity_check → serve
```

### 3. Brand-new box (total loss)
Provision the box, then:

```sh
kamal setup                       # web container restores from Scaleway on first boot
kamal accessory boot litestream   # start the replicator against the restored db
```

Order matters on a first-ever setup: the web container creates/restores the
database; the Litestream accessory tolerates a not-yet-existing database file
(it polls and begins replicating once the file appears), so booting it after
the app is safe.

## Operational notes

- Sidecar logs: `ssh <box> 'docker logs mandala_rails-litestream'` — healthy
  output shows `replica sync` with `txid.replica == txid.db`.
- The credentials live in gitignored files (`.kamal/.litestream_*`), pulled
  into `.kamal/secrets` at deploy time; nothing secret is committed.
