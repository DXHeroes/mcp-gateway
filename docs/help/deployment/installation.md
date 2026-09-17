# Install DXH Gateway

CE runs one active gateway with PostgreSQL. Check out a signed public release and verify its
`release.json`. Copy `.env.example` to `.env`, generate two independent random secrets with at least
32 random bytes, set the public URL, and set `GATEWAY_IMAGE` to the exact
`ghcr.io/dxheroes/mcp-gateway-ce@sha256:…` value. Read `LICENSE-CE.txt`. An administrator confirms
version `2026-09-17.1` with `GATEWAY_CE_TERMS_ACCEPTED` and selects `production` (eligible company
with at most 50 employees including affiliates) or `evaluation` (nonproduction) using
`GATEWAY_CE_USE`. No online activation is used.

Run `docker compose config`, `docker compose pull`, then `docker compose up -d --wait`. The image
applies database migrations before starting. Open the public URL, register the first owner, then set
`AUTH_SIGNUP_MODE=invite_only` and restart. Keep the encryption key and database backups together in
protected storage. Follow your infrastructure's TLS and backup procedures. The supplied Compose
binding is loopback-only; use a TLS reverse proxy for network access.

For Kubernetes use the supplied Helm chart. Set `edition=ce`, `replicaCount=1`, an existing Secret with database URL and both secrets, the terms variables, and your image digest. CE uses `Recreate` so upgrades stop the previous pod before starting its replacement. A database session lock also refuses a second active process; CE upgrades can have downtime.

For EE obtain the EE image and a signed license from DX Heroes. Mount the directory containing the license read-only and set `GATEWAY_LICENSE_FILE` to that file. Replace it atomically to renew; the API/UI observes it without losing data. Do not rename a CE image or set an environment flag to unlock EE; CE does not contain the EE implementation.

CE to EE uses the same database and encryption key. Before updating an existing installation arrange an appropriate paid/trial license (unlimited agreements use a null seat limit). Before an EE to CE downgrade, back up and run the CE compatibility check on a restored copy. CE startup refuses incompatible configuration or history. No automatic data deletion or permission widening is performed.

Multiple EE replicas require routing and database configuration appropriate to the deployed transport; legacy sessions are process-local. HA claims apply only to release images with published operational and load-test evidence.
