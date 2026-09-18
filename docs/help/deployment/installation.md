# Install DXH Gateway

CE runs one active gateway with PostgreSQL. The quick start in the repository README is the
shortest path: it downloads `compose.yaml`, writes `.env` with generated secrets and the terms
acceptance, and starts the release image named in `compose.yaml`. For a production installation:

Read `LICENSE-CE.txt`. The administrator accepts it by setting `GATEWAY_CE_TERMS_ACCEPTED` to the
version it names, `2026-09-18.1`. Accepting the terms confirms the use is eligible: production in a
company with at most 50 employees including affiliates, or nonproduction evaluation at any company
size. There is no separate purpose setting and no online activation.

Check out a signed public release and verify its `release.json`. Copy `.env.example` to `.env`,
generate `POSTGRES_PASSWORD` as hex (it becomes part of the database URL) and `BETTER_AUTH_SECRET`
and `GATEWAY_ENCRYPTION_KEY` as independent secrets with at least 32 random bytes each, set
`PUBLIC_URL`, and pin `GATEWAY_IMAGE` to the verified digest, for example
`docker.io/dxheroes/mcp-gateway-ce@sha256:…` or `ghcr.io/dxheroes/mcp-gateway-ce@sha256:…`.

Run `docker compose config`, `docker compose pull`, then `docker compose up -d --wait`. The image
applies database migrations before starting. Open the public URL, register the first owner, then set
`AUTH_SIGNUP_MODE=invite_only` and restart. Keep the encryption key and database backups together in
protected storage. Follow your infrastructure's TLS and backup procedures. The supplied Compose
binding is loopback-only; use a TLS reverse proxy for network access.

For Kubernetes use the supplied Helm chart. Set `edition=ce`, `replicaCount=1`, an existing Secret with database URL and both secrets, `config.ceTermsAccepted`, and your image digest. CE uses `Recreate` so upgrades stop the previous pod before starting its replacement. A database session lock also refuses a second active process; CE upgrades can have downtime.

For EE obtain the EE image and a signed license from DX Heroes. Set `GATEWAY_LICENSE` either to the license content or to the path of the license file, with the directory containing it mounted read-only. To renew a file, replace it atomically; the API/UI observes it without a restart or data loss. To renew inline content, update the variable and restart. `GATEWAY_LICENSE_FILE` was removed in 0.4.0, and an EE gateway that still sets only that name refuses to start. Do not rename a CE image or set an environment flag to unlock EE; CE does not contain the EE implementation.

CE to EE uses the same database and encryption key. Before updating an existing installation arrange an appropriate paid/trial license (unlimited agreements use a null seat limit). Before an EE to CE downgrade, back up and run the CE compatibility check on a restored copy. CE startup refuses incompatible configuration or history. No automatic data deletion or permission widening is performed.

Multiple EE replicas require routing and database configuration appropriate to the deployed transport; legacy sessions are process-local. HA claims apply only to release images with published operational and load-test evidence.
