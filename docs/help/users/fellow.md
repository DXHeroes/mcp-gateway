# Fellow

The **Fellow** preset connects the gateway to Fellow's own MCP server, so an AI can read your
meeting summaries, transcripts, action items and participants.

The connection is **read-only**. It can search meetings and open a summary, a transcript, the
participants or the action items, and it can change nothing in Fellow.

There is nothing to register on the Fellow side. Fellow hands the gateway its own credentials
during the first sign-in, so you never paste a client ID or a secret anywhere.

**You need:** the owner or admin role in the gateway, a Fellow account that can see the meetings,
and MCP turned on for the Fellow workspace. A Fellow admin does that under **Workspace Settings**
→ **Security** → **Allow users to create MCP connections**. Until then every sign-in fails.

## 1. Add the preset

1. **Servers** → **Catalog** → **Community presets** → **Fellow** → **Add to my servers**.
2. Pick who the connection acts as. See "One account or everyone's own" below. It is easier to
   choose now than to change later.
3. **Create server**, then add it to a [profile](./profiles.md). Nothing can reach the
   connection until it sits in one.

## 2. Sign in to Fellow

1. Open the server and click **Authorize**.
2. Sign in to Fellow and approve the request.

The connection can reach exactly the meetings the account signing in can already open. It grants
no extra access.

If you chose everyone's own account, each person does this for themselves under
**My connections**. See [Service credentials](./per-user-connections.md).

## One account or everyone's own

Fellow always reads as the person who signed in.

- **Shared** (what the preset starts with): one account for the whole organization. Everyone who
  asks the AI about meetings sees that account's meetings, private ones included.
- **Per-user**: each person signs in with their own Fellow account and sees only their own
  meetings.

Meeting transcripts are usually the most sensitive thing a notetaker holds, so choose per-user
unless you have a reason not to. Changing this later works, but it disconnects the existing
account and everyone reconnects.

## Tool permissions

Every tool here only reads, so they all start on **Allow**. Review them under
[Tool permissions](./tool-customization.md) before people start using the server. If a profile
should see summaries and action items but not full transcripts, turn the transcript tool off
there.

## Troubleshooting

| Problem | What it means |
| --- | --- |
| Sign-in is refused | MCP is off for the Fellow workspace. An admin turns it on under **Workspace Settings** → **Security**. |
| Sign-in works but the AI finds no meetings | The account that signed in is not on those meetings. Invite it in Fellow. |
| Someone sees meetings that are not theirs | The connection is shared. Switch to per-user and have everyone reconnect. |
| The connection stops working | A Fellow admin removed it. Admins can see and delete active MCP connections. |

## More from Fellow

[MCP server](https://developers.fellow.ai/reference/mcp-server)
