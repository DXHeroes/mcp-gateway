# Upgrade notes

Operator-facing notes for upgrading a running gateway. Each section covers one
release and lists only what a deployment has to change; ordinary features and
fixes are in the changelog.

Read the section for every version between the one you are running and the one
you are moving to. The gateway shows its own version on the last line of the sidebar, with
build and migration details behind it, and reports it on the authenticated
`GET /api/edition` and `GET /api/diagnostics` endpoints.

**Coming from 0.2.x or earlier?** Apply the sections in order: 0.3.0, then 0.4.0, then 0.6.0, then
0.7.0. 0.5.0 needs no action. Start with the 0.3.0 image rename below — before 0.3.0 the image was
`devdxheroes/mcp-gateway` and carried moving `latest` and `stable` tags, neither of which exists
any more, so the first thing to fix is the image reference itself.

## 0.7.0 — `AUTH_SECRET` replaces `BETTER_AUTH_SECRET`; the Helm chart becomes `mcp-gateway`

Two changes need action. `AUTH_SECRET` applies to every deployment; the chart rename applies to
Helm installations only, and both are made in the same upgrade.

### `AUTH_SECRET` replaces `BETTER_AUTH_SECRET`

**Action required for every deployment.** Rename `BETTER_AUTH_SECRET` to
`AUTH_SECRET` and **keep its value**. A gateway that still sets only
`BETTER_AUTH_SECRET` refuses to start with a message naming the variable to
rename, and so does one that sets both to different values.

It does not fall back silently, because the fallback would do damage. Without
the key the gateway generates a random one at every start. That signs every user
out, and since the same key encrypts every enrolled TOTP secret and backup code,
nobody with two-factor authentication could sign in again. With
`AUTH_REQUIRE_MFA` set, that is every password user.

| Before | After |
|---|---|
| `BETTER_AUTH_SECRET=<value>` | `AUTH_SECRET=<the same value>` |
| Secret key `BETTER_AUTH_SECRET` (Helm `secret.existingSecret`) | Secret key `AUTH_SECRET` |
| Helm `secret.values.BETTER_AUTH_SECRET` (dev only) | Helm `secret.values.AUTH_SECRET` |

The old name said which library reads the key, not what it is for. The new one
sits next to the other sign-in settings (`AUTH_EMAIL_PASSWORD`,
`AUTH_REQUIRE_MFA`, `AUTH_SIGNUP_MODE`). Startup messages name the variables but
never print their values.

While both names are set **to the same value**, the gateway starts and logs a
warning that the old one is no longer read. Older versions ignore
`AUTH_SECRET`, so you can add it before you upgrade and remove the old name
afterwards.

### Docker / Docker Compose

In `.env`, or wherever the container gets its environment:

```diff
-BETTER_AUTH_SECRET=<value>
+AUTH_SECRET=<value>
```

If you deploy the published `compose.yaml`, take the 0.7.0 version of it
together with the image. The older file passes only `BETTER_AUTH_SECRET` into
the container, so a 0.7.0 image started from it refuses to start. The new file
requires `AUTH_SECRET` in `.env`, and `docker compose up` stops before starting
anything if it is missing.

### Coolify and other dashboards

Add `AUTH_SECRET` with the value currently in `BETTER_AUTH_SECRET`, redeploy,
then delete `BETTER_AUTH_SECRET`. If Coolify deploys the published compose file,
the new file makes Coolify list an empty `AUTH_SECRET`. Fill it in before the
first deployment of 0.7.0.

### Helm: rename the Secret key

The chart turns every key of the Secret into an environment variable of the
same name (`envFrom`), so rename the key in the Secret you reference in
`secret.existingSecret`. With plain Kubernetes Secrets, copy the key first,
upgrade, then remove the old one:

```bash
# OpenShift: oc ... | Kubernetes: kubectl ...
oc -n mcp-gateway patch secret mcp-gateway-secrets --type merge -p \
  "{\"data\":{\"AUTH_SECRET\":\"$(oc -n mcp-gateway get secret mcp-gateway-secrets \
  -o jsonpath='{.data.BETTER_AUTH_SECRET}')\"}}"

helm upgrade ...

oc -n mcp-gateway patch secret mcp-gateway-secrets --type json \
  -p '[{"op":"remove","path":"/data/BETTER_AUTH_SECRET"}]'
```

