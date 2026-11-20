# DXH Gateway for shared MCP tools

Give AI clients the MCP tools they need and see which tools they call.

Community Edition is for developers and platform teams who manage access to shared MCP servers.

## The problem

- A new AI client means setting up the same servers again.
- You want an assistant to look up tickets, with someone approving any edits it makes.
- After an unexpected change, you need to find out who called the tool and from which AI client.

## See it

https://github.com/user-attachments/assets/839e3eea-6bd9-488e-881f-fa0ab68a378e

[Download the walkthrough (MP4)](docs/media/walkthrough.mp4)

![MCP Servers page listing ByzData and Context7 with their connection status and tool counts](docs/media/mcp-servers.png)

See which MCP servers are connected and how many tools they offer.

![Profiles page showing two ready profiles and the gateway endpoint](docs/media/profiles.png)

Give AI clients the tools they need by connecting them to a profile.

![Activity page showing successful tool-list requests from three simulated AI clients](docs/media/activity.png)

See which client requested tools and which profile handled the request.

## What you get

- Set up each MCP server once on your own gateway and reuse the connection across clients.
- Use profiles to give each client a set of tools suited to its work.
- Block individual tools or require approval before a call runs.
- Inspect recent calls in Activity to see which client called which tool and on which server.

## Why we built it

If something goes wrong, I want to be able to look up which MCP server we called and see
what came back. We built DXH Gateway to give our team that record.

Using Gateway, we measured 6 billion tokens and 135,000 lines of code over 30 days of our own work.

Prokop Simek

## Run it in 5 minutes

