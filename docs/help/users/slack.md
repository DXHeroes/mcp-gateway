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
4. **Create server**, then assign it to a profile.

Everyone now connects their own Slack account under **My connections**. See
[Service credentials](./per-user-connections.md).

---

## B. REST API (OpenAPI)

Talks to the [Slack Web API](https://docs.slack.dev/apis/web-api/) directly, as one bot for the
whole organization. This route is for developers: you have to supply the API description yourself.

**You need:** the organization owner role in the gateway, and an OpenAPI 3.x document describing
the Slack methods you want to use.

### 1. Get the bot token

In [api.slack.com/apps](https://api.slack.com/apps), on the same app or a new one:

1. **OAuth & Permissions** → **Bot Token Scopes**: add a scope for each thing the bot should do
   (`chat:write` to post messages, `channels:read` to list channels, and so on).
2. **Install App** → **Install to Workspace**.
3. Copy the **Bot User OAuth Token**. It starts with `xoxb-`.
4. In Slack, invite the bot to every channel it should work in. It cannot see anything else.

### 2. Prepare a spec

Slack's published [`slack-api-specs`](https://github.com/slackapi/slack-api-specs) is archived and
uses an older format, so it cannot be imported as it is. Write a small OpenAPI 3.x document
covering only the methods you need. The names and descriptions you put in it are what the AI
reads, so make them clear.

### 3. Create the connection

1. **Servers** → **Add server** → **Advanced, for developers** → type **REST API (OpenAPI)**.
2. Paste the spec or give a URL, click **Load spec**, then pick the operations to expose.
3. Base URL: `https://slack.com/api/`
4. Auth: an **API key** in a header, name `Authorization`, value `Bearer xoxb-your-token`.
5. Save, then assign the server to a profile.

### Good to know

- **A failed call can still look successful.** Slack reports errors inside the response instead of
  as an error code, so describe the `ok` and `error` fields in your spec.
- **No file uploads.** Only methods that accept plain JSON work.
- **Most tools start on "Needs approval".** Slack uses POST for nearly everything, including
  reads, and the gateway treats POST as a write. Change this under
  [Tool permissions](./tool-customization.md).

---

## Troubleshooting

| Problem | What it means |
| --- | --- |
| `bad_redirect_uri` | The redirect URL in Slack does not exactly match `https://<gateway>/api/oauth/callback`. |
| `invalid_scope` | One of the user token scopes is missing. |
| The Slack approval page is blank | The app has no bot scope. See step 1. |
| Slack says it is waiting for approval | Normal if your workspace restricts apps. An admin approves it once. |
| A bot token is rejected by the preset | Expected. The preset only takes personal accounts; use route B. |
| `missing_scope` on route B | The bot token is missing a scope. Add it and reinstall the app. |
| `channel_not_found` or `not_in_channel` | The bot was never invited to that channel. |
| Calls look fine but nothing happens | Slack reported an error inside the response. See "Good to know". |

## More from Slack

[Slack MCP server](https://docs.slack.dev/ai/slack-mcp-server/) ·
[Web API](https://docs.slack.dev/apis/web-api/) ·
[Installing with OAuth](https://docs.slack.dev/authentication/installing-with-oauth) ·
[Permission scopes](https://docs.slack.dev/reference/scopes)