With Vault or External Secrets Operator, rename the target key in the
`ExternalSecret` (or its template) and leave the stored value alone. A Secret
change does not restart the pods, so run the `rollout restart` from the chart's
install notes if you change the key without upgrading.

### Rolling back

Reverting to 0.6.x requires `BETTER_AUTH_SECRET` again. If you keep both names
with the same value until you are sure about the upgrade, a rollback is a plain
image change. No data or schema migration is involved.

### The Helm chart is renamed to `mcp-gateway` and published

**Action required for Helm installations only.** The chart that was `local-mcp-gateway` is now
`mcp-gateway`, and every stable release publishes it, signed, as the public OCI artifact
`oci://registry-1.docker.io/dxheroes/mcp-gateway` (chart version `0.7.0` for `v0.7.0`; Helm
versions carry no `v`). The chart name feeds the `app.kubernetes.io/name` label and the resource
names. Kubernetes does not let a Deployment change its selector, so upgrading an existing
release to the renamed chart without the setting below fails.

Add this to every upgrade of a release installed before 0.7.0, once and for good (put it in your
values file):

```yaml
nameOverride: local-mcp-gateway
```

With it, the renamed chart renders the same resource names and selectors as before; only the
`helm.sh/chart` label and the config checksum differ, which rolls the pods once as any upgrade
does.

```bash
helm upgrade mcp-gateway oci://registry-1.docker.io/dxheroes/mcp-gateway --version 0.7.0 \
  -n mcp-gateway --reuse-values --set nameOverride=local-mcp-gateway
```

A new installation needs nothing. Docker Compose, Coolify and other non-Helm deployments are not
affected. `charts/catalog-stack` keeps its values key `local-mcp-gateway:` and its names: it
depends on the renamed chart under that alias. Its `Chart.lock` is no longer committed; run
`helm dependency build charts/catalog-stack` as before.

## 0.6.0 — EE images move to `dxheroes/mcp-gateway-ee`

**Action required for EE only, before you pull 0.6.0.** From 0.6.0 on, the EE image is
published only as `docker.io/dxheroes/mcp-gateway-ee`. The old repository
`devdxheroes/mcp-gateway-ee` keeps every tag up to `v0.5.0` and receives nothing newer, so a
deployment that only changes the tag to `v0.6.0` fails with `not found`. Nothing inside the
gateway changes: no variable, no migration step.

| Where | Before | After |
|---|---|---|
| Docker / Compose | `image: devdxheroes/mcp-gateway-ee:v0.5.0` | `image: dxheroes/mcp-gateway-ee:v0.6.0` |
| Coolify and other dashboards | image `devdxheroes/mcp-gateway-ee` | image `dxheroes/mcp-gateway-ee` |
| Helm | `image.repository: devdxheroes/mcp-gateway-ee` | `image.repository: dxheroes/mcp-gateway-ee` |
| Air-gapped mirror | `docker pull devdxheroes/mcp-gateway-ee:<version>` | `docker pull dxheroes/mcp-gateway-ee:<version>` |

The image is still private. Log in with the user name of the account your read-only access
token belongs to, not with the repository's namespace: the tokens issued so far belong to the
`devdxheroes` account, so `docker login -u devdxheroes` with the same token as before. If
pulling the new name answers `pull access denied`, ask DX Heroes for access to the new
repository; do not work around it by staying on the old name, which will not receive security
fixes.

CE needs no change **if you pull from GHCR**. Its canonical image stays
`ghcr.io/dxheroes/mcp-gateway-ce`, and the same signed digest is now also public on Docker Hub as
`docker.io/dxheroes/mcp-gateway-ce`. If you pinned the Docker Hub name instead, the namespace moved
for CE too: the published compose file defaulted to `docker.io/devdxheroes/mcp-gateway-ce` up to
`v0.5.0` and to `docker.io/dxheroes/mcp-gateway-ce` from `v0.6.0`. Update your own compose file or
`GATEWAY_IMAGE` accordingly.

