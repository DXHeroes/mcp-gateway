# Google Workspace

Eight presets (Gmail, Drive, Calendar, Docs, Sheets, Slides, Chat and People) connect the gateway
to Google's official Workspace MCP servers. One Google Cloud project and one dedicated MCP OAuth
client cover all eight.

> **Google calls this a Developer Preview.** Your project has to be enrolled in the
> [Workspace Developer Preview Program](https://developers.google.com/workspace/preview) before
> any tool works. Apply with a Workspace account; Education accounts can apply too.

**You need:** a Google Workspace account for Developer Preview enrolment, admin access to a
Google Cloud project, and the owner or admin role in the gateway.

Personal `@gmail.com` and Workspace test accounts have passed tool listing and read calls for
**Calendar and People** through managed presets. Gmail and Drive remain unverified in this test.
See [verified service coverage](#verified-service-coverage). External audience or successful
consent alone does not establish MCP service admission or tool coverage.

Developer Preview is for testing. Under the [program terms](https://developers.google.com/workspace/preview#developer_preview_program_terms),
do not grant access to users outside your domain or company before general availability unless
Google has granted the applicable permission for that feature. An External OAuth audience does
not remove this program restriction.

---

## 1. Enrol the project

In the [Workspace Developer Preview Program](https://developers.google.com/workspace/preview):

1. Review and accept the terms, then submit the form with your individual Workspace email
   and **Google Cloud project number**, not just its project ID. Gmail addresses, service
   accounts and Google Groups cannot be the applicant.
2. Allow your account to be added to the program's Google Group and watch for verification
   messages. Google must verify the account and register the project.
3. Wait for the confirmation email. Google says it takes a couple of days. Enabling APIs
   alone does not enroll the project.

Enrolment covers the whole project, not one product at a time.

## 2. Turn on the APIs and MCP services

In **APIs & Services** → **Enable APIs and services**, enable both the standard APIs and
MCP services for your presets in the same Google Cloud project. The
[Google setup guide](https://developers.google.com/workspace/guides/configure-mcp-servers)
requires both steps; enabling a standard API alone does not enable its separate MCP service.

| Preset | Standard API service ID | MCP service ID |
| --- | --- | --- |
| Gmail | `gmail.googleapis.com` | `gmailmcp.googleapis.com` |
| Google Drive | `drive.googleapis.com` | `drivemcp.googleapis.com` |
| Google Calendar | `calendar-json.googleapis.com` | `calendarmcp.googleapis.com` |
| Google Docs | `docs.googleapis.com` | `docsmcp.googleapis.com` |
| Google Sheets | `sheets.googleapis.com` | `sheetsmcp.googleapis.com` |
| Google Slides | `slides.googleapis.com` | `slidesmcp.googleapis.com` |
| Google Chat | `chat.googleapis.com` | `chatmcp.googleapis.com` |
| Google People | `people.googleapis.com` | `people.googleapis.com` (same service) |

Docs, Sheets and Slides also need the standard Drive API (`drive.googleapis.com`) to access
files. People uses the same service ID for both steps, so enable it once.

## 3. Set up the OAuth client

1. **Google Auth Platform → Audience**: use **Internal** for your organization only.
   For outside users, select **External**; in Testing, add authorized test users. Check
   [verification requirements](https://support.google.com/cloud/answer/13463073) before public use.
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
4. Select **Use this client for an AI-powered agent** in **Google Auth Platform → Clients**.
   Use a separate MCP client if the existing one also handles sign-in or direct API features
   ([Google client isolation guidance](https://support.google.com/cloud/answer/15549257)).
5. Store the **Client ID** and **Client secret** securely and enter them in the preset.
   Keep secrets out of source control and issue comments.

### Scope classes for Gmail, Drive, Calendar and People

The four presets above use these classes (checked on 7 November 2026). All scope names below
have the prefix `https://www.googleapis.com/auth/`.

| Class | Scopes |
| --- | --- |
| Non-sensitive | `drive.file`, `calendar.calendarlist.readonly`, `calendar.events.freebusy`, `userinfo.profile` |
| Sensitive | `calendar.events.readonly`, `contacts.readonly`, `directory.readonly` |
| Restricted | `gmail.modify`, `gmail.compose`, `drive.readonly` |

Check the labels in **Google Auth Platform → Data Access** for your own project and for any
other scopes you add. Google's [scope reference](https://developers.google.com/identity/protocols/oauth2/scopes)
identifies that page as the source of sensitive-scope indicators. The [Gmail](https://developers.google.com/workspace/gmail/api/auth/scopes)
and [Drive](https://developers.google.com/workspace/drive/api/guides/api-specific-auth) guides
list their restricted scopes. Complete the applicable verification before public use; Google
also requires a security assessment when restricted-scope data is stored or transmitted on
servers. The scope class is separate from Developer Preview eligibility.

Google will reject unmarked Workspace MCP clients from **11 November 2026**. Existing clients
not marked by **12 November 2026** require replacement with a new agentic client. If the setting
cannot be changed, create a replacement and reconnect affected accounts.
[Google announcement](https://developers.google.com/workspace/docs/release-notes#october_12_2026).

## 4. Install a preset

1. **Servers** → **Catalog** → **Community presets** → pick the server → **Add to my servers**.
2. Paste the same client ID and secret into every community preset you install. These
   installations each store their own client configuration.
3. Choose the credential mode. **Per-user** means each person reaches their own mail, calendar or
   files. See [Service credentials](./per-user-connections.md).
4. **Create server**, then **Authorize**. In per-user mode each person authorizes themselves under
   **My connections** instead.

A workspace owner or admin can instead prepare a **managed preset** that holds the OAuth
client configuration centrally. Members still authorize their own accounts; their connections
read the client configuration from the managed preset.

---

## Verified service coverage

Tests on **8 November 2026** used a dedicated agentic client in an enrolled project, managed
presets on the released gateway, and actual MCP calls with each account's own credential:

| Service | Personal Gmail | Workspace | Observed tool coverage |
| --- | --- | --- | --- |
| Calendar | Tool listing and reads passed | Tool listing and reads passed | 9 tools; calendar/event listing and availability queries succeeded |
| People | Profile and contact search passed | Profile read and empty contact search passed | 3 read-only tools: profile, contact search and directory search |
| Gmail | Not tested | Not tested | No service verdict from this test |
| Drive | Not tested | Not tested | No service verdict from this test |

The personal contact search returned a contact; the empty Workspace search did not. Directory
access was not granted to the personal account or tested there. A personal profile response can
omit its email address; that alone is not a failed connection or proof of account isolation.

Calendar's listed tools include event creation, updates and deletion. The default preset's
scopes cover reads. To use event writes, add `https://www.googleapis.com/auth/calendar.events`
to the consent configuration and the managed preset, then authorize the account again
([Google's write-scope reference](https://developers.google.com/workspace/calendar/api/v3/reference/mcp/tools_list/create_event#authorization_scopes)).
Listing a write tool does not prove that the token can execute it. Gateway tool approval is a
separate gate: an expired request for human approval did not execute a provider write in this
test. Event writes and their readback remain unverified.

These observations do not establish public app availability, every tenant's consent policy,
complete account isolation or token revocation/reconnect behavior. Developer Preview terms
and OAuth verification requirements still apply.

## Troubleshooting

| Problem | What it means |
| --- | --- |
| Tools appear, but every call says the project is not enrolled | Step 1 is still pending. Everything else is fine, so don't go re-checking your OAuth setup. |
| The connection returns nothing | Check project enrolment, enabled APIs and MCP services, consent and the provider error in traces. An empty result alone does not identify the cause. |
| `redirect_uri_mismatch` | The redirect URI in Google Cloud does not exactly match `https://<gateway>/api/oauth/callback`. |
| Workspace MCP rejects the OAuth client | Check the AI-agent setting in **Google Auth Platform → Clients**; replace the client if it cannot be marked. |
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
