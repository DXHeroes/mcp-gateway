# Microsoft 365

For the independently deployed Outlook and Microsoft Teams connectors, including
Outlook.com accounts, see [DX Heroes OAuth connectors](./oauth-connectors.md#outlook-mail-and-calendar).

## Unified Work IQ preview

Gateway has no default catalog offer for the unified endpoint. On 20 November 2026,
an unauthenticated GET to `https://workiq.svc.cloud.microsoft/mcp` returned HTTP 401.
Its challenge pointed to metadata listing only
`fdcc1f02-fc51-4226-8753-f668596af7f7/WorkIQAgent.Ask`. Microsoft says Ask can authorize
agents to write, and Ask alone hides SharePoint paths. Microsoft documents a separate
delegated permission for reading, `WorkIQ.Read`, which requires administrator consent.
Whether Gateway can obtain and use that grant in an eligible tenant remains unverified.
[Endpoint metadata](https://workiq.svc.cloud.microsoft/.well-known/oauth-protected-resource/mcp) ·
[Work IQ permissions](https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/work-iq/permissions) ·
[SharePoint path visibility](https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/work-iq/sharepoint-iq)

### Verify delegated reads in a test tenant

1. Have the administrator confirm Work IQ enablement, the user's licensing or billing
   entitlement, access to the test data, and tenant consent for `WorkIQ.Read` on an existing
   Entra client. Verify its Web redirect URI exactly matches
   `https://<gateway-host>/api/oauth/callback`.
   [Microsoft tenant prerequisites](https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/work-iq/enable-work-iq)
2. In a test profile, add the unified URL as a Streamable HTTP server with **Per-user**
   credentials and **Manual OAuth**. Use the registered client ID and its configured
   credentials. Use the tenant's Entra v2 `/authorize` and `/token` endpoints under
   `https://login.microsoftonline.com/<tenant-id>/oauth2/v2.0`. Explicitly request
   `api://workiq.svc.cloud.microsoft/WorkIQ.Read`; add `offline_access` for renewal.
   Verify that the issued grant targets Work IQ and that its only Work IQ permission
   is `WorkIQ.Read`. Record the scope and an anonymous tenant label. Keep tokens private.
3. Confirm the active tenant policy under **Microsoft 365 admin center → Agents → Tools →
   Work IQ MCP → Policy**. Work IQ checks the resource path, underlying method and operation,
   and the signed-in user's access. Mutations are blocked by default. Gateway can block an
   entire tool by name, but allowing `fetch` does not restrict its `entityUrls` arguments.
   The initial Microsoft policy controls apply tenant-wide.
   [Microsoft policy controls](https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/work-iq/mcp/policy-governance-mcp)
4. Use `search_paths` and `get_schema` to identify supported reads. With `fetch`, try
   one path at a time: `/me/messages?$top=1`, `/me/events?$top=1` and
   `/me/chats/{known-chat-id}/messages?$top=1`. For SharePoint, discover a read under
   `/sharepoint` and request metadata for one known test object. Check the MCP result
   and each returned status. In the isolated tenant, verify a denied GET on a restricted
   fixture. On a disposable event, verify that the read succeeds and the update (PATCH)
   is refused. Verify that an action (POST) is also refused using a test-only destination.
   Record whether Gateway or Work IQ denied each call and check for side effects.
   [Work IQ tool reference](https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/work-iq/mcp/tool-reference)
5. For cross-tenant use, authorize two named connections with different prefixes in
   one user's profile. Check both prefixes in `tools/list` and read a known fixture unique
   to each tenant. Reconnect the first connection and repeat both reads. A missing license,
   grant or test account leaves the result open.

### Separate workload connections

The following calls test a single read. Each connector's configured OAuth grant also
permits writes. Review its scopes before authorizing it. A live tenant read is still
unverified for all four workloads.

| Workload | Available connection | Bounded read to verify |
| --- | --- | --- |
| Mail | `outlook-mail` (DX Heroes) | `mail_list_folders` with `{"top":1}` on the connected mailbox |
| Calendar | `outlook-calendar` (DX Heroes) | `calendar_list_calendars` with `{"top":1}` on the connected mailbox |
| Teams | `microsoft-teams` (DX Heroes Graph connector) | `teams_list_chats` with `{"top":1}` on a work or school account |
| SharePoint | Microsoft SharePoint (legacy Agent 365 community preset) | For an existing deployment, check for `getSiteByPath` and request one known test site. A production route for new deployments remains unverified. |

The Outlook catalog source has been tested locally with a released image.
For connector deployment, scopes and account requirements, see
[DX Heroes OAuth connectors](./oauth-connectors.md). Microsoft reserves its
workload-specific Agent 365 servers for backward compatibility and advises against
using them for new projects or production.
[Microsoft server guidance](https://learn.microsoft.com/en-us/microsoft-agent-365/tooling-servers-overview) ·
[Legacy SharePoint tool reference](https://learn.microsoft.com/en-us/microsoft-agent-365/mcp-server-reference/sharepoint)

## Legacy Agent 365 presets

The Teams, SharePoint and OneDrive community presets use separate Microsoft-hosted
endpoints. The following setup applies to existing installations of these presets.
One Entra app registration covers all three.

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