Both editions are now also published as `vX.Y.Z-beta.N` and a moving `beta` tag, built from
every change to the development branch. Those are for trying a fix before its release, not for
production: keep pinning `vX.Y.Z` or, better, a digest.

## 0.5.0 — CE accepts its terms without `GATEWAY_CE_USE`

**No action required.** CE terms version `2026-09-18.1` drop the separate
production/evaluation declaration: accepting the terms already confirms that the
use is eligible. The gateway no longer reads `GATEWAY_CE_USE`, so you can delete
it (in Helm, `config.ceUse` is now ignored). An installation that accepted
`2026-09-17.1` keeps starting unchanged. To move to the current terms, read
`LICENSE-CE.txt` and set `GATEWAY_CE_TERMS_ACCEPTED=2026-09-18.1`. EE is not
affected.

## 0.4.0 — `GATEWAY_LICENSE` replaces `GATEWAY_LICENSE_FILE`

**Action required for EE only.** An EE gateway that still sets
`GATEWAY_LICENSE_FILE` without `GATEWAY_LICENSE` refuses to start with a message
naming the variable to rename. It does not fall back silently: without its
license an EE gateway keeps serving traffic but refuses every configuration
change, and nothing would point at the renamed variable. CE never read the
license and needs no change.

### What changed

`GATEWAY_LICENSE` takes the same file path as before **or** the license content
itself. A value starting with `{` is the content (a license is a JSON document);
anything else is a path.

| Before | After |
|---|---|
| `GATEWAY_LICENSE_FILE=/run/gateway-license/license.json` | `GATEWAY_LICENSE=/run/gateway-license/license.json` |
| file mount + `GATEWAY_LICENSE_FILE` | or: `GATEWAY_LICENSE={"keyId":…}` with no mount |
| Helm `config.licenseFile` | Helm `config.license` (path), or `GATEWAY_LICENSE` in the Secret (content) |

Renewal differs by form. A mounted file is re-read on every check, so replacing
it atomically takes effect without a restart, as before. Inline content is an
environment variable, so a renewed license needs the variable updated and the
gateway restarted.

The license is a credential. Keep inline content in your secret store, not in a
committed `.env` or a ConfigMap. Startup messages name the variables but never
print their values.

### Docker / Docker Compose

```diff
     environment:
-      GATEWAY_LICENSE_FILE: /run/gateway-license/license.json
+      GATEWAY_LICENSE: /run/gateway-license/license.json
```

To drop the mount instead, put the content of the issued `.license.json` file
into `GATEWAY_LICENSE` and remove the license volume.

### Coolify and other dashboards

Add `GATEWAY_LICENSE`, redeploy, then delete `GATEWAY_LICENSE_FILE`. While both
are set, the gateway starts and logs a warning that the old one is no longer
read, so add the new variable **before** moving to the new image. The value can
be the existing path or the content of the license file; with the content, the
file storage is no longer needed. After the redeploy, check that the license
page (or `GET /api/edition`) reports the license as valid.

### Helm

```diff
 config:
-  licenseFile: /run/gateway-license/license.json
+  license: /run/gateway-license/license.json
```

A values file still setting `config.licenseFile` is refused by the chart's
values schema, so `helm upgrade` fails before anything is applied:

```
Error: values don't meet the specifications of the schema(s) in the following chart(s):
local-mcp-gateway:
- at '/config': additional properties 'licenseFile' not allowed
```

`config.license` accepts a path only; the schema rejects license content there,
because the chart renders it into a ConfigMap. To pass the content, add it to
the Secret named by `secret.existingSecret` under the key `GATEWAY_LICENSE`.

In 0.3.0 the chart rendered `config.licenseFile`, `config.ceTermsAccepted` and
`config.ceUse` into the ConfigMap's metadata instead of its data, so none of
them reached the gateway. That is fixed: they are now passed to the container.

### Rolling back

Reverting to 0.3.x requires putting `GATEWAY_LICENSE_FILE` back, and that
version only accepts a path: inline content has to be written to a mounted file
again. No data or schema migration is involved.

## 0.3.0 — one public URL replaces `BETTER_AUTH_URL` and `FRONTEND_URL`; the EE image is renamed

Two changes need action. The image rename applies to EE only; `PUBLIC_URL` applies to every
deployment.

