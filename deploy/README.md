# Deploy DXH Gateway Community Edition

CE is one container plus a PostgreSQL database. Any platform that keeps exactly one copy of the
container running all the time, and lets it reach PostgreSQL directly, can host it. This page
covers a server of your own (VPS, DigitalOcean Droplet, Hetzner Cloud, Lightsail) and four hosted
platforms.

| Platform | How | Status |
|---|---|---|
| [VPS or Droplet](#vps-or-droplet) | `install.sh`, or `cloud-init.yaml` for a new server | Installer tested end to end with Docker; on a public host not yet |
| [DigitalOcean App Platform](#digitalocean-app-platform) | Deploy button, `.do/deploy.template.yaml` | Not yet tested on the platform |
| [Render](#render) | Deploy button, `render.yaml` | Validated against Render's Blueprint schema; not yet deployed |
| [Railway](#railway) | Steps below | Not yet tested on the platform |
| [Fly.io](#flyio) | `fly.toml` below | Not yet tested on the platform |

Vercel and other serverless platforms cannot run it: see [why](#why-not-vercel-or-serverless).

## What every platform needs

- **The CE terms accepted.** Read [LICENSE-CE.txt](../LICENSE-CE.txt), then set
  `GATEWAY_CE_TERMS_ACCEPTED` to the version it names, `2026-09-18.1`. Without it the gateway does
  not start.
- **One instance, and upgrades that stop it first.** CE holds a database lock for as long as it
  runs, and a second copy refuses to start with `CE_INSTANCE_LIMIT`. Keep the instance count at 1
  with autoscaling off. A platform that starts the new version next to the old one fails the
  upgrade and leaves the old version running; each section below says how to avoid that.
- **A direct database connection.** The lock belongs to one database session, so a transaction
  pooler (PgBouncer in transaction mode, or a provider's "pool" connection string) breaks it. When
  the provider offers a pooled and a direct connection string, use the direct one.
- **Two secrets**, each from `openssl rand -base64 32`: `AUTH_SECRET` signs sessions,
  `GATEWAY_ENCRYPTION_KEY` encrypts the credentials stored in the database. Keep the encryption
  key with the database backups: without it the stored credentials cannot be read again.
- **`PUBLIC_URL`**: the `https://` address people open. Sign-in and OAuth redirects use it.
- **Memory**: at least 512 MB for the gateway. It used about 215 MiB while idle in our test.
- **`MCP_ALLOW_PRIVATE_NETWORK_TARGETS=false`** when the gateway is reachable from the internet:
  it then refuses MCP servers on private network addresses. The platform templates set it. Leave
  the default (`true`) only when the gateway has to reach MCP servers on your internal network.

After the first start, on every platform:

1. Open `PUBLIC_URL` and register the first account straight away: it becomes the owner.
2. Set `AUTH_SIGNUP_MODE=invite_only` and restart, so nobody else can sign up uninvited.
3. Connect an AI client: see [Connect an AI client](../README.md#connect-an-ai-client), with your
   `PUBLIC_URL` in place of `http://localhost:3001`.

Before every upgrade, read the [upgrade notes](../docs/help/deployment/upgrade-notes.md) of each
version you skip and back up the database.

## VPS or Droplet

A Linux server with at least 1 GB of memory, Docker Engine with the Compose plugin, `curl` and
`openssl`. The installer can install Docker on Linux for you (`--install-docker`, through
get.docker.com).

```sh
curl -fsSL https://raw.githubusercontent.com/DXHeroes/mcp-gateway/beta/install.sh | sh -s -- --domain gateway.example.com
```

To read the script before it runs:

```sh
curl -fsSLO https://raw.githubusercontent.com/DXHeroes/mcp-gateway/beta/install.sh
less install.sh
sh install.sh --domain gateway.example.com
```

The installer asks you to accept the CE terms on the terminal. Then it creates `./mcp-gateway`,
downloads `compose.yaml`, writes `.env` (mode 600) with a generated database password,
`AUTH_SECRET` and `GATEWAY_ENCRYPTION_KEY`, and starts the newest release with
`docker compose up -d --wait`.

| Option | What it does |
|---|---|
| `--dir DIR` | Install into `DIR` instead of `./mcp-gateway` |
| `--domain HOST` | Serve `https://HOST` through Caddy, which obtains a Let's Encrypt certificate |
| `--install-docker` | On Linux, install Docker Engine first when it is missing |

**HTTPS.** With `--domain`, the DNS record of `HOST` must point at the server and ports 80 and 443
must be open, because the certificate is issued over them. The installer writes
`PUBLIC_URL=https://HOST` and `COMPOSE_FILE=compose.yaml:compose.https.yaml` into `.env`, so plain
`docker compose ps` and `docker compose logs` in that directory include Caddy. Without a domain the
gateway listens on `127.0.0.1:3001` only; reach it with `ssh -L 3001:localhost:3001 <server>` and
http://localhost:3001, or run the installer again with `--domain`.

**A new server with cloud-init.** [cloud-init.yaml](cloud-init.yaml) installs Docker and the
gateway on the first boot of an Ubuntu LTS server. Replace `gateway.example.com` in it with your
host name, then paste the file as the server's user data when you create it. It accepts the CE
terms for you, so read them first. Follow the installation with
`tail -f /var/log/cloud-init-output.log`; it lives in `/opt/mcp-gateway`.

**Upgrade.** Run the installer again with the same `--dir`, as the same user (root for
cloud-init). It downloads the compose files of the newest release, keeps `.env` and the database,
and restarts the stack; Compose stops the old container before it starts the new one. The terms
acceptance and the domain are remembered in `.env`. When a release comes with new CE terms, the
installer asks for the new acceptance.

**Your own settings.** Each run replaces `compose.yaml` and `compose.https.yaml`. Put your changes
into `.env`, or into a file of your own that you add to `COMPOSE_FILE` in `.env`, for example
`compose.local.yaml`:

```yaml
services:
  gateway:
    environment:
      MCP_ALLOW_PRIVATE_NETWORK_TARGETS: "false"
```

```sh
COMPOSE_FILE=compose.yaml:compose.https.yaml:compose.local.yaml
```

To stay on one release, set `GATEWAY_IMAGE` in `.env` to a tag or digest; the installer then keeps
it and says so.

**Backup.** In the installation directory:

```sh
docker compose exec -T postgres pg_dump -U gateway -Fc gateway > gateway-$(date +%F).dump
```

Store the dump together with `.env`. Restore and the Claude Code skill that automates it:
[backup-restore](../plugin/skills/backup-restore/SKILL.md).

## DigitalOcean App Platform

[![Deploy to DigitalOcean](https://www.deploytodo.com/do-btn-blue.svg)](https://cloud.digitalocean.com/apps/new?repo=https://github.com/DXHeroes/mcp-gateway/tree/main)

The template runs the CE image as one `apps-s-1vcpu-1gb` instance with the health check on
`/api/health/ready`, and sets `PUBLIC_URL` to the app's address (`${APP_URL}`). It needs a
database you create first.

1. Create a **PostgreSQL database cluster** in the region you will run the app in. App Platform's
   dev database is not supported: on PostgreSQL 15 and later its user reportedly cannot create
   tables in the `public` schema, which the gateway's migrations need.
2. From the cluster's connection details, copy the connection string of the database itself
   (port 25060), not of a connection pool (port 25061). Add `&uselibpqcompat=true` to its end:
   DigitalOcean signs the database certificate with its own CA, and the gateway's database driver
   rejects that under `sslmode=require` unless the flag gives `require` its libpq meaning
   (encrypted, certificate not verified).
3. Click the button. App Platform asks for the values the template leaves empty:
   - `DATABASE_URL`: the string from step 2
   - `AUTH_SECRET`, `GATEWAY_ENCRYPTION_KEY`: each the output of `openssl rand -base64 32`
   - `GATEWAY_CE_TERMS_ACCEPTED`: `2026-09-18.1`
4. If the cluster limits its trusted sources, add the app to them.

**Upgrade.** App Platform starts a new deployment next to the running one, so changing the image
tag alone fails: the new instance stops with `CE_INSTANCE_LIMIT` and the old one keeps serving.
Stop the app first by archiving it, then restore it with the new tag. The gateway is down for the
few minutes in between. With [doctl](https://docs.digitalocean.com/reference/doctl/):

```sh
doctl apps spec get <app-id> > app.yaml
```

Add this to the top level of `app.yaml` and apply it; the app stops:

```yaml
maintenance:
  archive: true
```

```sh
doctl apps update <app-id> --spec app.yaml
```

Then set `archive: false`, change the service's `image.tag` to the new release and apply the spec
again. Restoring the app starts a new deployment with the new tag.

## Render

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/DXHeroes/mcp-gateway)

The Blueprint [render.yaml](../render.yaml) creates the web service and a PostgreSQL database, connects
them through the internal database URL and generates `AUTH_SECRET` and `GATEWAY_ENCRYPTION_KEY`.
It uses paid plans (Starter, Basic-256mb): a free web service sleeps when idle, and a free
database expires after 30 days.

When you create it, Render asks for two values:

- `PUBLIC_URL`: `https://mcp-gateway.onrender.com`. Render gives the service another address
  when that name is taken; then set `PUBLIC_URL` to the address the dashboard shows and deploy
  again.
- `GATEWAY_CE_TERMS_ACCEPTED`: `2026-09-18.1`

The service has a 1 GB disk that stores nothing. Render stops a service with a disk before it
starts the new version, so an upgrade never runs two copies; without it Render would deploy
without downtime and the new copy would stop with `CE_INSTANCE_LIMIT`.

**Upgrade.** In the service settings, change the image tag to the new release and deploy.

## Railway

1. In a new project, add **PostgreSQL**. These steps assume the database service is named
   `Postgres`.
2. Add a service from the Docker image `docker.io/dxheroes/mcp-gateway-ce:v1.5.0-beta.23`.
3. In its **Settings**: generate a public domain for port 3001, set the health check path to
   `/api/health/ready`, and keep one replica.
4. Attach a **volume** to it, mounted at `/var/lib/mcp-gateway`. Nothing is stored there; Railway
   stops a service with a volume before it starts the new deployment, so an upgrade never runs
   two copies.
5. Set its **variables** (the raw editor takes them as they are; generate both secrets with
   `openssl rand -base64 32`), then deploy:

   ```text
   DATABASE_URL=${{Postgres.DATABASE_URL}}
   PUBLIC_URL=https://${{RAILWAY_PUBLIC_DOMAIN}}
   PORT=3001
   AUTH_SECRET=<generated>
   GATEWAY_ENCRYPTION_KEY=<generated>
   GATEWAY_CE_TERMS_ACCEPTED=2026-09-18.1
   MCP_ALLOW_PRIVATE_NETWORK_TARGETS=false
   ```

**Upgrade.** Change the image tag in the service's source settings and deploy.

## Fly.io

You need [flyctl](https://fly.io/docs/flyctl/) and a PostgreSQL database the app can reach over
a direct connection. Save this as `fly.toml`, with your app name and region:

```toml
app = "my-mcp-gateway"
primary_region = "fra"

[build]
  image = "docker.io/dxheroes/mcp-gateway-ce:v1.5.0-beta.23"

[env]
  PUBLIC_URL = "https://my-mcp-gateway.fly.dev"
  MCP_ALLOW_PRIVATE_NETWORK_TARGETS = "false"

[http_service]
  internal_port = 3001
  force_https = true
  auto_stop_machines = "off"
  min_machines_running = 1

  [[http_service.checks]]
    grace_period = "60s"
    interval = "15s"
    timeout = "5s"
    method = "GET"
    path = "/api/health/ready"

[[vm]]
  memory = "1gb"
```

```sh
fly apps create my-mcp-gateway
fly secrets set --app my-mcp-gateway \
  DATABASE_URL='postgresql://…' \
  AUTH_SECRET="$(openssl rand -base64 32)" \
  GATEWAY_ENCRYPTION_KEY="$(openssl rand -base64 32)" \
  GATEWAY_CE_TERMS_ACCEPTED=2026-09-18.1
fly deploy --ha=false
```

`--ha=false` creates one Machine; the first deploy would otherwise create two, and the second
would stop with `CE_INSTANCE_LIMIT`.

**Upgrade.** Change the image tag in `fly.toml` and run `fly deploy`. The default rolling strategy
stops the Machine and starts it again with the new image. Do not deploy with
`--strategy bluegreen` or `canary`: both start a new Machine next to the running one.

## Why not Vercel or serverless

Vercel, Netlify Functions, AWS Lambda and similar serverless platforms run code in short-lived
functions: they start as many copies as there are requests, stop them when idle and limit how
long each runs. CE needs the opposite: one process that runs all the time, holds its database
lock for its whole life and keeps the long-lived HTTP streams of MCP clients open. Use one of the
platforms above, or any container platform where you can fix the instance count at one.

## Image tags

Each template and command here pins the release it was published with (`vX.Y.Z`); there is no
`latest`. Moving tags exist too: `vX.Y` is the newest patch of a minor and `vX` (for example `v1`)
the newest release of a major. A pinned release changes only when you change it, after reading the
upgrade notes. See [Image](../README.md#image) for the registries and signature verification.