You need Docker with Compose v2, `curl` and `openssl` on a Mac or a Linux machine. For step 5,
use either [Claude Code](https://code.claude.com/docs/en/overview) signed in to your Claude
account or [MCP Inspector](https://modelcontextprotocol.io/docs/tools/inspector) with Node.js and
`npx`. MCP Inspector works without a Claude account. Allow extra time for the first download of
the gateway and PostgreSQL images.

1. Install the gateway:

   ```sh
   curl -fsSL https://raw.githubusercontent.com/DXHeroes/mcp-gateway/main/install.sh | sh
   ```

   Answer `y` to accept the [CE terms](LICENSE-CE.txt). The installer writes `mcp-gateway/.env`
   with generated secrets, starts the gateway and prints
   `DXH Gateway is running at http://localhost:3001.` followed by the next steps.

2. Open http://localhost:3001, click **Sign up** and create an account. The first account owns
   the gateway. You land on the Dashboard, where the **Gateway endpoint** card shows
   `http://localhost:3001/api/mcp/workspace/gateway`.

3. Add a first MCP server: on **MCP Servers → Catalog**, click **Add to my servers** on
   **ByzData**. It reads public Czech company registers and needs no API key. Its page shows
   **Connected** and **Server ready (no API key required)**, and the **Tools** tab lists 9 tools.

4. Put the server into the profile the endpoint serves: on **Profiles**, click **Edit** on
   `default`, select **ByzData** and click **Save changes**. The Dashboard now shows the `default`
   profile as **Ready at last check** with servers `1/1`.

5. Verify the profile's tools with either client.

   To use **Claude Code**, run these commands after signing in.

   ```sh
   claude mcp add --transport http mcp-gateway http://localhost:3001/api/mcp/workspace/gateway
   claude mcp login mcp-gateway
   claude mcp list
   ```

   `claude mcp login` opens the gateway's authorization page in your browser. In the browser where
   you created the account, it goes straight to **Authentication successful**. The last command
   then prints:

   ```text
   mcp-gateway: http://localhost:3001/api/mcp/workspace/gateway (HTTP) - ✔ Connected
   ```

   In a signed-in Claude Code session, open `/mcp`, select `mcp-gateway` and choose
   **View tools** to see the nine ByzData tools, including `search_company` and `get_company`.

   To use **MCP Inspector**, run this command with a supported Node.js version such as 24.22.1.

   ```sh
   npx -y @modelcontextprotocol/inspector@2.16.0 --cli \
     http://localhost:3001/api/mcp/workspace/gateway --transport http --method tools/list
   ```

   Complete the gateway authorization in the browser where you created the account. The command
   prints a JSON `tools` array with the nine ByzData tool names.

### What next

- [Before you go to production](#before-you-go-to-production) says how to close the sign-up and
  serve the gateway over HTTPS. The installer's `--domain` option does the HTTPS part, see
  [Install with one command](#install-with-one-command).
- [Connect an AI client](#connect-an-ai-client) has the configuration for other clients that
  support remote MCP servers over HTTP.
- [Get started](docs/help/users/introduction/quick-start.md) covers profiles, tool permissions and
  approvals.
- [Docker Compose](#quick-start-with-docker-compose) and [`docker run`](#quick-start-with-docker-run)
  install the gateway without the installer.
- [Update, stop, remove](#update-stop-remove) covers upgrades and removal.

## Community vs. Enterprise

| | Community Edition (CE) | Enterprise Edition (EE) |
| --- | --- | --- |
| Use | Free for internal production in companies with up to 50 employees. Free for non-production evaluation and testing at any company size. | Paid or trial license |
| Active accounts | Up to 25 across the installation, counting all roles | Capacity set by the signed license |
| Workspaces | One | Multiple |
| Saved REST/OpenAPI connections | One, even if disabled | No edition limit |
| Deployment | One running gateway instance | Multiple gateway replicas |
| Activity and audit history | Up to seven days | Longer retention |
| Authentication | Password, Google and Microsoft sign-in, plus MFA | Adds AD FS sign-in, directory group-to-role mapping and external JWTs |
| API access | OAuth for MCP clients | Adds profile and management API keys |
| Configuration | Configuration export | Adds configuration as code with plan and apply |
| Monitoring | Health and basic metrics | Adds log export, alerts and automatic checks for tool and specification drift |

The CE terms call a workspace an organization. Count employees at your company and at any company
that controls it, is controlled by it or is under common control. CE sets no commercial quota on
MCP connections, profiles or tool calls. See the [CE terms](LICENSE-CE.txt).

DXH Gateway verifies paid and trial EE licenses offline. See [editions and licenses](docs/help/users/editions.md).
For Enterprise Edition or a trial, [contact DX Heroes](https://dxheroes.io/contact).

For support or to report a bug, email [hello@dxheroes.io](mailto:hello@dxheroes.io).

## What we are working on

We plan to add these capabilities.

- Give each user group access to the MCP connections and tools it needs (EE only).
- Let users narrow their own tool list at the shared workspace URL by switching off profiles.
- Update Gateway group membership from your directory at sign-in (EE only).
- Manage workspace groups and their tool access in a configuration file you can review and apply (EE only).

Last updated on 19 November 2026.

See [Releases](https://github.com/DXHeroes/mcp-gateway/releases).

---

Self-hosted governance for MCP tools: connect your MCP servers once, group them into profiles, and
give every AI client exactly the tools it needs, with permissions, approvals and an audit trail.

This repository holds installation materials and public documentation for the Community Edition
(CE) container image. Service source is private.

## Install with one command

On a Linux server or a Mac with Docker:

```sh
curl -fsSL https://raw.githubusercontent.com/DXHeroes/mcp-gateway/main/install.sh | sh
```

The installer asks you to accept the [CE terms](LICENSE-CE.txt), writes `mcp-gateway/.env` with
generated secrets and starts the newest release with Docker Compose. Add a domain to serve it over
HTTPS with a Let's Encrypt certificate (its DNS must point at the server, ports 80 and 443 open):

```sh
curl -fsSL https://raw.githubusercontent.com/DXHeroes/mcp-gateway/main/install.sh | sh -s -- --domain gateway.example.com
```

Running it again upgrades the installation and keeps `.env` and the data. To read the script
first, download it with `curl -fsSLO …/install.sh` and run `sh install.sh`; `sh install.sh --help`
lists the options.

On a hosted platform, read its guide first, because each one asks for values only you can give:

[![Deploy to DigitalOcean](https://www.deploytodo.com/do-btn-blue.svg)](https://cloud.digitalocean.com/apps/new?repo=https://github.com/DXHeroes/mcp-gateway/tree/main)
[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/DXHeroes/mcp-gateway)

[Deploy guides](deploy/README.md): a VPS or Droplet (including a cloud-init file for a new
server), DigitalOcean App Platform, Render, Railway and Fly.io, and why Vercel and other
serverless platforms cannot run the gateway.

## Quick start with Docker Compose

You need Docker with Compose v2 and a shell with `openssl` (macOS, Linux or WSL). Copy the whole
block. The last line inside `.env` accepts the [CE terms](LICENSE-CE.txt), so read them first: CE
is free for production use in companies with up to 50 employees, and for evaluation at any company.

```sh
mkdir mcp-gateway && cd mcp-gateway
curl -fsSLO https://raw.githubusercontent.com/DXHeroes/mcp-gateway/main/compose.yaml
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
  dxheroes/mcp-gateway-ce:v1.7.0
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

To use GHCR, add `GATEWAY_IMAGE=ghcr.io/dxheroes/mcp-gateway-ce:v1.7.0` to `.env` (Compose) or
use that name in the `docker run` command.

The repositories also carry `vX.Y.Z-beta.N` builds and a moving `beta` tag from the development
branch, for trying a fix before it is released. They are not supported releases: pin a release tag.
The [`beta` branch](https://github.com/DXHeroes/mcp-gateway/tree/beta) of this repository holds
these instructions for the newest beta.

Signatures belong to the repository they were published in, so verify the reference that
`release.json` names, not a copy of it: see [image verification](docs/help/deployment/image-verification.md).

## Connect an AI client

The Dashboard shows the gateway endpoint, which serves your default profile. On a new installation
it is `http://localhost:3001/api/mcp/workspace/gateway`:

```sh
claude mcp add --transport http mcp-gateway http://localhost:3001/api/mcp/workspace/gateway
```

Other clients that support remote MCP servers over HTTP use the same URL:

```json
{
  "mcpServers": {
    "mcp-gateway": { "type": "http", "url": "http://localhost:3001/api/mcp/workspace/gateway" }
  }
}
```

The client signs you in through the browser (OAuth). See [Get started](docs/help/users/introduction/quick-start.md)
for profiles, tool permissions and approvals.

## Update, stop, remove

- **Update (Compose):** download `compose.yaml` again and run `docker compose up -d --wait`, or
  run the installer again if it made the installation. The new image migrates the database on
  start. Back up the database before you update.
- **Update (`docker run`):** `docker rm -f mcp-gateway`, then run the gateway command again with the
  new tag.
- **Stop:** `docker compose down`, or `docker stop mcp-gateway mcp-gateway-db`. Data stays in the
  volume.
- **Remove everything, including data:** `docker compose down -v`, or remove both containers, the
  `mcp-gateway-db` volume and the `mcp-gateway` network.

## Before you go to production

- Put the gateway behind a TLS reverse proxy and set `PUBLIC_URL` to its address (the installer's
  `--domain` does both with Caddy). The defaults publish port 3001 on loopback only.
- After the owner account exists, close public sign-up.

  - For **Docker Compose**, set `AUTH_SIGNUP_MODE=invite_only` in the installation's `.env` and
    run `docker compose up -d --wait` from that directory.
  - For **`docker run`**, set `AUTH_SIGNUP_MODE=invite_only` in `gateway.env`, run
    `docker rm -f mcp-gateway` and repeat the gateway container command from
    [Quick start with `docker run`](#quick-start-with-docker-run). Keep the PostgreSQL container
    and its data volume.
- Pin the image by digest from `release.json` and verify its signature: see
  [image verification](docs/help/deployment/image-verification.md).
- Back up the database and `.env` together.

The full procedure, Helm (Kubernetes/OpenShift) and upgrades are in
[installation](docs/help/deployment/installation.md).

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
