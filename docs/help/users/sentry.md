# Sentry

The **Sentry** preset connects the gateway to Sentry's own MCP server, so an AI can search errors,
read stack traces and releases, triage issues and manage projects.

There is nothing to register on the Sentry side. Sentry hands the gateway its own credentials
during the first sign-in, so you never paste a client ID or a secret anywhere.

**You need:** the owner or admin role in the gateway, and a sentry.io account with access to the
organization. The hosted server does not serve a self-hosted Sentry.

## 1. Add the preset

1. **Servers** → **Catalog** → **Community presets** → **Sentry** → **Add to my servers**.
2. Pick who the connection acts as. See "One account or everyone's own" below. It is easier to
   choose now than to change later.
3. **Create server**, then add it to a [profile](./profiles.md). Nothing can reach the
   connection until it sits in one.

## 2. Sign in to Sentry

1. Open the server and click **Authorize**.
2. Sign in to Sentry and approve.

The connection can reach exactly what the account signing in can already open.

If you chose everyone's own account, each person does this for themselves under
**My connections**. See [Service credentials](./per-user-connections.md).

## Narrowing it to one project

How much the AI can reach depends on the address:

| Address | Reaches |
| --- | --- |
| `https://mcp.sentry.dev/mcp` | Every organization the account belongs to |
| `https://mcp.sentry.dev/mcp/{org-slug}` | One organization |
| `https://mcp.sentry.dev/mcp/{org-slug}/{project-slug}` | One project |

The preset installs the first one. If the gateway serves a single product team, edit the address
and pin it to their project. A narrower address means fewer tools and no way to land in another
team's errors by accident.

## One account or everyone's own

Sentry always acts as the person who signed in.

- **Shared** (what the preset starts with): one account for the whole organization. Everyone sees
  that account's projects, and every issue assignment carries its name.
- **Per-user**: each person signs in with their own Sentry account and sees their own projects.

Error data is usually open to the whole engineering team anyway, so a shared account works well
here. Choose per-user if projects are restricted by team. Changing this later works, but it
disconnects the existing account.

## Tool permissions

This server writes as well as reads. It can assign and resolve issues, create projects and teams,
and change DSN keys. New servers start with the reading tools on **Allow** and the writing ones on
**Needs approval**. Review them under [Tool permissions](./tool-customization.md) before people
start using the server.

## Troubleshooting

| Problem | What it means |
| --- | --- |
| Sign-in works but the AI finds no issues | The account is not a member of the organization, or the address pins a different one. |
| Fewer tools than expected | The address pins one organization or project, which removes the tools for switching between them. |
| A self-hosted Sentry cannot be reached | This server serves sentry.io only. |
| Issue changes show the wrong name | The connection is shared. Switch to per-user and have everyone reconnect. |

## More from Sentry

[Sentry MCP](https://mcp.sentry.dev/)
