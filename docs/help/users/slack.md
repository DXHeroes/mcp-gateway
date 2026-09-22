# Slack

There are two ways to connect Slack. Pick one before you start.

| | **A. Community preset** | **B. REST API (OpenAPI)** |
| --- | --- | --- |
| Acts as | Each person, as themselves | One bot account |
| Can see | What that person sees in Slack | Only channels the bot is invited to |
| Setup | Clicking through Slack's settings | Needs a developer to write an API spec |
| Best for | People using Slack through their AI | Automation and scheduled jobs |

Most setups want **A**. Pick **B** only if you need Slack messages to come from a bot rather than
from a person, because [Slack's MCP server](https://docs.slack.dev/ai/slack-mcp-server/) only
works with personal accounts. In CE you can save one REST/OpenAPI connection, and only an
organization owner can create it.

---

## A. Community preset

Everyone connects their own Slack account, and the AI sees exactly what they see.

**You need:** the owner or admin role in the gateway, and someone who can create a Slack app and
get it approved for your workspace.

### 1. Create the Slack app

Go to [api.slack.com/apps](https://api.slack.com/apps)
([Slack's own guide](https://docs.slack.dev/quickstart)):

1. **Create New App** → **From scratch**. Give it a name and pick your workspace.
2. Open **Agents & AI Apps** and turn on **Model Context Protocol**.
3. Open **OAuth & Permissions**, turn on **PKCE**, and under **Redirect URLs** add
   `https://<your-gateway-host>/api/oauth/callback`. Copy it exactly, with no trailing slash.
4. On the same page, add any one scope under **Bot Token Scopes**. Slack only shows the approval
   screen for apps that have a bot, so without this the login page comes up empty. Nothing else
   uses it.

### 2. Add the user token scopes

Scopes are the permissions Slack grants. Under **OAuth & Permissions** → **User Token Scopes**,
add these:

```
search:read.public     channels:history    im:history      chat:write
search:read.private    channels:read       im:read         reactions:write
search:read.im         groups:history      mpim:history    files:read
search:read.mpim       groups:read         mpim:read       emoji:read
search:read.users      users:read          users:read.email
```

If one is missing, connecting fails with `invalid_scope`. See
[Slack permission scopes](https://docs.slack.dev/reference/scopes).

### 3. Install the app

1. **Install App** → **Install to Workspace**. A workspace admin may need to approve this.
2. Go to **Basic Information** → **App Credentials** and copy the **Client ID** and
   **Client Secret**.

### 4. Add the preset in the gateway

1. **Servers** → **Catalog** → **Community presets** → **Slack** → **Add to my servers**.
2. Paste the client ID and client secret.
3. Leave the credential mode on **per-user**.
4. **Create server**, then add it to a [profile](./profiles.md).

Everyone now connects their own Slack account under **My connections**. See
[Service credentials](./per-user-connections.md).

---

## B. REST API (OpenAPI)

Talks to the [Slack Web API](https://docs.slack.dev/apis/web-api/) directly, as one bot for the
whole organization. This route is for developers: you supply the API description yourself.

**You need:** the organization owner role in the gateway, and an OpenAPI 3.x document describing
the Slack methods you want to use. Slack's published
[`slack-api-specs`](https://github.com/slackapi/slack-api-specs) is archived and uses an older
format, so write a small document covering only the methods you need. The names and descriptions
you put in it are what the AI reads, so make them clear.

### 1. Get the bot token

In [api.slack.com/apps](https://api.slack.com/apps), on the same app or a new one:

1. **OAuth & Permissions** → **Bot Token Scopes**: add a scope for each thing the bot should do
   (`chat:write` to post messages, `channels:read` to list channels).
2. **Install App** → **Install to Workspace**.
3. Copy the **Bot User OAuth Token**. It starts with `xoxb-`.
4. In Slack, invite the bot to every channel it should work in. It cannot see anything else.

### 2. Create the connection

1. **Servers** → **Add server** → **Advanced, for developers** → type **REST API (OpenAPI)**.
2. Paste the spec or give a URL, click **Load spec**, then pick the operations to expose.
3. Base URL: `https://slack.com/api/`
4. Auth: an **API key** in a header, name `Authorization`, value `Bearer xoxb-your-token`.
5. **Create server**.

### 3. Set it up for autonomous runs

A scheduled job has nobody to ask, so approvals have to be gone before it runs.

1. **Profiles** → [create a profile](./profiles.md), or open an existing one,
   and add the Slack server to it.
2. Open the server on the profile page and set every tool the job will use to **Allow**.
3. Turn off **Ask user (Claude)** on those tools. Left on, the run stops and waits.
4. In the profile's **API Keys** panel, **Generate key** and copy the secret. It starts with
   `mcp_api_` and is shown only once. API keys are an [Enterprise feature](./editions.md).

### 4. Give the key to the job

Put the address and the key in the job's MCP client config. Keep the key in a CI secret, a
`.env` file or your password manager, never in the repository.

```
URL:    https://<your-gateway-host>/api/mcp/<org-slug>/<profile-name>
Header: Authorization: Bearer mcp_api_…
```

### Good to know

- **A failed call can still look successful.** Slack reports errors inside the response instead of
  as an error code, so describe the `ok` and `error` fields in your spec.
- **No file uploads.** Only methods that accept plain JSON work.
- **Most tools start on "Needs approval".** Slack uses POST for nearly everything, including
  reads, and the gateway treats POST as a write.

---

## Troubleshooting

| Route | Problem | What it means |
| --- | --- | --- |
| A | `bad_redirect_uri` | The redirect URL in Slack does not exactly match `https://<gateway>/api/oauth/callback`. |
| A | `invalid_scope` | One of the user token scopes is missing. |
| A | The Slack approval page is blank | The app has no bot scope. See step 1. |
| A | Slack says it is waiting for approval | Normal if your workspace restricts apps. An admin approves it once. |
| A | A bot token is rejected by the preset | Expected. The preset only takes personal accounts; use route B. |
| B | `not_authed` or `invalid_auth` | The header is missing or malformed. It has to be `Authorization: Bearer xoxb-…`. |
| B | `missing_scope` | The bot token is missing a scope. Add it and reinstall the app. |
| B | `channel_not_found` or `not_in_channel` | The bot was never invited to that channel. |
| B | Calls look fine but nothing happens | Slack reported an error inside the response. See "Good to know". |
| B | The gateway answers `401` | The key expired, was deleted, or belongs to a different profile. |
| B | A call waits forever | The tool is still on **Needs approval**, or **Ask user (Claude)** is on. |

## More from Slack

[Slack MCP server](https://docs.slack.dev/ai/slack-mcp-server/) ·
[Web API](https://docs.slack.dev/apis/web-api/) ·
[Installing with OAuth](https://docs.slack.dev/authentication/installing-with-oauth) ·
[Permission scopes](https://docs.slack.dev/reference/scopes)