### The EE image is renamed, and `latest` / `stable` are gone

**Action required for EE, before you pull 0.3.0.** The image was renamed from
`devdxheroes/mcp-gateway` to `devdxheroes/mcp-gateway-ee` when the Community Edition was
introduced and the two editions needed separate repositories. (It moved again in 0.6.0 — if you
are upgrading past that release, go straight to `dxheroes/mcp-gateway-ee` and read the 0.6.0
section.)

| Where | Before | After |
|---|---|---|
| Docker / Compose | `image: devdxheroes/mcp-gateway:<tag>` | `image: dxheroes/mcp-gateway-ee:vX.Y.Z` |
| Helm | `image.repository: devdxheroes/mcp-gateway` | `image.repository: dxheroes/mcp-gateway-ee` |

At the same time the moving tags **`latest` and `stable` stopped being published**. Only
`vX.Y.Z` releases exist (and, from 0.6.0, `vX.Y.Z-beta.N` plus a moving `beta`). A deployment
that referenced `:latest` or `:stable` keeps running the image it already pulled and silently
stops receiving updates; a fresh pull fails with `manifest unknown`. Pin an explicit `vX.Y.Z`,
or better the digest from that release's `release.json`.

There is no `latest` by design: a moving tag would hand you a breaking configuration change —
of which this file lists several — with no warning.

### One public URL replaces `BETTER_AUTH_URL` and `FRONTEND_URL`

**Action required.** A gateway that still sets `BETTER_AUTH_URL` or
`FRONTEND_URL` without `PUBLIC_URL` refuses to start with a message naming the
variable to rename. It does not fall back silently: those variables decided
every OAuth redirect, invitation link and CORS origin, so ignoring them would
move all of them to the gateway's own loopback address and surface hours later
as a login that cannot complete.

### What changed

| Before | After |
|---|---|
| `BETTER_AUTH_URL=https://gateway.example.com` | `PUBLIC_URL=https://gateway.example.com` |
| `FRONTEND_URL=https://gateway.example.com` | remove — `PUBLIC_URL` covers it |
| Helm `config.betterAuthUrl` | Helm `config.publicUrl` |
| Helm `config.frontendUrl` | remove |

In the production image the backend serves the built UI, so the two variables
always held the same value typed twice — `FRONTEND_URL` even defaulted to the
backend origin. `PUBLIC_URL` is that one value, and its name describes what it
is for rather than which library reads it.

`CORS_ORIGINS` is unchanged, and still unions in the gateway's own public origin
automatically.

### Docker / Docker Compose

```diff
-      BETTER_AUTH_URL: https://gateway.example.com
-      FRONTEND_URL: https://gateway.example.com
+      PUBLIC_URL: https://gateway.example.com
```

If you deploy the published compose file, `PUBLIC_URL` was already the single
variable you set in `.env` — it now reaches the gateway directly instead of
being fanned out into the two removed names. No change to your `.env`.

### Coolify and other dashboards

Add `PUBLIC_URL` with the value currently in `BETTER_AUTH_URL`, redeploy, then
delete `BETTER_AUTH_URL` and `FRONTEND_URL`. Adding the new variable before
removing the old ones keeps the rollout to a single restart; while both are
set, the gateway starts and logs a warning that the old ones are no longer
read.

### Helm

```diff
 config:
-  betterAuthUrl: https://gateway.example.com
-  frontendUrl: https://gateway.example.com
+  publicUrl: https://gateway.example.com
```

A values file still setting `config.betterAuthUrl` is refused by the chart's
values schema, so `helm upgrade` fails before anything is applied:

```
Error: values don't meet the specifications of the schema(s) in the following chart(s):
local-mcp-gateway:
- at '/config': additional properties 'betterAuthUrl' not allowed
```

### Validation added

`PUBLIC_URL` is now checked at boot and must be an absolute `http`/`https` URL.
Previously an unparseable value threw from inside CORS setup with no indication
of which variable was at fault.

### Rolling back

Reverting to 0.2.x requires putting `BETTER_AUTH_URL` (and, for split-Vite
development, `FRONTEND_URL`) back. No data or schema migration is involved, so a
rollback is otherwise a plain image change.
