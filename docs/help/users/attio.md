# Attio

The **Attio** preset connects the gateway to Attio's own MCP server, so an AI can search and edit
CRM records, lists, notes, tasks and comments, and read meeting transcripts and call recordings.

There is nothing to register on the Attio side. Attio hands the gateway its own credentials during
the first sign-in, so you never paste a client ID or a secret anywhere.

**You need:** the owner or admin role in the gateway, and an Attio account in the workspace. The
reporting and SQL tools depend on your Attio plan.

## 1. Add the preset

1. **Servers** → **Catalog** → **Community presets** → **Attio** → **Add to my servers**.
2. Pick who the connection acts as. See "One account or everyone's own" below. It is easier to
   choose now than to change later.
3. **Create server**, then add it to a [profile](./profiles.md). Nothing can reach the
   connection until it sits in one.

## 2. Sign in to Attio

1. Open the server and click **Authorize**.
2. Sign in to Attio, choose the workspace and approve.

Attio applies that member's own permissions, so the connection can reach exactly what they can
already open.

If you chose everyone's own account, each person does this for themselves under
**My connections**. See [Service credentials](./per-user-connections.md).

## One account or everyone's own

Attio always acts as the member who signed in.

- **Shared** (what the preset starts with): one member for the whole organization. Everyone reads
  and writes as that member, and every record change carries its name in Attio's history.
- **Per-user**: each person signs in with their own account and sees what they see in Attio.

A CRM is a shared record of who talked to whom, and a shared account makes that record wrong.
Choose per-user unless the connection is meant to be read-only. Changing this later works, but it
disconnects the existing account.

## Tool permissions

Around forty tools, and many of them write: creating, updating and merging records, adding notes
and comments, changing tasks and lists. New servers start with the reading tools on **Allow** and
the writing ones on **Needs approval**. Review them under
[Tool permissions](./tool-customization.md) before people start using the server. Watch the merge
tool in particular. A merge cannot be undone.

Meeting transcripts and call recordings are reachable here too. If a profile should not hand those
to an AI, turn those tools off there.

## Troubleshooting

| Problem | What it means |
| --- | --- |
| Sign-in works but the AI finds no records | The account cannot see those objects in Attio, or a different workspace was chosen. |
| Reporting or SQL tools are missing | Those depend on the Attio plan. |
| Calls start failing during heavy use | Attio limits how many requests per second it accepts. Ask for less at once. |
| Record changes show the wrong name | The connection is shared. Switch to per-user and have everyone reconnect. |

## More from Attio

[Attio MCP](https://docs.attio.com/mcp/overview)
