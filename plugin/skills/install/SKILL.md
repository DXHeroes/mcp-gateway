---
name: install
description: Prepare and install DXH Gateway CE or EE locally with immutable images, read-only preflight, and explicit approval before writing or starting services.
---

# Install MCP Gateway

Use only the public distribution repository and its immutable release metadata. The service source
is private and is never required for installation. CE uses
`ghcr.io/dxheroes/mcp-gateway-ce`; EE uses the private Docker Hub repository and requires an
individually issued offline license.

First inspect, without changing the host: operating system and architecture, Docker Engine and
Compose versions, free disk and memory, port 3001, existing containers/volumes, selected release,
`release.json`, Cosign signature and attestations, and whether the exact digest contains the native
platform. Redact registry usernames, tokens, license contents, environment secrets, database URLs,
and configuration exports. Do not pull or execute an unreviewed image. Install by digest by default; a compatibility line
(`vX`, `vX.Y`) is accepted only when the administrator asks for automatic updates inside that
line, and then only after saying that the tag moves and what it resolves to today.

Present one concrete plan containing the target directory, edition, version, image digest, public
URL, port binding, database volume, generated file paths, secret-generation commands, terms version,
start command, health checks, and rollback/removal commands. For CE, require the administrator to
explicitly accept the cited CE terms version; accepting it confirms eligible use, and there is no
separate production/evaluation choice. For EE, require the administrator to confirm the private
image access and how `GATEWAY_LICENSE` receives the license (a mounted file path or the license
content). Wait for explicit approval of that exact plan before creating the directory, `.env`,
secrets, volumes, or containers.

After approval, generate each secret independently with at least 32 random bytes and write it only
to a mode-0600 `.env` or secret-manager target. Set `GATEWAY_IMAGE` to `image@sha256:…`, run
`docker compose config`, pull, and start with `docker compose up -d --wait`. Confirm readiness,
`GET /api/edition` version/edition, browser access, non-root runtime, and loopback-only binding.
Never print secret values. Report the exact installed digest and backup location.
