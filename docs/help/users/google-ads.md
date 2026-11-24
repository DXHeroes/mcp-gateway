# Google Ads reporting

The **Google Ads** preset connects DXH Gateway to your deployment of Google's
Google Ads MCP server. Each connection authorizes its own Google account. The
deployment below exposes customer discovery, field metadata and reporting.

## Deploy the reporting server

1. Enable **Google Ads API** in the Google Cloud project that owns the OAuth
   client. Test access covers test accounts. For production reporting, check
   that the project has Explorer, Basic or Standard access and that its
   permitted use covers reporting. Give each Google identity **Read-only**
   access to its Ads customer or manager. [Google Ads API access levels](https://developers.google.com/google-ads/api/docs/api-policy/access-levels)
2. Configure the Google OAuth consent screen and audience. Create a **Web
   application** OAuth client with the redirect URI
   `https://<ads-host>/auth/callback`. Google sends users back to this server.
   Separately, DXH Gateway registers its own `/api/oauth/callback` with that
   server through dynamic client registration. Keep the Google client secret
   on the reporting server.
3. Install the pinned upstream release in an isolated Python 3.12 environment
   with `python -m pip install 'google-ads-mcp==0.0.6'`.
   Save the following configuration as `tools.yaml` in the service's working
   directory. Each group allows only the named tool. The bundled default also
   enables label and asset mutations. [Upstream release](https://github.com/googleads/google-ads-mcp/tree/v0.0.6)

```yaml
namespaces:
  customers:
    enabled_tools: [list_accessible_customers]
  metadata:
    enabled_tools: [get_resource_metadata]
  search:
    enabled_tools: [search]
```

4. Inject `GOOGLE_ADS_MCP_OAUTH_CLIENT_ID` and
   `GOOGLE_ADS_MCP_OAUTH_CLIENT_SECRET` through the service's secret store.
   Keep stable, independent signing and storage secrets in
   `GOOGLE_ADS_MCP_JWT_SIGNING_KEY` and
   `GOOGLE_ADS_MCP_STORAGE_ENCRYPTION_KEY`. Set `ADS_HOST` to the real public
   hostname and mount a private, persistent, writable OAuth volume at
   `/var/lib/google-ads-mcp` for this single instance. Start the service behind
   an HTTPS reverse proxy forwarding requests at the root of that hostname.

```sh
export GOOGLE_ADS_MCP_BASE_URL="https://${ADS_HOST:?Set the public hostname}"
export GOOGLE_ADS_MCP_TOOLS_CONFIG="$PWD/tools.yaml"
export GOOGLE_ADS_MCP_STORAGE_TYPE=filetree
export GOOGLE_ADS_MCP_STORAGE_PATH=/var/lib/google-ads-mcp
: "${GOOGLE_ADS_MCP_OAUTH_CLIENT_ID:?}" "${GOOGLE_ADS_MCP_OAUTH_CLIENT_SECRET:?}"
: "${GOOGLE_ADS_MCP_JWT_SIGNING_KEY:?}" "${GOOGLE_ADS_MCP_STORAGE_ENCRYPTION_KEY:?}"
PORT=8080 google-ads-mcp
```

The upstream requests Google identity scopes and
`https://www.googleapis.com/auth/adwords`. Google Ads has a single API scope.
The mounted allowlist and the user's Ads role constrain operations. Leave
`GOOGLE_ADS_LOGIN_CUSTOMER_ID` unset for a deployment serving multiple managers.

## Publish the deployed URL in a company catalog

To pin the reporting server for your workspace, create a discovery document
with its actual endpoint. With `ADS_HOST` set as above, this command writes a
single-offer document. To extend an existing source, append this entry to its
`servers` array and retain the other entries.

```sh
jq -n --arg url "https://${ADS_HOST:?}/mcp" '{
  schemaVersion: 1,
  servers: [{
    id: "google-ads", name: "Google Ads", description: "Google Ads reporting",
    version: "0.0.6", endpoint: {transport: "streamable-http", url: $url},
    auth: {type: "oauth", credentialModes: ["per_user"], defaultCredentialMode: "per_user"}
  }]
}' > google-ads-catalog.json
```

Serve the document at a stable HTTPS URL accessible to the gateway. In
**Servers → Catalog → Company catalog sources**, add that document URL and
refresh the source. Members can then choose the company offer with a fixed
endpoint and personal OAuth. The community preset also works on its own.

## Connect two accounts

1. In **Servers → Catalog → Community presets**, add **Google Ads**. Enter the
   reporting hostname and check that the resulting URL is
   `https://<ads-host>/mcp`. Keep **Per-user** and **OAuth** with automatic
   discovery. Give this server a recognizable name and the tool prefix
   `ads-a`. Save it and authorize account A from **My Connections**.
2. Add a second Google Ads server with the same hostname, its own name and
   prefix `ads-b`. Authorize account B. Check the email on each Google consent
   screen. Separate browser profiles can help select the intended account.
3. Assign both servers to the profile used by the MCP client and refresh its
   tool list. Each prefix should expose exactly
   `customers_list_accessible_customers`, `metadata_get_resource_metadata` and
   `search_search`. For example, call `ads-a_customers_list_accessible_customers`
   and then its `ads-b_` counterpart. Compare each result with the expected
   directly accessible customer or manager IDs. A manager's child can be
   absent from this list. [List accessible accounts](https://developers.google.com/google-ads/api/docs/account-management/listing-accounts)
4. Under each prefix, call `metadata_get_resource_metadata` for
   `{"resource_name":"campaign"}`. Then call `search_search` with the following
   arguments, replacing the IDs with those for that account. Set
   `login_customer_id` to the authorizing manager for an indirect customer.
   Omit it for a directly accessible customer.

```json
{
  "customer_id": "<target customer ID>",
  "login_customer_id": "<manager ID>",
  "resource": "campaign",
  "fields": ["customer.id", "campaign.id", "metrics.impressions"],
  "conditions": ["segments.date DURING LAST_7_DAYS"],
  "limit": 1
}
```

Check `customer.id` against the requested target in each result. If there is no
campaign activity, query `customer` with fields `["customer.id"]` and limit 1,
then use a reporting period with known activity for the campaign check.

To reconnect, authorize the **same server row** from **My Connections** with
its original Google identity. Repeat both prefixed customer lists and reports
after reconnecting one row and after restarting the reporting server. Retain
the hostname, signing key, encryption key and OAuth volume across restarts.
