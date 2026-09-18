---
name: backup-restore
description: Plan and perform a consistent MCP Gateway backup or restore with validation and explicit approval before writing or replacing data.
---

# Back up or restore MCP Gateway

Back up the PostgreSQL database plus the deployment configuration needed to interpret it. Include
Compose/Helm values, installed image digest, Gateway version and edition, encryption-key reference,
`GATEWAY_LICENSE` reference for EE, and externally managed OAuth/SSO configuration references. Never copy
secret values into the report or commit backup material. Database data is unusable without the same
Gateway encryption key, so confirm its protected backup separately.

For backup, inspect database readiness, size, free space, target permissions, retention, and
encryption. Present the exact destination, commands, consistency method, expected size, checksum and
restore test. Wait for approval before creating any file. After approval, produce the dump, restrict
permissions, compute a checksum, and validate it with a disposable database when authorized.

For restore, keep the target stopped from accepting writes. Inspect the archive, checksum, source
version/edition, target version, migration compatibility, target database identity, and rollback copy.
Present every destructive operation and require explicit approval before stopping services, dropping
or overwriting data, or replacing configuration. After approval, preserve the old state, restore,
start the exact compatible image, and confirm readiness, `/api/edition`, login, organizations,
profiles, server catalog, and an authorization denial. Never treat a successful `pg_restore` exit as
full acceptance.
