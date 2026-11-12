# Integrators inside one workspace

Enterprise Edition's `managedUsers` feature lets several products use one workspace while
keeping their users, connections and policy separate. It extends managed users under the same
license feature. Managed presets themselves remain available in both editions.

## Prepare and roll out

The operator enables `AUTH_MANAGED_USERS_ENABLED=true` with `WORKSPACE_MODE=single` and keeps
a nonempty `AUTH_MANAGED_USERS_RETURN_URLS` for legacy callers. Upgrade every serving backend
replica before issuing a bound key: older binaries do not understand the binding. Before a
production migration, take a fresh backup, apply it to a copy of real data and compare entity
counts. Repeat the counts after deployment. Local synthetic tests are separate evidence.

An existing user or unbound key stays in the legacy namespace. Upgrading never guesses a
product from a key's creator, assigns existing users to products, rewrites external IDs or
moves credentials. Adopting a bound product requires its users to reconnect; keep an existing
integration available until they do.

## Configure a product

Owners and admins can also keep workspace presets and integrators in a **GatewayConfig v2**
YAML document. Export it with `GET /api/config/export?apiVersion=v2&format=yaml`, review
`POST /api/config/plan`, then pass that plan's `approvalToken` with the same document to
`POST /api/config/apply`. Plans expire after 15 minutes and reject intervening edits. New
products default to disabled; omitted policy is preserved, submitted grant lists replace
the whole list, and v2 never prunes existing products or connections. Personal servers and
profiles continue to use the separate v1 document. Loading a container does not apply YAML.

As a workspace owner or admin, open **Workspace → Integrators** and choose **Add integrator**.
Members and service keys cannot administer integrators.

1. Choose a permanent slug and a display name. The optional logo must be an HTTPS URL without
   credentials or a fragment. Slug and workspace cannot change later.
2. Select English or Czech as the connect page's default language. English is the default and
   fallback. This setting is trusted administrator configuration; SDK requests need no locale.
3. Add complete return URLs, including any query. They match exactly after URL normalization;
   `/return` grants neither `/return/child` nor another query. Local HTTP is allowed only for
   `localhost` and `127.0.0.1`. An empty list permits no new return flow.
4. Select the managed presets the product may use. Grant writes explicitly for each preset
   when needed. An empty list permits no presets. Existing blocked-tool, approval, read-only,
   license and credential rules continue to apply.
5. Save. Concurrent edits require **Reload latest (discard draft)** and a fresh review. The
   API uses a revision and replaces each submitted URL/grant list in full.

Provider OAuth applications, client secrets, upstream endpoints and token forms are configured
once on the workspace's managed presets. Integrators contain grants and presentation settings;
they do not receive provider secrets.

## Create and rotate service keys

In **Management API keys**, select the integrator service-key scope and the enabled integrator.
The dialog requires an explicit product or **Legacy namespace** choice. A key's binding is
permanent. The HTTP creation API retains compatibility: omitted or null `integratorId` means
legacy, so automation for a new product must supply its intended binding explicitly.

Give the key only to the product's backend. Use the product's raw stable external user ID;
another product can use the same value independently. Users, lists, cleanup, attempts,
connections and MCP endpoints are all scoped by the stored key binding. Headers cannot switch
it. Unbound keys can act only for legacy users and bound keys cannot act for legacy users.

For rotation, create another key bound to the **same** integrator, update the product's secret
and revoke the old key. Existing identities, connections and pending attempts survive. A key
still expires or stops working when revoked or when its creator loses the required access.
SDK 1.7.0's public request/response shapes remain supported unchanged; confirmed managed
connections keep `keepAlive=true`.

## Restrict or disable

Removing a preset grant refuses subsequent access to that preset, including the next request
in an already-open MCP session. Removing a write grant refuses subsequent write/destructive
tool calls. Removing a return URL invalidates its pending attempts. Disabling an integrator
invalidates all pending attempts and refuses its service-key requests, including open MCP
sessions. An already-sent upstream operation cannot be undone by a later policy change.

Use **Disable** to suspend a product. There is no delete/rebind operation that turns its users
or keys into legacy access. Disable remains a safety action after license expiry; new
configuration and enable follow the existing license restrictions. Re-enabling restores
access subject to current grants; superseded pending attempts need a new link.

Legacy callers keep the shared workspace catalog, the path-prefix
`AUTH_MANAGED_USERS_RETURN_URLS` allowlist and each preset's legacy `integratorWrites` switch.
Those settings do not grant access to a bound product. The server-side package `@dxheroes/mcp-gateway-sdk` documents the product HTTP flow.
