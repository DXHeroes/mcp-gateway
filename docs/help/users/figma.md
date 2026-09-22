# Figma

Connects the gateway to Figma's own MCP server, so an AI can search, read and edit your Figma
Design and FigJam files.

> **Figma only lets approved apps connect.** Until the gateway is approved in the
> [Figma MCP Catalog](https://www.figma.com/mcp-catalog/), **Authorize** fails with
> `Client registration failed: 403 Forbidden`. That is Figma's rule, not a broken setup. Adding
> the preset does not change it. Join the waitlist; it is the only way in that we recommend.

**You need:**

- The owner or admin role in the gateway.
- A Figma account that can open the files.
- The gateway approved by Figma. Everything below works without it; only the last step fails.

## 1. Add the preset

1. **Servers** → **Catalog** → **Community presets** → **Figma** → **Add to my servers**.
2. Choose **Shared** or **Per-user**. See below. Choosing now is one click; changing later
   disconnects the account.
3. **Create server**, then add it to a [profile](./profiles.md). Nothing can reach the
   connection until it sits in one.

Nothing to register on the Figma side, and no client ID or secret to paste. Figma issues the
gateway its own credentials.

## 2. Sign in

1. Open the server and click **Authorize**.
2. Sign in to Figma and approve.

On **Per-user**, everyone does this for themselves under **My connections**. See
[Service credentials](./per-user-connections.md).

## Shared or per-user

Figma acts as whoever signed in, so this decides whose name lands in a file's edit history.

| | **Shared** | **Per-user** |
| --- | --- | --- |
| Acts as | One account, for everyone | Each person, as themselves |
| Can see | What that account can open | What that person can open |
| Edit history shows | That one account | The person who made the edit |

Pick **Per-user** unless you want one shared account on purpose. The preset opens on **Shared**
for a technical reason, not as a recommendation: the gateway cannot yet start this kind of
connection on Per-user without breaking its sign-in form.

## Tool permissions

Figma's server writes as well as reads. It can create and change frames, components and
variables. Reading tools start on **Allow**, writing tools on **Needs approval**. Check them
under [Tool permissions](./tool-customization.md) before people start using the server.

## The "DCR client name" field

This field replaces the name the gateway gives when it introduces itself to a provider. Leave it
empty. The preset suggests no value and neither does this page.

Putting an approved app's name in it to get past Figma's approval list is your own call, and it
may break Figma's terms.

## Troubleshooting

| Problem | What it means |
| --- | --- |
| `Client registration failed: 403 Forbidden` | Figma has not approved the gateway yet. See the note at the top. |
| Signed in, but no files found | That account cannot open those files or that team. Fix it in Figma. |
| Edits show the wrong name | The connection is **Shared**. Switch to **Per-user** and have everyone reconnect. |
| A tool you expected is missing | Figma offers different tools depending on the file type and what is selected. |

## More from Figma

[Figma MCP server](https://developers.figma.com/docs/figma-mcp-server/) ·
[Remote server installation](https://developers.figma.com/docs/figma-mcp-server/remote-server-installation/) ·
[Tools and prompts](https://developers.figma.com/docs/figma-mcp-server/tools-and-prompts/) ·
[MCP Catalog](https://www.figma.com/mcp-catalog/)
