---
name: diagnose
description: Diagnose MCP Gateway installation, health, networking, authentication, catalog, and profile problems using read-only and redacted evidence by default.
---

# Diagnose MCP Gateway

Stay read-only unless the administrator later approves a concrete repair. Collect the Gateway base
URL, observed symptom and time range, deployment type, `docker compose ps` or workload status,
container digest and labels, `/api/health`, `/api/health/ready`, `/api/edition`, recent redacted logs,
database reachability, disk/memory pressure, clock skew, reverse-proxy headers, and the failing MCP
endpoint's HTTP status. Do not read or print `.env`, licenses, bearer tokens, cookies, API keys,
OAuth tokens, database URLs, request bodies, tool arguments/results, or configuration exports.

Separate liveness, readiness, authentication, authorization, upstream MCP, catalog discovery, and
tool-policy failures. A reachable container or catalog entry does not prove a healthy connector.
Reproduce with the smallest safe protocol request and include an expected denial control. For an MCP
server problem, verify its separate container and exact catalog endpoint; do not execute source or
install dependencies inside the Gateway container.

Return evidence, likely cause with confidence, and a concrete repair plan with exact files/commands,
impact, validation, and rollback. Wait for explicit approval before restarting, editing configuration,
rotating credentials, changing firewall/proxy rules, modifying data, installing tools, or upgrading.
