# Google Analytics 4

The Google Analytics 4 preset in Community and Enterprise connects DXH Gateway to
an operator-hosted copy of Google's Analytics MCP server. Each signed-in Gateway
user authorizes a Google account for each connection. The admin and reporting
tools use that account's property permissions.

## Deploy the reporting endpoint

1. Enable the **Google Analytics Admin API** (`analyticsadmin.googleapis.com`)
   and **Google Analytics Data API** (`analyticsdata.googleapis.com`) in your
   Google Cloud project. Ask a GA4 property administrator to give each test
   account the **Viewer** role on its own property. Pick two properties with
   known recent activity. For an isolation check, account A should have no
   access to B's property and vice versa. [Google setup and roles](https://developers.google.com/analytics/devguides/MCP)
2. In Google Auth Platform, configure the consent screen and audience. Add both
   users if the app is in external testing. Create a dedicated **Web application**
   OAuth client and register the exact redirect URI displayed by the Gateway,
   normally `https://<gateway-host>/api/oauth/callback`. Add the delegated scope
   `https://www.googleapis.com/auth/analytics.readonly`.
3. On the Analytics host, install the official server in an isolated Python 3.12
   environment. Set `GA4_HOST` to its actual HTTPS hostname. Inject the Google
   web client's ID and secret as `GOOGLE_OAUTH_CLIENT_ID` and
   `GOOGLE_OAUTH_CLIENT_SECRET` from the service's secret store. Start the
   server behind a TLS reverse proxy on the same machine that forwards
   `/mcp` to `127.0.0.1:8080` and preserves the Authorization header.
   [Official HTTP server](https://github.com/googleanalytics/google-analytics-mcp/tree/1.1.0)

```sh
python -m pip install 'analytics-mcp==1.1.0'
: "${GOOGLE_OAUTH_CLIENT_ID:?}" "${GOOGLE_OAUTH_CLIENT_SECRET:?}"
ANALYTICS_MCP_ALLOW_WRITE=false analytics-mcp --transport http --stateless-http \
  --oauth --issuer-url "https://${GA4_HOST:?Set the Analytics hostname}" \
  --host 127.0.0.1 --port 8080
```

DXH Gateway requests and refreshes tokens directly at Google. The upstream
`--oauth` option validates the bearer token against that same Google client ID
and requires the read-only scope. The server takes each request's credentials
from its bearer token. Leave application default credentials and service account
keys off the host. Only the Gateway's callback needs to be registered with
Google for this setup.

### Use a reporting endpoint restricted to DXH Gateway

You can use bearer pass-through when a trusted HTTPS reverse proxy restricts
access to the reporting endpoint to DXH Gateway. Set up that restriction before
enabling this mode. Keep the OAuth client ID and secret in the Gateway and
leave application default credentials and service account keys off the Analytics
host. Forward `/mcp` to the loopback listener with the incoming `Authorization`
and `Host` headers.

```sh
ANALYTICS_MCP_OAUTH=false ANALYTICS_MCP_ALLOW_WRITE=false \
  analytics-mcp --transport http --stateless-http \
  --issuer-url "https://${GA4_HOST:?Set the Analytics hostname}" \
  --host 127.0.0.1 --port 8080
```

The host in `--issuer-url` is allowed by the server's HTTP transport. The
reverse proxy controls access to MCP discovery. Each reporting call requires a
bearer token, and Google APIs validate the token and apply the account's property
permissions. Use `--oauth` for publicly reachable reporting endpoints. That
mode checks the client ID and scope at the HTTP endpoint.

## Connect and verify two Google accounts

1. Sign in to the Gateway. In **Servers → Catalog → Community presets**, add
   **Google Analytics 4**, fill in the Analytics hostname, and keep **Per-user**
   credentials. In the prefilled manual OAuth configuration, enter the Google
   Web application client ID and secret. With `--oauth`, use the same client
   on the Analytics host. The authorization endpoint belongs to Google and the
   scope list contains only
   `https://www.googleapis.com/auth/analytics.readonly`.
2. Give the connection a recognizable name and the tool prefix `ga-a`. Save
   it. From **My connections**, connect and choose account A on Google's
   account selector. Repeat with a second connection, prefix `ga-b`, and
   account B. Check the email on both consent screens.
3. Assign both connections to the profile your MCP client uses. Refresh its
   tool list and call `ga-a_get_account_summaries` and
   `ga-b_get_account_summaries`. Match each result's `property_summaries`
   to the expected property ID. For each prefix, run `run_report` on its
   property using the following arguments.

```json
{
  "property_id": "<numeric property ID>",
  "date_ranges": [{"start_date": "7daysAgo", "end_date": "yesterday"}],
  "dimensions": ["date"],
  "metrics": ["activeUsers"],
  "limit": 1
}
```

A report can be empty for a property without activity in that period. With the
two disjoint grants, try the other property's ID under each prefix and check
that Google denies access.

## Restart and reconnect

Keep the Analytics hostname and Google client ID stable. Restart the reporting
server and run both lists and reports again. The Gateway keeps each user's
encrypted OAuth credentials in its database and refreshes directly with
Google. If Google revokes a grant, open **My connections → Reconnect** on the
affected connection, choose the original Google account and repeat the checks
under both prefixes. With `--oauth`, compare the client ID on the reporting
server with the one in the Gateway if token validation fails on both connections.

## Publish a fixed endpoint in the company catalog

A workspace owner or administrator can publish the same configuration for
other installers. Set `GA4_HOST` to the deployed Analytics hostname and use
this command to create a discovery document. If your workspace already uses
a discovery document, merge the entry into its existing `servers` array.

```sh
jq -n --arg url "https://${GA4_HOST:?}/mcp" '{
  schemaVersion: 1, servers: [{
    id: "google-analytics", name: "Google Analytics 4",
    description: "Read GA4 properties and reports", version: "1.1.0",
    endpoint: {transport: "streamable-http", url: $url},
    auth: {
      type: "oauth", credentialModes: ["per_user"], defaultCredentialMode: "per_user",
      oauthDefaults: {
        authorizationServerUrl: "https://accounts.google.com",
        authorizationEndpoint: "https://accounts.google.com/o/oauth2/v2/auth",
        tokenEndpoint: "https://oauth2.googleapis.com/token",
        scopes: ["https://www.googleapis.com/auth/analytics.readonly"],
        authorizeParams: {access_type: "offline", prompt: "consent select_account"},
        noMetadata: true
      }
    }
  }]
}' > google-analytics-catalog.json
```

Serve the document over HTTPS. Under **Servers → Catalog → Company catalog
sources**, add the source URL and refresh it. Install the offer with its fixed
endpoint and enter the web client's credentials in the Gateway. Keep the
client secret out of the discovery document.
