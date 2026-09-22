# Context7

The **Context7** preset connects the gateway to Context7's own MCP server, which looks up current
documentation and code examples for public libraries. An AI then answers from today's docs instead
of whatever it was trained on.

It has two tools. One turns a library name into a Context7 ID, the other fetches documentation for
that ID. Both only read, and neither touches anything of yours.

**This is the one preset with nothing to sign in to.** The server answers without an account, so
there is no token and no login step. Everything below is optional.

**You need:** the owner or admin role in the gateway.

## Add the preset

1. **Servers** → **Catalog** → **Community presets** → **Context7** → **Add to my servers**.
2. **Create server**, then add it to a [profile](./profiles.md). Nothing can reach the
   connection until it sits in one.

That is the whole setup. The tools show up straight away.

## Adding an API key

Without an account there is a limit on how much you can look up. A key from the
[Context7 dashboard](https://context7.com/dashboard) raises it and opens private repositories
indexed on your account.

To add one, edit the connection, switch it to an API key and fill in:

| Field | Value |
| --- | --- |
| Header name | `Authorization` |
| Header value | `Bearer YOUR_API_KEY` |

A key belongs to an account, so everyone can use their own if they have one. For looking up public
documentation that is rarely worth the setup. See [Service credentials](./per-user-connections.md).

## Tool permissions

Both tools read public documentation, so both start on **Allow** and there is nothing to restrict.
See [Tool permissions](./tool-customization.md).

## Troubleshooting

| Problem | What it means |
| --- | --- |
| Lookups start failing after heavy use | You hit the limit for accounts without a key. Add one. |
| A library is not found | It is not indexed. Try the exact package name, or the `/org/project` ID. |
| The docs describe the wrong version | Say the version in the question, or use a version-specific library ID. |
| A private repository is invisible | It is indexed under an account, so the connection needs that account's key. |

## More from Context7

[Documentation](https://context7.com/docs) · [GitHub](https://github.com/upstash/context7)
