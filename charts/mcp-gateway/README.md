# mcp-gateway Helm chart

OpenShift-native Helm chart for DXH Gateway, hardened for the `restricted-v2` SCC (arbitrary UID,
read-only root filesystem, dropped capabilities). Works on plain Kubernetes too.

Every stable release publishes this chart as a signed OCI artifact,
`oci://registry-1.docker.io/dxheroes/mcp-gateway`, with the chart version equal to the Gateway
version (`0.7.0` for `v0.7.0`; Helm tags carry no `v`). It is public: no login is needed for the
chart, only for a private EE image. The same chart is also in the public `DXHeroes/mcp-gateway`
repository. Pin `image.digest` in production. `--version 1` (or `1.0`) installs the newest chart of that
line; `--version 1.0.0` is the exact chart.

Until 0.6.0 the chart was called `local-mcp-gateway`. An installation made with that name keeps
its resource names and selectors only with `nameOverride: local-mcp-gateway`; see the 0.7.0
upgrade notes.

## Prerequisites

- Kubernetes >= 1.25 / OpenShift 4.12+
- An external PostgreSQL database (the chart bundles no DB)
- A Secret with at least `GATEWAY_ENCRYPTION_KEY` and `DATABASE_URL`

## Quick start (OpenShift, production)

Provide secrets through an existing Secret (e.g. synced by Vault / External
Secrets Operator) whose keys are named after the env vars the app reads:

```bash
oc create secret generic mcp-gateway-secrets \
  --from-literal=GATEWAY_ENCRYPTION_KEY='<32+ random chars, immutable>' \
  --from-literal=DATABASE_URL='postgresql://user:pass@db.internal:5432/mcp' \
  --from-literal=AUTH_SECRET='<random>' \
  --from-file=GATEWAY_LICENSE=./license.json

helm install mcp-gateway oci://registry-1.docker.io/dxheroes/mcp-gateway --version <X.Y.Z> \
  --set edition=ee \
  --set image.registry=registry.bank.internal \
  --set image.repository=mcp-gateway/mcp-gateway-ee \
  --set image.digest=sha256:... \
  --set secret.existingSecret=mcp-gateway-secrets \
  --set route.host=mcp-gateway.apps.bank.internal \
  --set config.publicUrl=https://mcp-gateway.apps.bank.internal
```

`edition=ee` belongs to every Enterprise Edition install and upgrade. Without it the chart
renders the default `edition: ce`: `Recreate` strategy, exactly one replica and no migration hook.
Without a valid license an EE gateway refuses every configuration change, including new
accounts. `GATEWAY_LICENSE` above carries the license content; to mount it as a file that renews
without a restart, set `config.license` to its path instead (Kubernetes and OpenShift deployment
guide, Step 2b).

## Quick start (kind / local dev)

```bash
helm install mcp charts/mcp-gateway \
  --set route.enabled=false --set ingress.enabled=true \
  --set secret.create=true \
  --set secret.values.GATEWAY_ENCRYPTION_KEY=dev-encryption-key-1234567890 \
  --set secret.values.DATABASE_URL=postgresql://postgres:postgres@host:5432/mcp_gateway
```

## Key values

| Key | Default | Notes |
| --- | --- | --- |
| `edition` | `ce` | `ee` for Enterprise Edition; must match the image |
| `image.registry` / `image.repository` | `ghcr.io` / `dxheroes/mcp-gateway-ce` | Override for EE or an internal mirror |
| `image.digest` | `""` | Takes precedence over `tag`; use for air-gapped pinning |
| `secret.existingSecret` | `""` | Production: name of an external Secret (Vault/ESO) |
| `secret.create` | `false` | Dev only; renders a Secret from `secret.values` |
| `route.enabled` / `ingress.enabled` | `true` / `false` | Route is the OpenShift default (edge TLS) |
| `route.tls.termination` | `edge` | `edge` \| `reencrypt` \| `passthrough`; only `edge` works as is (the pod serves plain HTTP, no serving certificate) |
| `migrations.runAsHook` | `true` | EE only: run DB migrations as a pre-install/upgrade Job (avoids multi-replica races). Its pods are labelled `<name>-migrate` and get the same `extraEnv`, `extraVolumes` and `extraVolumeMounts` as the app pods |
| `networkPolicy.enabled` | `false` | Opt-in default-deny + allowlist; in EE with the migration hook also a hook NetworkPolicy for the migration pods |
| `networkPolicy.egress.migrateRules` | `[]` | Egress of the migration pods besides DNS; empty = `networkPolicy.egress.extraRules` |
| `strategy` | `{}` | EE only: Deployment `spec.strategy`; empty = Kubernetes default `RollingUpdate`. `maxSurge: 0`, `maxUnavailable: 1` needs no spare node |
| `preStopDrainSeconds` / `terminationGracePeriodSeconds` | `0` / `30` | Drain delay before SIGTERM (10 with one-pod-at-a-time) and the grace period it counts against |
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
