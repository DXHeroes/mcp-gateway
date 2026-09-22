# DXH Gateway

> **Beta branch.** These materials install `v1.2.0-beta.5`, a pre-release build of the
> next version from the development branch, for trying a change before it is released. It is
> not a supported release. For production, use the
> [`main` branch](https://github.com/DXHeroes/mcp-gateway) and its release tags.

Self-hosted governance for MCP tools: connect your MCP servers once, group them into profiles, and
give every AI client exactly the tools it needs, with permissions, approvals and an audit trail.

This repository holds installation materials and public documentation for the Community Edition
(CE) container image. Service source is private.

## Quick start with Docker Compose

You need Docker with Compose v2 and a shell with `openssl` (macOS, Linux or WSL). Copy the whole
block. The last line inside `.env` accepts the [CE terms](LICENSE-CE.txt), so read them first: CE
is free for production use in companies with up to 50 employees, and for evaluation at any company.

```sh
mkdir mcp-gateway && cd mcp-gateway
curl -fsSLO https://raw.githubusercontent.com/DXHeroes/mcp-gateway/beta/compose.yaml
cat > .env <<EOF
POSTGRES_PASSWORD=$(openssl rand -hex 32)
AUTH_SECRET=$(openssl rand -base64 32)
GATEWAY_ENCRYPTION_KEY=$(openssl rand -base64 32)
GATEWAY_CE_TERMS_ACCEPTED=2026-09-18.1
EOF
chmod 600 .env
docker compose up -d --wait
```

Open http://localhost:3001 and create an account. The first account owns the gateway and gets a
`default` profile. On the Dashboard, **Add server** connects your first MCP server; **MCP Servers →
Catalog** lists the ready-made ones.

Keep `.env`. It holds the key that encrypts the credentials stored in the database, and without it
they cannot be read again.

## Quick start with `docker run`

The same setup without Compose: one network, a PostgreSQL container and the gateway.

```sh
mkdir mcp-gateway && cd mcp-gateway
DB_PASSWORD=$(openssl rand -hex 32)
cat > gateway.env <<EOF
DATABASE_URL=postgresql://gateway:${DB_PASSWORD}@mcp-gateway-db:5432/gateway
AUTH_SECRET=$(openssl rand -base64 32)
GATEWAY_ENCRYPTION_KEY=$(openssl rand -base64 32)
GATEWAY_CE_TERMS_ACCEPTED=2026-09-18.1
EOF
chmod 600 gateway.env

docker network create mcp-gateway
docker run -d --name mcp-gateway-db --network mcp-gateway --restart unless-stopped \
  -e POSTGRES_USER=gateway -e POSTGRES_DB=gateway -e POSTGRES_PASSWORD="$DB_PASSWORD" \
  -v mcp-gateway-db:/var/lib/postgresql/data \
  postgres:17-alpine
docker run -d --name mcp-gateway --network mcp-gateway --restart unless-stopped \
  --env-file gateway.env -p 127.0.0.1:3001:3001 \
  dxheroes/mcp-gateway-ce:v1.2.0-beta.5
```

The gateway waits for the database and applies migrations itself, so a `connection refused` line
in `docker logs -f mcp-gateway` while PostgreSQL starts is expected. Then open
http://localhost:3001 as above.

## Image

The CE image is public on Docker Hub as `dxheroes/mcp-gateway-ce` and on GitHub Container
Registry as `ghcr.io/dxheroes/mcp-gateway-ce`, with the same tags and digests. Tags are release
versions (`vX.Y.Z`); there is no `latest`, so `docker pull` without a tag fails.

Next to each release there are two moving tags: `vX.Y` is the newest patch of that minor and `vX`
the newest release of that major, so `v1` takes every 1.x release as it comes and never crosses a
breaking change — those bump the major. Before 1.0.0 a minor may break compatibility, so no `v0`
exists. Pin a release or a digest for a deployment that never changes under you; pin a line when
you want the updates automatically.

To use GHCR, add `GATEWAY_IMAGE=ghcr.io/dxheroes/mcp-gateway-ce:v1.2.0-beta.5` to `.env` (Compose) or
use that name in the `docker run` command.

The repositories also carry `vX.Y.Z-beta.N` builds and a moving `beta` tag from the development
branch, for trying a fix before it is released. They are not supported releases: pin a release tag.
The [`beta` branch](https://github.com/DXHeroes/mcp-gateway/tree/beta) of this repository holds
these instructions for the newest beta.

Signatures belong to the repository they were published in, so verify the reference that
`release.json` names, not a copy of it: see [image verification](docs/help/deployment/image-verification.md).

## Connect an AI client

The Dashboard shows the gateway endpoint, which serves your default profile. On a new installation
it is `http://localhost:3001/api/mcp/organization/gateway`:

```sh
claude mcp add --transport http mcp-gateway http://localhost:3001/api/mcp/organization/gateway
```

Other clients that support remote MCP servers over HTTP use the same URL:

```json
{
  "mcpServers": {
    "mcp-gateway": { "type": "http", "url": "http://localhost:3001/api/mcp/organization/gateway" }
  }
}
```

The client signs you in through the browser (OAuth). See [Get started](docs/help/users/introduction/quick-start.md)
for profiles, tool permissions and approvals.

## Update, stop, remove

- **Update (Compose):** download `compose.yaml` again and run `docker compose up -d --wait`. The
  new image migrates the database on start. Back up the database before you update.
- **Update (`docker run`):** `docker rm -f mcp-gateway`, then run the gateway command again with the
  new tag.
- **Stop:** `docker compose down`, or `docker stop mcp-gateway mcp-gateway-db`. Data stays in the
  volume.
- **Remove everything, including data:** `docker compose down -v`, or remove both containers, the
  `mcp-gateway-db` volume and the `mcp-gateway` network.

## Before you go to production

- Put the gateway behind a TLS reverse proxy and set `PUBLIC_URL` to its address. The defaults
  publish port 3001 on loopback only.
- After the owner account exists, set `AUTH_SIGNUP_MODE=invite_only` and restart.
- Pin the image by digest from `release.json` and verify its signature: see
  [image verification](docs/help/deployment/image-verification.md).
- Back up the database and `.env` together.

The full procedure, Helm (Kubernetes/OpenShift) and upgrades are in
[installation](docs/help/deployment/installation.md).

## Editions

CE includes 25 active accounts, one organization, one REST/OpenAPI connection and one active gateway
instance. MCP connections, profiles and tool calls have no commercial quota. Enterprise Edition (EE)
adds enterprise identity, automation, log export, longer retention and multiple gateway replicas,
with offline-verified paid or trial licenses. See [editions](docs/help/users/editions.md).

Support and EE/trial requests: hello@dxheroes.io. Report public issues without credentials or
private tool results.

## Claude marketplace

Install assisted administration skills directly from this public repository:

```sh
claude plugin marketplace add DXHeroes/mcp-gateway
claude plugin install mcp-gateway@mcp-gateway
```

The plugin provides `install`, `connect`, `upgrade`, `backup-restore`, and `diagnose`. Each skill
runs read-only preflight checks, displays the exact plan, and waits for explicit administrator
approval before writing files, starting or replacing containers, registering an MCP endpoint, or
restoring data.

## License

The public repository is Apache-2.0 for documentation, Compose, Helm, and plugin materials. The CE
and EE container images use the separate terms shipped here ([CE](LICENSE-CE.txt),
[EE](LICENSE-EE.txt)). No service source is published.
