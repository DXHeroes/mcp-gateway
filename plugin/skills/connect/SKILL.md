---
name: connect
description: Connect Claude Code to a reviewed MCP Gateway profile after checking the endpoint and showing the exact local configuration change.
---

# Connect Claude to MCP Gateway

Ask for the Gateway base URL, profile slug, and preferred Claude scope. Do not request a profile API
key in chat or place it in a repository, URL, shell history, or plan output. Confirm the endpoint uses
TLS unless it is loopback, fetch public OAuth metadata where applicable, and ask the administrator to
verify the profile and allowed tool surface in the Gateway UI.

Run read-only checks first. Show the exact MCP endpoint, scope, transport, credential source, and
rollback command. Wait for explicit approval before changing Claude configuration. Prefer Gateway
OAuth where configured. When a profile API key is required, have the administrator enter it through
the local secret/keychain mechanism and redact it from all commands and output.

After approval, use Claude's HTTP transport for the profile endpoint, then exercise `initialize` or
discovery, `tools/list`, one explicitly safe read-only tool, and an expected denial. Do not call a
write or destructive tool as a connectivity test. Record only the Gateway URL, profile slug, scope,
and successful protocol version; never record credentials or tool results.
