# DXH Gateway

Self-hosted governance for MCP tools. This repository contains installation materials and public documentation. Service source is private.

Community Edition (CE) is free for eligible production use in companies with at most 50 employees including affiliates, and for nonproduction evaluation at any company size. CE includes 25 active accounts, one organization, one REST/OpenAPI connection and one active gateway instance. MCP connections, profiles and tool calls have no commercial quota.

Enterprise Edition (EE) adds enterprise identity, automation, log export, longer retention and multiple gateway replicas. Paid and individually issued trial licenses are verified offline. User limits follow the license, including unlimited users. Paid EE includes support and onboarding; SLA is agreed separately.

Start with [installation](docs/help/deployment/installation.md), [edition details](docs/help/users/editions.md) and [image verification](docs/help/deployment/image-verification.md). Read [CE terms](LICENSE-CE.txt) before accepting them.

Release images and signature/SBOM links are published only after release validation. Use an immutable image digest. Do not use a source-repository archive as an installation package.

Support and EE/trial requests: hello@dxheroes.io. Report public issues without credentials or private tool results.

## Install CE locally

Every release publishes an immutable `release.json`. Copy `.env.example` to `.env`, put the
published CE `image@sha256:…` value in `GATEWAY_IMAGE`, generate independent secrets, read the CE
terms, and then start the reviewed plan:

```sh
cp .env.example .env
docker compose config
docker compose pull
docker compose up -d --wait
```

The browser UI and management API are then available at `http://localhost:3001`. The default
configuration binds the Gateway only to loopback. Use a TLS reverse proxy and set `PUBLIC_URL`
before exposing it on a network. See [installation](docs/help/deployment/installation.md) for the
full procedure and backup requirements.

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

The public repository is Apache-2.0 for documentation, Compose, Helm, and plugin materials. The CE
and EE container images use the separate terms shipped here. No service source is published.
