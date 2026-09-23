# Microsoft 365

Three presets (Teams, SharePoint and OneDrive) connect the gateway to Microsoft's official Work IQ
MCP servers. One Entra app registration covers all three.

> **Your tenant needs Microsoft 365 Copilot licensing.** Without it these servers cannot be
> reached at all, and there is nothing to configure in the gateway.

> **This is a preview.** Microsoft has changed the endpoints and permissions more than once. Where
> this page disagrees with Microsoft's own reference, trust Microsoft. Every field in the install
> form can be edited.

**You need:** Microsoft Entra administrator access, your **Directory (tenant) ID** from the Entra
admin center, and the owner or admin role in the gateway.

---

## 1. Register the Entra application

Do this once, as an Entra administrator
([Microsoft's guide](https://learn.microsoft.com/en-us/entra/identity-platform/quickstart-register-app)):

1. **Entra admin center** → **App registrations** → **New registration**.
2. For **Redirect URI** choose platform **Web** and enter
   `https://<your-gateway-host>/api/oauth/callback`, exactly, with no trailing slash.
3. **API permissions** → **Add a permission** → **APIs my organization uses** → search for
   **Agent 365 Tools**. Add the **delegated** permission for each server you want, then click
   **Grant admin consent**. Your colleagues cannot approve these themselves.

   | Preset | Delegated permission |
   | --- | --- |
   | Microsoft Teams | `McpServers.Teams.All` |
   | Microsoft SharePoint | `McpServers.SharePoint.All` |
   | Microsoft OneDrive | `McpServers.OneDrive.All` |

   If the search finds nothing, your tenant has no Agent 365 entitlement and these presets
   cannot be used. Talk to whoever manages your Microsoft licensing.
4. Optionally create a client secret under **Certificates & secrets**. Entra also accepts an app
   with no secret; in that case leave the gateway's secret field empty.
5. Copy the **Application (client) ID** and the **Directory (tenant) ID**.

## 2. Install a preset

1. **Servers** → **Catalog** → **Community presets** → pick the server → **Add to my servers**.
2. Enter the **tenant ID** first. The server address is built from it, and the form will not save
   until it is filled in.
3. Enter the **client ID**, and the client secret if you made one.
4. Leave the credential mode on **per-user**. These servers act as whoever is signed in, so a
   shared credential would make everything look like it came from one person.
5. **Create server**. Everyone then connects under **My connections**. See
   [Service credentials](./per-user-connections.md).

Repeat for each of the three.

## A note on scopes

Each preset asks for `offline_access` plus one permission written with a long id in front of it,
for example `ea9ffc3e-8a23-4a7d-836d-234d7c7565c1/McpServers.Teams.All`. Two things matter:

- **That id prefix is required.** Without it, Entra thinks you mean a Microsoft Graph permission.
- **`offline_access` is what keeps the connection alive.** Remove it and the connection dies at
  the first token expiry, about an hour in.

---

## Troubleshooting

| Problem | What it means |
| --- | --- |
| `AADSTS50011`, redirect URI mismatch | The redirect URI on the Entra app does not exactly match `https://<gateway>/api/oauth/callback`. |
| "Does not support dynamic client registration" | No client ID was entered. Entra needs the one from step 1. |
| `AADSTS650053`, scope does not exist | The permission lost its id prefix. See "A note on scopes". |
| Signing in works, but tool calls return 403 | Admin consent was never granted, or the tenant has no Copilot licensing. |
| It works for an hour, then stops | `offline_access` was removed from the scopes. |

## More from Microsoft

[Teams](https://learn.microsoft.com/en-us/microsoft-agent-365/mcp-server-reference/teams) ·
[SharePoint](https://learn.microsoft.com/en-us/microsoft-agent-365/mcp-server-reference/sharepoint) ·
[OneDrive](https://learn.microsoft.com/en-us/microsoft-agent-365/mcp-server-reference/onedrive) ·
[AADSTS error codes](https://learn.microsoft.com/en-us/entra/identity-platform/reference-error-codes)
