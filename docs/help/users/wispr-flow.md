# Wispr Flow Notetaker

The **Wispr Flow Notetaker** preset connects the gateway to Wispr Flow's own MCP server, so an AI
can read your meeting summaries, notes, transcripts, attendees and tasks, your scratchpad, and the
calendar events the recordings belong to.

The connection is **read-only**, and it covers the Notetaker only. Your dictation history and your
Notetaker chat history stay out of reach.

There is nothing to register on the Wispr Flow side. The gateway gets its own credentials during
the first sign-in, so you never paste a client ID or a secret anywhere.

**You need:** the owner or admin role in the gateway, a Wispr Flow account with Notetaker and MCP
enabled, and a **Google, Apple, Microsoft or company SSO** sign-in on that account. Wispr Flow
cannot finish MCP sign-in for an account that uses an email and a password. An organization
switches Notetaker, cloud access and MCP on separately, so one being on says nothing about the
others.

## 1. Add the preset

1. **Servers** → **Catalog** → **Community presets** → **Wispr Flow Notetaker** →
   **Add to my servers**.
2. Pick who the connection acts as. See "One account or everyone's own" below. It is easier to
   choose now than to change later.
3. **Create server**, then add it to a [profile](./profiles.md). Nothing can reach the
   connection until it sits in one.

## 2. Sign in to Wispr Flow

1. Open the server and click **Authorize**.
2. Sign in with your SSO provider and approve the request.

Sign-in covers the whole account, and the connection reaches only what that account can already
open.

If you chose everyone's own account, each person does this for themselves under
**My connections**. See [Service credentials](./per-user-connections.md).

## One account or everyone's own

Wispr Flow always reads as the person who signed in.

- **Shared** (what the preset starts with): one account for the whole organization. Everyone who
  asks the AI sees that account's meetings and scratchpad.
- **Per-user**: each person signs in with their own account and sees only their own.

A transcript and a personal scratchpad are rarely meant for a whole company, so choose per-user
unless you have a reason not to. Changing this later works, but it disconnects the existing
account and everyone reconnects.

## What the AI cannot reach

- Dictation history and Notetaker chat history.
- Transcripts of meetings you were not invited to, and transcripts your organization does not
  allow to be shared.
- Transcripts and audio that are past the retention window. Wispr Flow deletes those and keeps the
  summaries, so an old meeting can come back with a summary and no transcript.
- Anything at all, if a HIPAA agreement covers the account or the organization. That blocks
  meeting, calendar and account data.

Search looks at titles, summaries and notes, not at the words in a transcript. Filtering by
attendee works only for recordings linked to a calendar event.

## Tool permissions

Every tool here only reads, so they all start on **Allow**. Review them under
[Tool permissions](./tool-customization.md) before people start using the server, and turn the
transcript tools off for a profile that should see summaries only.

## Troubleshooting

| Problem | What it means |
| --- | --- |
| Sign-in never finishes | The account uses an email and a password. Link Google, Apple, Microsoft or company SSO and try again. |
| Sign-in is refused | MCP or Notetaker is off for the organization. An admin turns each on separately. |
| A meeting has a summary but no transcript | The transcript is past the retention window, or you have no access to it. |
| Search finds nothing for something that was said | Search covers titles, summaries and notes, not the transcript text. |
| Someone sees meetings that are not theirs | The connection is shared. Switch to per-user and have everyone reconnect. |

## More from Wispr Flow

[Connect an MCP client](https://docs.wisprflow.ai/articles/9551372685-connect-an-mcp-client-to-wispr-flow-remote-mcp-server)
