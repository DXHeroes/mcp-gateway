# OAuth connectors maintained by DX Heroes

Use these independently deployed connectors when a provider's official MCP server
does not cover the required service, operations or account types. Their source and
provider setup instructions live in [DXHeroes/mcp-servers](https://github.com/DXHeroes/mcp-servers).
The gateway connects to their HTTP endpoints; it does not install or run them.

Catalog sources, connector OAuth and managed presets are available in CE and EE.
Product integrations using managed users, connect links and the published SDK require
Enterprise Edition. See [workspace integrators](./integrators.md).

## Choose the service

The paths below belong to separate connector deployments. Use the matching package
and a catalog offer for each service, including when several offers share one image.

| Catalog offer ID | Package | Endpoint path | Account audience |
| --- | --- | --- | --- |
| `google-tasks` | `google` | `/tasks/mcp` | Personal Google and Workspace |
| `google-contacts` | `google` | `/contacts/mcp` | Personal Google and Workspace |
| `google-search-console` | `google` | `/search-console/mcp` | Google accounts with Search Console property access |
| `outlook-mail` | `outlook` | `/mail/mcp` | Personal Microsoft and work/school |
| `outlook-calendar` | `outlook` | `/calendar/mcp` | Personal Microsoft and work/school |
| `microsoft-teams` | `microsoft-teams` | `/mcp` | Work/school only |
| `slack` | `slack` | `/mcp` | Eligible internal pilot only; see below |

Tasks and writable Contacts use Google's REST APIs. The Microsoft connectors use
Graph directly to cover the required account types and operations. Slack is an
internal bridge with a separate distribution gate. For provider-operated servers,
see [official provider connectors](./official-connectors.md).

The separate `google-gmail-send` offer at `/gmail/mcp` requests `gmail.send` and
provides sending and replies. It is a limited pilot, with no mailbox reads; it does
not replace a complete Gmail integration. Keep the official Gmail/Calendar/Drive
setup in [Google Workspace](./google-workspace.md) separate from these offers.

## Deploy the connector and publish its catalog

1. Deploy the matching HTTP connector from the public repository. Use a verified
   immutable image that contains the chosen service. Follow the
   [independent deployment guide](https://github.com/DXHeroes/mcp-servers/blob/main/docs/runtime.md) for TLS,
   network access and separate connector/catalog service credentials.
2. In a built checkout of `DXHeroes/mcp-servers`, create a deployment map using
   **offer IDs**, not package aliases. For example:

   ```json
   {
     "google-tasks": "https://google-connector.example.com/tasks/mcp",
     "google-contacts": "https://google-connector.example.com/contacts/mcp",
     "google-search-console": "https://google-connector.example.com/search-console/mcp",
     "outlook-mail": "https://outlook-connector.example.com/mail/mcp",
     "outlook-calendar": "https://outlook-connector.example.com/calendar/mcp",
     "microsoft-teams": "https://teams-connector.example.com/mcp",
     "slack": "https://slack-connector.example.com/mcp"
   }
   ```

   Include only the services deployed and approved for your installation. Generate
   the manifest with `node scripts/catalog-manifest.mjs deployment.json > catalog.json`.
   The generator supplies each offer's OAuth endpoints, scopes and credential delivery.
3. Serve that manifest using the repository's catalog service and add its URL under
   the gateway's **Catalog sources**. The catalog source token authenticates catalog
   reads. It must differ from the token protecting a connector endpoint.
4. As a workspace owner or admin, create a managed preset based on the catalog offer.
   Keep **OAuth** and **Per-user**. Configure the provider client and review its scopes
   using the sections below. In **Connector access**, enter the connector service
   token; the API field is `serviceAuthToken`. This is separate from the provider's
   OAuth client secret and each user's access token.
5. Register the preset's exact `redirectUri` with the provider:
   `https://<gateway-host>/api/oauth/callback`. A product's SDK return URL belongs in
   that product's integrator allowlist; it is not the provider's OAuth callback.
6. Enable the preset, then connect each person's own account. The gateway stores and
   renews provider credentials. The connector receives only that call's access token;
   client secrets and refresh tokens stay in the gateway.

Do not install these OAuth offers as shared API-key connections, paste a user token
into Connector access, or manually replace the catalog's credential-delivery headers.
A successful catalog refresh proves that offers can be read; it does not prove that
their endpoints, provider registrations or account permissions work.

## Google Tasks and Contacts

In Google Cloud, enable **Google Tasks API** for Tasks and **People API** for Contacts.
Create a **Web application** OAuth client and register the gateway callback above.
Use an **External** consent audience for personal Google accounts; configure test users
while the app is in testing. Set this client on each relevant managed preset.

| Service | Requested scope | Classification |
| --- | --- | --- |
| Tasks read/write | `https://www.googleapis.com/auth/tasks` | Sensitive |
| Contacts read/write | `https://www.googleapis.com/auth/contacts` | Sensitive |
| Optional Workspace directory, separate `google-directory` offer | `https://www.googleapis.com/auth/directory.readonly` | Sensitive; Workspace directory only |
| Optional Gmail Send pilot | `https://www.googleapis.com/auth/gmail.send` | Sensitive |

The Tasks and Contacts write scopes already include their corresponding reads.
Gmail Send does not grant mailbox reads. Do not add directory
permissions to a personal Contacts connection. The generated Google offers request
offline access and consent so the gateway can refresh credentials.

Recheck classifications in your project's **Google Auth Platform → Data Access**;
that console is authoritative for sensitive-scope indicators. Complete the applicable
verification before public rollout. Tasks, Contacts and Gmail Send do not themselves
request restricted scopes; other grants on the same OAuth app need their own review.
These instructions do not establish app verification or a production rollout approval.

References: [Google scope reference](https://developers.google.com/identity/protocols/oauth2/scopes),
[connector setup and tools](https://github.com/DXHeroes/mcp-servers/blob/main/connectors/google/README.md).

## Google Search Console

Enable **Google Search Console API** in the OAuth client’s Google Cloud project.
Register a Web application with the gateway callback above. On the per-user
`google-search-console` preset, request only
`https://www.googleapis.com/auth/webmasters.readonly`. Give each account access to
its test properties in Search Console. [Google’s property permissions guide](https://support.google.com/webmasters/answer/7687615)

Use the **External** consent audience for personal Google accounts or accounts
from different Workspace organizations. In **Testing**, add both accounts as test
users. Google expires their grants, including refresh tokens, after seven days.
[Google’s app audience guide](https://support.google.com/cloud/answer/15549945)

1. Create one connection for each Google account with prefixes such as `gsc-work`
   and `gsc-personal`. Use both in the same profile and select the intended account
   when Google prompts for consent. In `tools/list`, check for both
   `gsc-work_search_console_list_properties` and `gsc-personal_search_console_list_properties`.
2. Run each connection’s `search_console_list_properties`. Copy the exact
   `siteUrl`, such as `sc-domain:example.com` or `https://example.com/blog/`,
   into `search_console_get_property` to read the account’s permission level.
3. Run `search_console_query_analytics` for a known active property using inclusive
   Pacific dates, for example `{"siteUrl":"sc-domain:example.com","startDate":"2026-10-01","endDate":"2026-10-07","dimensions":["date"],"rowLimit":5}`.
   Each call accepts up to 31 days and 100 rows, with 10 rows by default. A successful
   query with no matching data can return an empty report.
4. Run `search_console_inspect_url` with the property identifier and one
   `inspectionUrl` inside that property. The result describes Google's indexed
   version. [API reference](https://developers.google.com/webmaster-tools/v1/api_reference_index)
5. Verify each connection against a property accessible only to the other account.
   Google should deny access. When the gateway asks for a new grant, reconnect the
   same connection, select the original account, and repeat the property check
   through both prefixes.

Google limits Search Analytics by query load and by site, user and project. URL
Inspection allows 2,000 inspections per day and 600 per minute per site, alongside
project limits. On HTTP 429, observe the returned retry delay. On HTTP 403, check
the property grant, API enablement and project quota usage. For a Search Analytics
short-term load limit, Google recommends waiting 15 minutes before retrying.
[Google’s usage limits](https://developers.google.com/webmaster-tools/limits)

## Outlook mail and calendar

Register an Entra application supporting **accounts in any organizational directory
and personal Microsoft accounts**. Add the exact gateway callback as a **Web** redirect
and create a client secret for the gateway. Use delegated Graph permissions, with
separate presets requesting only their own service's scopes:

| Offer | Delegated permissions |
| --- | --- |
| `outlook-mail` | `User.Read`, `offline_access`, `Mail.ReadWrite`, `Mail.Send`, `MailboxSettings.Read` |
| `outlook-calendar` | `User.Read`, `offline_access`, `Calendars.ReadWrite` |

Both offers use the `common` authority:
`https://login.microsoftonline.com/common/oauth2/v2.0/authorize` and
`https://login.microsoftonline.com/common/oauth2/v2.0/token`. They use registered
clients, without DCR. A tenant-only app cannot serve personal Outlook.com accounts.
Tenant consent policies and publisher-verification requirements still apply.

### Register both offers in a workspace

1. Deploy the Outlook connector and a dedicated catalog service. Use the connector
   image and manifest generator from matching releases. Connector release `0.1.1`
   supports discovery of both services. Replace `outlook.example.com` below with the
   host reachable from your gateway, and save this as `outlook-deployment.json`:

   ```json
   {
     "outlook-mail": "https://outlook.example.com/mail/mcp",
     "outlook-calendar": "https://outlook.example.com/calendar/mcp"
   }
   ```

2. From the built connector checkout, run
   `node scripts/catalog-manifest.mjs outlook-deployment.json > catalog.json`.
   Mount the result at the catalog service's `MCP_CATALOG_MANIFEST` path. As a
   workspace owner or admin, open **Catalog sources** in the intended workspace.
   Add the catalog's `/catalog/v1/servers` URL with its source token and a stable
   key such as `outlook`. If the source already exists, refresh it. On an
   authenticated `GET /api/catalog-sources`, expect `serverCount: 2` and
   `stale: false` on this source. In `GET /api/mcp-servers/presets`, match its
   `sourceId` and check for `outlook-mail` and `outlook-calendar` at the end of
   the two catalog IDs.
3. Create and enable one managed preset per catalog offer. Set the Entra client
   and connector service token on each preset as described above. Confirm each
   authorization request asks for the scopes in its own row. If tenant policy
   requires an administrator, give the administrator the tenant, client ID and
   that offer's explicit scopes. Entra's `/.default` requests the app's full
   configured permission set. Use separate app registrations for Mail and
   Calendar when their tenant-wide grants must be independently revocable.
   [Microsoft's admin consent guide](https://learn.microsoft.com/en-us/entra/identity-platform/v2-admin-consent)

### Verify two work tenants

Use an authorized account with a provisioned Exchange Online mailbox in each
work tenant. Connect both presets as tenant A, then both as tenant B, selecting
the intended account in Microsoft's picker each time. Assign all four connections
to one profile. For example, use `mail-a`, `cal-a`, `mail-b` and `cal-b` as their
tool prefixes. The following checks use one page per read.

| Check | Run through each tenant's prefix | Expected result |
| --- | --- | --- |
| Mail identity and folders | Run `mail_list_folders` with `{"top":5}`. Compare a returned folder ID with a known folder from that account. | Each prefix matches its own mailbox. Common folder names such as Inbox occur in both tenants. |
| Calendar identity | Call `calendar_get_free_busy` for a 15-minute UTC interval with `startDateTime` and `endDateTime`. Omit `schedules` to resolve the connected account. | `scheduleId` in the returned schedule matches the intended account. |
| Calendar read | Call `calendar_list_events` on the default calendar with explicit UTC `startDateTime` and `endDateTime` seven days apart, `top: 5` and `select: "id"`. | A page of up to five event IDs or an empty page for a quiet week. |

Reconnect tenant A's existing connections, select A again and repeat the reads
through both sets of prefixes. For each environment, record the offer, tenant alias,
operation, identity match and outcome. Keep message contents, event IDs and tokens
out of the record.

| Where the check stopped | What to verify |
| --- | --- |
| Offer missing or stale | Check the workspace, source URL/token, last refresh and generated map. |
| MCP connection fails, or the connector returns HTTP 401 | Verify the endpoint path and reachability from the gateway, then the service token in **Connector access**. |
| Microsoft sign-in asks for approval or refuses consent | Record the Entra error code for that tenant and offer. Have the tenant administrator review consent policy, scopes and publisher requirements. |
| Graph refuses the mailbox read | Confirm the signed-in account has an active Exchange Online mailbox accessible to Graph. A connector build containing the [mailbox diagnostic](https://github.com/DXHeroes/mcp-servers/pull/22) returns `mailbox_rest_unavailable` for recognized mailbox-specific 404s. Release `0.1.1` returns a generic provider error for those responses. A generic 404 alone cannot establish the cause. |

See the [Outlook registration and tool guide](https://github.com/DXHeroes/mcp-servers/blob/main/connectors/outlook/README.md)
for image verification and tool parameters. The [Microsoft 365 guide](./microsoft-365.md)
covers the vendor presets.

## Microsoft Teams

Teams uses work/school accounts and the `organizations` authority:
`https://login.microsoftonline.com/organizations/oauth2/v2.0/authorize` and
`https://login.microsoftonline.com/organizations/oauth2/v2.0/token`. A shared Entra
registration can serve Outlook and Teams when it has the combined account audience
above; keep each preset's authority and scopes separate. Personal Microsoft accounts
cannot use this Teams route.

Request delegated `User.Read`, `offline_access`, `Chat.ReadWrite`,
`ChannelMessage.Read.All`, `ChannelMessage.Send`, `Team.ReadBasic.All`,
`Channel.ReadBasic.All` and `User.ReadBasic.All`. **ChannelMessage.Read.All requires
administrator consent**; tenant policy can require approval for other permissions
too. Use the user's own accessible chats/channels for testing, with separate approval
for posting and cleanup. The connector does not create chats or channels.

References: [Teams registration guide](https://github.com/DXHeroes/mcp-servers/blob/main/connectors/microsoft-teams/README.md),
[Graph permission reference](https://learn.microsoft.com/en-us/graph/permissions-reference).
Real-account consent and read/write acceptance must be verified in your tenant.

## Slack internal bridge

The `slack` catalog offer calls Slack's Web API directly. It is an **internal pilot**;
the final public route targets the [official Slack MCP server](./slack.md). A successful
home-workspace installation does not prove eligibility or acceptance in another workspace.
Establish the app's distribution eligibility and history limits before external use.

Register the callback on your Slack app and configure these **User Token Scopes**:

```text
channels:read     channels:history     groups:read     groups:history
im:read           im:history           users:read      chat:write
reactions:write   search:read
```

The offer uses `https://slack.com/oauth/v2_user/authorize` and
`https://slack.com/api/oauth.v2.user.access`, with `scope` and no bot scopes.
Use a client configured for the gateway's PKCE flow. Review Slack's
[PKCE requirements](https://docs.slack.dev/authentication/using-pkce/) before changing
an app: enabling it changes the client type, cannot be undone without Slack support,
and changes refresh-token lifetime. Do not change an existing production app just
to run a test. The bridge does not require the official server's MCP enablement or
its additional user scopes.

An installation limit or admin-approval page is a provider setup refusal. Resolve
it with the workspace owner before retrying; do not remove another app or start a
paid trial as an automatic repair. The bridge provides no message edit/delete tools;
plan any approved synthetic-message cleanup in Slack itself.

See the [bridge's scopes, rate limits and distribution boundary](https://github.com/DXHeroes/mcp-servers/blob/main/connectors/slack/README.md).

## Verify access and recovery

Test the connected account and one bounded read before granting writes. For a bound
product, enable the explicit per-preset `integratorWrites` grant under
[Integrators](./integrators.md); the preset's legacy write switch applies only to
unbound legacy service keys. Provider consent and gateway write policy both apply.

Use the published `@dxheroes/mcp-gateway-sdk`: `connections.createLink`,
`parseConnectReturn`, `confirm`, then `connections.mcpEndpoint`. Keep the returned
connection ID. Reconnect that ID through a new connect link when the gateway returns
`credential_required`, `credential_expired` or `credential_refused`. A connector's
service-authentication failure needs its service token repaired instead of asking
the user to reconnect their provider account.

Before rollout, record actual read/write readback, two-account isolation, revoked-token
recovery, latency and cleanup for the chosen deployment. After SDK `disconnect`, verify
that the old endpoint is refused; provider-side OAuth grants may need separate cleanup.
Published source, a catalog entry and local tests do not prove those live checks.
