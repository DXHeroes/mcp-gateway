# GitHub

The **GitHub MCP** preset connects the gateway to GitHub's own MCP server, so an AI can work with
your repositories, issues, pull requests, Actions runs and projects.

This preset is the odd one out: it signs in with a **personal access token** you create on GitHub,
not by clicking through a login screen.

**You need:** the owner or admin role in the gateway, and a GitHub account that can see the
repositories. GitHub Enterprise Server is not supported. Enterprise Cloud works, but on a
different address (`https://copilot-api.SUBDOMAIN.ghe.com/mcp`), which you set on the connection
after you add the preset.

## 1. Create a token

1. In GitHub go to **Settings** → **Developer settings** → **Personal access tokens**.
2. Create a token. A fine-grained token can be limited to named repositories, which is safer.
3. Give it only what it needs. For a classic token that is usually `repo` (repositories, issues
   and pull requests), `read:org` (teams and projects), `security_events` (code scanning and
   Dependabot alerts) and `notifications`.
4. Set an expiry date and write it down. The connection stops working that day.

## 2. Add the preset

1. **Servers** → **Catalog** → **Community presets** → **GitHub MCP** → **Add to my servers**.
2. Pick who the connection acts as. See "One account or everyone's own" below. It is easier to
   choose now than to change later.
3. Paste the token.
4. **Create server**, then add it to a [profile](./profiles.md). Nothing can reach the
   connection until it sits in one.

If you chose everyone's own account, nobody pastes a token here. Each person adds their own under
**My connections**. See [Service credentials](./per-user-connections.md).

## One account or everyone's own

A personal access token belongs to one person, so GitHub sees whoever created it.

- **Shared** (what the preset starts with): one token for the whole organization. Every comment
  and every commit carries that account's name. Use a machine account, not your own.
- **Per-user**: each person adds their own token and reaches their own repositories.

Per-user fits a code host better. GitHub already decides who may see which repository and keeps
its own history of who did what, and both stay true only if the token is the real person's.
Changing this later works, but it disconnects the stored token.

## What the AI can reach

The preset asks GitHub for the standard tools plus Actions and Projects. Other groups exist
(security, discussions, gists, notifications). To change the selection, edit the
`X-MCP-Toolsets` header on the connection.

The preset also sends `X-MCP-Lockdown: false`. Set it to `true` to hide issues in public
repositories from people without write access.

## Tool permissions

This server writes as well as reads. It can open and close issues, comment, create branches and
pull requests, and re-run workflows. New servers start with the reading tools on **Allow** and the
writing ones on **Needs approval**. Review them under [Tool permissions](./tool-customization.md)
before people start using the server.

## Troubleshooting

| Problem | What it means |
| --- | --- |
| Everything fails with "unauthorized" | The token expired or was revoked. Create a new one and update the connection. |
| A repository is missing | A fine-grained token that does not list it, or an account without access. |
| No organization repositories at all | The organization approves fine-grained tokens itself. An owner approves yours under **Settings** → **Personal access tokens**. |
| Actions or Projects tools are gone | The `X-MCP-Toolsets` header was edited. Put `default,actions,projects` back. |
| Commits show the wrong name | The connection is shared. Switch to per-user and have everyone add their own token. |

## More from GitHub

[GitHub MCP Server](https://github.com/github/github-mcp-server) ·
[Remote server reference](https://github.com/github/github-mcp-server/blob/main/docs/remote-server.md)
