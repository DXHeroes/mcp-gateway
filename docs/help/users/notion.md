# Notion

The **Notion** preset connects the gateway to Notion's own MCP server, so an AI can search, read,
create and update pages and databases in your workspace.

There is nothing to register on the Notion side. Notion hands the gateway its own credentials
during the first sign-in, so you never paste a client ID or a secret anywhere.

**You need:** the owner or admin role in the gateway, and a Notion account that can see the
content you want the AI to reach. If your workspace is part of a Notion organization, an owner may
have to allow the connection under **Settings** → **Connections**.

## 1. Add the preset

1. **Servers** → **Catalog** → **Community presets** → **Notion** → **Add to my servers**.
2. Pick who the connection acts as. See "One account or everyone's own" below. It is easier to
   choose now than to change later.
3. **Create server**, then add it to a [profile](./profiles.md). Nothing can reach the
   connection until it sits in one.

## 2. Sign in to Notion

1. Open the server and click **Authorize**.
2. Sign in to Notion and choose the workspace.
3. Approve the request.

The connection can reach exactly the pages the account signing in can already open. It grants no
extra access.

If you chose everyone's own account, each person does this for themselves under
**My connections**. See [Service credentials](./per-user-connections.md).

## One account or everyone's own

Notion always acts as the person who signed in, so this choice decides whose name appears on every
page the AI edits.

- **Shared** (what the preset starts with): one account for the whole organization. Everyone reads
  and writes as that account. This is how Notion's own service accounts work: one account, set up
  once by someone allowed to authorize it.
- **Per-user**: each person signs in with their own Notion account and sees exactly what they see
  in Notion. Choose this if the workspace holds content that not everyone should read.

Changing this later works, but it disconnects the existing account and everyone reconnects.

## A Notion token will not work

This preset only accepts a Notion sign-in. The secret from Notion's **My integrations** page (it
starts with `ntn_`) is not accepted anywhere in the form. Use **Authorize**.

## Tool permissions

The preset brings both reading tools (search, open a page, query a database, read comments) and
writing tools (create and update pages, databases, views and comments). Reading tools start on
**Allow** and writing tools on **Needs approval**. Review them under
[Tool permissions](./tool-customization.md) before people start using the server, and keep
approval on anything that writes to a shared workspace.

## Troubleshooting

| Problem | What it means |
| --- | --- |
| Sign-in works but the AI finds nothing | The account that signed in cannot see those pages. Share them with it in Notion. |
| A tool call fails with a permission error | Same cause: the page permissions in Notion, not the gateway. |
| Edits show the wrong person's name | The connection is shared. Switch to per-user and have everyone reconnect. |
| The connection stops working | An owner removed it in Notion under **Settings** → **Connections**. Authorize again. |

## More from Notion

[Notion MCP](https://developers.notion.com/docs/mcp) ·
[Get started](https://developers.notion.com/guides/mcp/get-started-with-mcp) ·
[Supported tools](https://developers.notion.com/guides/mcp/mcp-supported-tools)
