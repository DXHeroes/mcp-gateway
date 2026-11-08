# Service credentials

Both editions support shared credentials and per-user credentials for capable connections. In per-user mode each person connects their own account from My Connections. A person's credential is not shared with other members. Built-in connectors that accept a key support per-user tokens; remote services may use OAuth.

Upstream API keys and OAuth are available in CE. They authenticate the gateway to a service and are different from the EE profile API keys used by clients to access the gateway.

Renew or revoke credentials when needed. Credential recovery remains available after an EE license's grace period ends.

## Managed connector access

A workspace owner or admin can edit a managed preset from the Catalog. For a connector offer,
**Connector access** holds the token used by the gateway to access that connector. Each member
still connects their own provider account; the connector token does not replace it.

The stored token is never shown. Choose **Keep**, **Replace** or **Clear**. Existing connections
use a replacement on their next call, including on another gateway instance. Clearing it sends
no connector bearer; a connector that requires one will refuse calls until access is restored.
This credential recovery remains available after the EE license grace period ends.
