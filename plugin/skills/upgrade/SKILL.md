---
name: upgrade
description: Prepare a digest-pinned MCP Gateway upgrade with verification, backup, migration checks, approval, and rollback.
---

# Upgrade MCP Gateway

Read the installed `/api/edition` snapshot, Compose configuration, exact running image digest,
database version, available disk, current health, and latest approved `release.json`. Verify the new
digest has the host platform, matches the requested version, and has the expected Cosign identity,
SBOM, provenance, source revision, edition, and terms version. Reject mutable tags and cross-edition
replacement. Never infer that a pulled image has been deployed.

Create a consistent database backup and configuration backup before replacement. The preflight may
inspect commands and destinations, but writing the backup requires approval. Present the current and
target digests, release notes, migration path, estimated interruption, backup destination and check,
exact Compose diff, health/acceptance checks, and rollback procedure. Wait for explicit approval of
that plan before backing up, pulling, migrating, or restarting.

After approval, verify the backup, pull the exact digest, update only `GATEWAY_IMAGE`, render Compose,
and replace the Gateway. The image entrypoint performs schema and data migrations before startup.
Confirm readiness, `/api/edition` version/edition, login, one profile discovery, catalog display, and
an expected authorization denial. Roll back only when migrations are documented as compatible;
otherwise restore the paired backup using the backup/restore skill. Report observed runtime evidence,
not only successful Compose output.
