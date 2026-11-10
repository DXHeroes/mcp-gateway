# Profiles

A **profile** is a named shortlist of tools you hand to one AI client. The AI connects to the
profile and sees nothing outside it.

A connection you add under **Servers** does nothing on its own. It has to sit in a profile first.

**You need:** any role except end user. End users cannot create or edit profiles.

## 1. Create a profile

1. Go to **Profiles**.
2. Click **Create profile**.
3. Give it a name, for example `dev`. The name becomes part of the address, so keep it short and
   lowercase. `gateway` is reserved.
4. Add one or more connections to it.
5. Save.

The profile lives in the workspace you are working in. Switch workspaces and it is not there.

## 2. Choose which tools appear

Open the profile and turn individual tools on or off, rename them, or rewrite their descriptions.
The same connection can look different in two profiles. See
[Tool permissions](./tool-customization.md).

## 3. Connect an AI to it

Every profile has its own address:

```
https://<your-gateway-host>/api/mcp/<workspace-slug>/<profile-name>
```

Paste it into the MCP client (Claude, Cursor and so on). The AI signs in as you the first time. For
a client that cannot sign in interactively, such as a scheduled job, the profile can issue an API
key instead. API keys are an [Enterprise feature](./editions.md).

There is also one fixed address, the same for everyone, that serves each person their own
default profile:

```
https://<your-gateway-host>/api/mcp/gateway
```

Choose your default under **Profiles** → **Gateway endpoint**. The choice is yours alone: it
shares nothing and changes nothing for anyone else. Until you choose, the address serves your
profile named `default`, else your oldest one. It only ever serves a profile you own, never one
shared with you. An administrator can therefore allow this one address in every AI client, and
each person who signs in gets their own profile behind it. To give the whole team one profile,
share it with the workspace and use its own address.

If you belong to several workspaces, use the workspace form
`https://<your-gateway-host>/api/mcp/<workspace-slug>/gateway`, which the Dashboard shows. The
short address names no workspace, so it refuses anyone in more than one.

## How to split them up

One profile with everything in it gives the AI too much to choose from. Split by the job:

- `dev` for coding work
- `business` for messages, documents and calendars
- `research` for reading, with the write tools turned off
- `reporting` for a scheduled job

The names are yours to pick, and a connection can sit in several profiles with a different tool
list in each. A short list means less for the AI to pick wrong from, a profile with no write tools
cannot write by accident, and you can share one without handing over the credentials in the others.

## Share a profile

Only the owner can share a profile. Share it so a colleague can use it without rebuilding it, or
give them Admin level so they can maintain it too.

The owner and everyone it is shared with are told when someone else changes the profile or a
server in it. The change shows in a **Changed by others** card on the profile.

## Delete a profile

Open the profile and delete it. The address stops working immediately and any AI client pointed at
it breaks, so check what is connected first.
