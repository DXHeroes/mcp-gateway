# Official provider connectors

The Catalog's **Community presets** section includes provider-operated MCP servers.
Pipedrive, HubSpot, Linear, Atlassian and Airtable use the entries below. GitHub has
separate OAuth and PAT variants; Attio, Notion and Slack retain their own guides.
Each connection should use the person's own provider account. Provider permissions
and gateway tool permissions both apply.

| Preset | Server | Client setup |
| --- | --- | --- |
| Pipedrive | `https://mcp.pipedrive.ai/mcp` | OAuth discovery and DCR; callback eligibility must be verified |
| HubSpot | `https://mcp.hubspot.com` | Pre-register a HubSpot MCP connector; PKCE required |
| Linear | `https://mcp.linear.app/mcp` | OAuth discovery and DCR |
| Atlassian (Jira and Confluence) | `https://mcp.atlassian.com/v2/mcp?tools=all` | OAuth discovery and DCR; flat v2 tools |
| Airtable | `https://mcp.airtable.com/mcp` | OAuth discovery and DCR |
| [GitHub MCP (OAuth)](./github.md) | `https://api.githubcopilot.com/mcp/` | Register a GitHub OAuth App; the PAT entry remains separate |
| [Attio](./attio.md) | `https://mcp.attio.com/mcp` | OAuth discovery and DCR |
| [Notion](./notion.md) | `https://mcp.notion.com/mcp` | OAuth discovery and DCR |
| [Slack](./slack.md) | `https://mcp.slack.com/mcp` | Registered Slack app eligible for official MCP access |

## Connect your account

1. Choose the provider in **Servers → Catalog → Community presets**.
2. Keep **Per-user** and the OAuth method. Discovery-based entries use automatic
   authentication; they do not require a token pasted into an API-key field.
3. For a provider requiring a registered client, have an administrator register
   the gateway callback exactly as `https://<gateway-host>/api/oauth/callback`,
   then enter that client's credentials. Client secrets belong on the backend.
4. Save and complete the provider sign-in. Check the connected identity and tools
   before adding the server to a profile. A provider account, consent or app approval
   can restrict the resulting tool set.

DCR creates the OAuth client during authorization; it does not register a provider
user account or guarantee that the provider accepts your gateway callback. Use
DXH Gateway's own client identity. Do not impersonate another MCP client to bypass
provider admission restrictions.

## Pipedrive

Select **Pipedrive** and let discovery obtain its authorization server and DCR
endpoint from provider metadata. The declared server is `oauth.pipedrive.com`.
Do not paste a company's REST API domain into the MCP server URL; the official
server is responsible for company routing.

For a managed preset, explicitly choose the grants needed for the integration.
A starting set to verify for deals, persons/organizations, activities, notes and
search is `base`, `deals:full`, `contacts:full`, `activities:full` and `search:read`.
Metadata advertises a wider set, including administrative scopes: do not treat
that advertised list as a recommendation to grant every scope. Verify actual tool
coverage and granted permissions before replacing a native integration.

A provider can refuse DCR with `invalid_redirect_uri`. Keep the exact callback,
record the refusal safely and have the app-registration owner request allowlisting.
Do not keep registering clients or change the identity to work around it.
A successful public metadata read is not proof of callback acceptance or tools.
See the [provider's MCP announcement](https://www.pipedrive.com/en/newsroom/pipedrive-launches-native-mcp-server-bringing-crm-workflows-directly-into-ai-assistants)
and [OAuth scopes](https://pipedrive.readme.io/docs/marketplace-scopes-and-permissions-explanations).

## HubSpot

In HubSpot, open **Development → MCP Connectors → Create MCP connector**. Register
`https://<gateway-host>/api/oauth/callback` and use the generated client ID and secret.
This is an MCP connector, separate from a regular CRM app or the developer MCP server.
The preset uses `https://mcp.hubspot.com/oauth/authorize/user` and
`https://mcp.hubspot.com/oauth/v3/token` with the resource `https://mcp.hubspot.com`.
The gateway sends PKCE S256. DCR is not advertised for this service.

The preset deliberately requests no fixed scope names: HubSpot determines available
permissions from its tools and the user's consent. Do not add guessed CRM scopes.
After sign-in, `get_user_details` is the provider's documented way to inspect access.
Subscription and account settings can limit data and tools; a connected token does
not prove complete CRM coverage. [HubSpot setup](https://developers.hubspot.com/docs/apps/developer-platform/build-apps/integrate-with-the-remote-hubspot-mcp-server).

## Linear

Choose **Linear**, keep automatic OAuth discovery and authorize the intended
workspace. No pre-registered client is needed when the provider accepts DCR.
The provider currently advertises `read` and `write` for the MCP resource; an
operator can narrow the managed preset's scopes. Workspace application approval
and the signing-in user's permissions still apply. [Linear MCP](https://linear.app/docs/mcp).

## Atlassian

The preset uses v2 with `tools=all` so Jira and Confluence tools are exposed as
individual tools. Keep that query parameter when using gateway tool policies.
Discovery follows the v2 protected-resource document to its authorization server;
do not pin v1 OAuth endpoints or reuse another client's cached registration.
Select only required Jira/Confluence read, search and write grants during setup,
plus refresh access as offered. The provider's advertised scope set also includes
other products and administrative capabilities.

The signed-in user needs access to the selected Atlassian sites. Review the actual
tools and their permissions before making them available. [Atlassian setup](https://support.atlassian.com/atlassian-ai-gateway/docs/get-started-with-the-atlassian-remote-mcp-server/).

## Airtable

Choose **Airtable** and complete automatic OAuth discovery/DCR. The provider's
current scope set includes `data.records:read`, `data.records:write`,
`schema.bases:read`, `schema.bases:write`, `data.recordComments:read`,
`data.recordComments:write` and `workspacesAndBases:read`. Grant only the operations
and bases needed by the integration. The user's base access and provider policies
still constrain calls. [Airtable setup](https://airtable.com/developers/agents/mcp/getting-started).

## Managed integrator connections

Managed presets and the integrator API require Enterprise Edition. Create an
OAuth managed preset from the selected catalog entry. For HubSpot, GitHub and
Slack supply the registered application client; for DCR providers leave the client
empty unless you already have an appropriate registered client. Select scopes
explicitly where needed, then have each managed user complete a connect link and
confirmation before invoking tools through its SDK endpoint.

The preset's **integratorWrites** starts off. A write requiring approval is refused
for a service-key caller until the administrator enables it. An explicitly blocked
tool stays blocked when the switch is on. Provider-side write consent does not
change gateway tool policy. Test the actual read/write behavior for each provider
before rollout; these setup instructions are not an acceptance report.
