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

The profile lives in the organization you are working in. Switch organizations and it is not there.

## 2. Choose which tools appear

Open the profile and turn individual tools on or off, rename them, or rewrite their descriptions.
The same connection can look different in two profiles. See
[Tool permissions](./tool-customization.md).

## 3. Connect an AI to it

Every profile has its own address:

```
https://<your-gateway-host>/api/mcp/<org-slug>/<profile-name>
```

Paste it into the MCP client (Claude, Cursor and so on). The AI signs in as you the first time. For
a client that cannot sign in interactively, such as a scheduled job, the profile can issue an API
key instead. API keys are an [Enterprise feature](./editions.md).

There is also one fixed address that always points at whichever profile is marked as default:

```
https://<your-gateway-host>/api/mcp/gateway
```

Set the default under **Profiles** → **Gateway endpoint**. Marking a profile as default shares it
with the whole organization, and everyone calling this address uses that profile's stored
credentials. Pick one you are happy to hand to every member.

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

## Delete a profile

Open the profile and delete it. The address stops working immediately and any AI client pointed at
it breaks, so check what is connected first.
