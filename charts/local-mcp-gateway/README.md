# local-mcp-gateway Helm chart

OpenShift-native Helm chart for DXH Gateway, hardened for the
`restricted-v2` SCC (arbitrary UID, read-only root filesystem, dropped
capabilities). Works on plain Kubernetes too.

Use the chart from the public `DXHeroes/mcp-gateway` repository. Verify the release metadata and
pin `image.digest`; the chart version and application version are one Gateway product version.

## Prerequisites

- Kubernetes >= 1.25 / OpenShift 4.x
- An external PostgreSQL database (the chart bundles no DB)
- A Secret with at least `GATEWAY_ENCRYPTION_KEY` and `DATABASE_URL`

## Quick start (OpenShift, production)

Provide secrets through an existing Secret (e.g. synced by Vault / External
Secrets Operator) whose keys are named after the env vars the app reads:

```bash
oc create secret generic mcp-gateway-secrets \
  --from-literal=GATEWAY_ENCRYPTION_KEY='<32+ random chars, immutable>' \
  --from-literal=DATABASE_URL='postgresql://user:pass@db.internal:5432/mcp' \
  --from-literal=BETTER_AUTH_SECRET='<random>'

helm install mcp-gateway charts/local-mcp-gateway \
  --set image.registry=registry.bank.internal \
  --set image.digest=sha256:... \
  --set secret.existingSecret=mcp-gateway-secrets \
  --set route.host=mcp-gateway.apps.bank.internal \
  --set config.publicUrl=https://mcp-gateway.apps.bank.internal
```

## Quick start (kind / local dev)

```bash
helm install mcp charts/local-mcp-gateway \
  --set route.enabled=false --set ingress.enabled=true \
  --set secret.create=true \
  --set secret.values.GATEWAY_ENCRYPTION_KEY=dev-encryption-key-1234567890 \
  --set secret.values.DATABASE_URL=postgresql://postgres:postgres@host:5432/local_mcp_gateway
```

## Key values

| Key | Default | Notes |
| --- | --- | --- |
| `image.registry` / `image.repository` | `ghcr.io` / `dxheroes/mcp-gateway-ce` | Override for EE or an internal mirror |
| `image.digest` | `""` | Takes precedence over `tag`; use for air-gapped pinning |
| `secret.existingSecret` | `""` | Production: name of an external Secret (Vault/ESO) |
| `secret.create` | `false` | Dev only; renders a Secret from `secret.values` |
| `route.enabled` / `ingress.enabled` | `true` / `false` | Route is the OpenShift default (edge TLS) |
| `route.tls.termination` | `edge` | `edge` \| `reencrypt` \| `passthrough` |
| `migrations.runAsHook` | `true` | Run DB migrations as a pre-install/upgrade Job (avoids multi-replica races) |
| `networkPolicy.enabled` | `false` | Opt-in default-deny + allowlist |
| `autoscaling.enabled` / `pdb.enabled` | `false` / `false` | Optional operational controls |
| `config.*` | `""` | Non-secret env (auth toggles, OIDC IDs, URLs, OTEL); only-if-set |

`config.*` and secrets are never baked into the image, so each customer (bank
vs. company) configures auth methods, OIDC, etc. via values.

## Security notes

- No hardcoded `runAsUser`; OpenShift assigns the UID from the namespace range.
  On vanilla Kubernetes set `podSecurityContext.runAsUser` / `fsGroup`.
- `readOnlyRootFilesystem: true`; `/home/app` and `/tmp` are `emptyDir`.
- `GATEWAY_ENCRYPTION_KEY` is immutable — rotating it invalidates stored tokens.
- ServiceAccount mounts no token (the app uses no Kubernetes API).
