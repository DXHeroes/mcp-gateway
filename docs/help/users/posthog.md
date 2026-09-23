# PostHog

The **PostHog** preset connects the gateway to PostHog's own MCP server, so an AI can query your
analytics, read and change feature flags and experiments, and work with error tracking and
surveys.

There is nothing to register on the PostHog side. PostHog hands the gateway its own credentials
during the first sign-in, so you never paste a client ID or a secret anywhere.

**You need:** the owner or admin role in the gateway, and a PostHog Cloud account with access to
the project.

## 1. Add the preset

1. **Servers** → **Catalog** → **Community presets** → **PostHog** → **Add to my servers**.
2. Pick who the connection acts as. See "One account or everyone's own" below. It is easier to
   choose now than to change later.
3. **Create server**, then add it to a [profile](./profiles.md). Nothing can reach the
   connection until it sits in one.

## 2. Sign in to PostHog

1. Open the server and click **Authorize**.
2. Sign in to PostHog and approve.

PostHog sends the connection to the region of the account that signs in, US or EU. You do not set
the region anywhere. If your company uses both, make one connection per region.

If you chose everyone's own account, each person does this for themselves under
**My connections**. See [Service credentials](./per-user-connections.md).

## Pinning it to one project

By default the AI gets tools for switching organization and project, and it may switch on its own
in the middle of a conversation. To stop that, add two custom headers on the connection:

| Header | Value |
| --- | --- |
| `x-posthog-organization-id` | The organization's ID |
| `x-posthog-project-id` | The project's ID |

Once the project is pinned, the switching tools disappear and every question lands in that
project. Both headers say which project, not who you are, so they keep working in per-user mode
as well.

## One account or everyone's own

PostHog always acts as the person who signed in.

- **Shared** (what the preset starts with): one account for the whole organization. Everyone reads
  and writes as that account, and a feature flag changed through the gateway carries its name in
  PostHog's activity log.
- **Per-user**: each person signs in with their own PostHog account and reaches their own
  projects.

Changing a feature flag changes what real users see, so per-user is worth it if you leave any
writing tool on **Allow**. Changing this later works, but it disconnects the existing account.

## Tool permissions

This server writes as well as reads. It can create and switch feature flags, edit experiments,
insights and dashboards, and manage surveys. New servers start with the reading tools on **Allow**
and the writing ones on **Needs approval**. Review them under
[Tool permissions](./tool-customization.md) before people start using the server, and keep
approval on the feature flag tools.

## Troubleshooting

| Problem | What it means |
| --- | --- |
| Answers come from the wrong project | No project is pinned and the AI switched. Add the two headers above. |
| No data at all | The account that signed in lives in the other region. Sign in again with the right one. |
| A flag changed and nobody noticed | A writing tool is on **Allow**. Move it to **Needs approval**. |
| Changes show the wrong name | The connection is shared. Switch to per-user and have everyone reconnect. |

## More from PostHog

[Model Context Protocol](https://posthog.com/docs/model-context-protocol) ·
[Tools reference](https://posthog.com/docs/model-context-protocol/tools)
