# Google Workspace

Eight presets (Gmail, Drive, Calendar, Docs, Sheets, Slides, Chat and People) connect the gateway
to Google's official Workspace MCP servers. One Google Cloud project and one OAuth client cover
all eight.

> **Google calls this a Developer Preview.** Your project has to be enrolled in the
> [Workspace Developer Preview Program](https://developers.google.com/workspace/preview) before
> any tool works. Any Workspace account qualifies, including Education.

**You need:** a Google Workspace account (not a personal `@gmail.com` one), admin access to a
Google Cloud project, and the owner or admin role in the gateway.

---

## 1. Enrol the project

In the [Workspace Developer Preview Program](https://developers.google.com/workspace/preview):

1. Accept the terms and submit the form with your Workspace account and Cloud project.
2. Accept the Google Group invitation they email you. If your address rejects group mail, the
   request stalls with no warning.
3. Wait for the confirmation email. Google says it takes a couple of days.

Enrolment covers the whole project, not one product at a time.

## 2. Turn on the APIs

Go to **APIs & Services** → **Enable APIs and services**. Each product needs **two** APIs, the
normal one and its MCP counterpart. Enabling only one is the most common reason a connection comes
back empty.

| Preset | Enable |
| --- | --- |
| Gmail | Gmail API + **Gmail MCP API** |
| Google Drive | Drive API + **Drive MCP API** |
| Google Calendar | Calendar API + **Calendar MCP API** |
| Google Docs | Docs API + **Docs MCP API** + Drive API |
| Google Sheets | Sheets API + **Sheets MCP API** + Drive API |
| Google Slides | Slides API + **Slides MCP API** + Drive API |
| Google Chat | Chat API + **Chat MCP API** |
| Google People | People API only |

Docs, Sheets and Slides open their files through Drive, which is why they need it too. People is
the one product with no separate MCP API.

## 3. Set up the OAuth client

1. **OAuth consent screen** → user type **Internal**. Choosing **External** means Google has to
   [verify your app](https://support.google.com/cloud/answer/13463073) first.
2. Add the scopes for the presets you plan to install. Scopes are the permissions Google grants.
   Every one below starts with `https://www.googleapis.com/auth/`.

   | Preset | Scopes |
   | --- | --- |
   | Gmail | `gmail.modify`, `gmail.compose` |
   | Google Drive | `drive.readonly`, `drive.file` |
   | Google Calendar | `calendar.calendarlist.readonly`, `calendar.events.freebusy`, `calendar.events.readonly` |
   | Google Docs | `drive.readonly`, `drive.file`, `documents.readonly`, `documents` |
   | Google Sheets | `drive.readonly`, `drive.file`, `spreadsheets.readonly`, `spreadsheets` |
   | Google Slides | `drive.readonly`, `drive.file`, `presentations.readonly`, `presentations` |
   | Google Chat | `chat.spaces.readonly`, `chat.memberships.readonly`, `chat.messages.readonly`, `chat.messages.create`, `chat.users.readstate` |
   | Google People | `directory.readonly`, `userinfo.profile`, `contacts.readonly` |

   Gmail asks for `gmail.modify` rather than read-only because read-only cannot label, archive or
   trash a message.
3. **Credentials** → **Create credentials** → **OAuth client ID** → **Web application**. Under
   authorized redirect URIs add `https://<your-gateway-host>/api/oauth/callback`, exactly, with no
   trailing slash.
4. Copy the **Client ID** and **Client secret**.

## 4. Install a preset

1. **Servers** → **Catalog** → **Community presets** → pick the server → **Add to my servers**.
2. Paste the same client ID and secret into every preset you install. Each one keeps its own copy.
3. Choose the credential mode. **Per-user** means each person reaches their own mail, calendar or
   files. See [Service credentials](./per-user-connections.md).
4. **Create server**, then **Authorize**. In per-user mode each person authorizes themselves under
   **My connections** instead.

---

## Troubleshooting

| Problem | What it means |
| --- | --- |
| Tools appear, but every call says the project is not enrolled | Step 1 is still pending. Everything else is fine, so don't go re-checking your OAuth setup. |
| The connection returns nothing | Only one of the two APIs is on. See step 2. |
| `redirect_uri_mismatch` | The redirect URI in Google Cloud does not exactly match `https://<gateway>/api/oauth/callback`. |
| `access_denied` on the Google approval screen | That scope is not listed on your consent screen. |
| An error that goes away when you retry | Google occasionally rejects a request that is otherwise fine. |
| It works for an hour, then stops | The refresh token is missing. The preset asks for one automatically, so put the authorize settings back if you changed them. |

> **No Google Cloud project?** The community-run
> [`google_workspace_mcp`](https://github.com/taylorwilsdon/google_workspace_mcp) server registers
> itself, so it installs without a client ID. You host and maintain it yourself.

## More from Google

[Configure Workspace MCP servers](https://developers.google.com/workspace/guides/configure-mcp-servers) ·
[OAuth 2.0 for web server apps](https://developers.google.com/identity/protocols/oauth2/web-server) ·
[OAuth scopes](https://developers.google.com/identity/protocols/oauth2/scopes)
