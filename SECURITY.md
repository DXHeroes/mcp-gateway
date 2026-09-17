# Security policy

Do not report vulnerabilities, credentials, customer endpoints, MCP tool results, or configuration
exports in a public issue. Use GitHub's private vulnerability reporting for this repository. If that
channel is unavailable, contact security@dxheroes.io and include only enough information to arrange
a protected handoff.

DX Heroes supports the current Gateway release. Release metadata records the immutable image
digest, two native Linux platforms, source revision, signing identity, and terms version. Verify the
digest, signature, SBOM, and provenance before deployment. Security fixes apply to affected CE and
EE images; service source remains private.

The Claude plugin performs read-only checks before showing a proposed change. Treat its plan as
review material. Do not approve commands that include plaintext secrets, mutable image tags,
unreviewed third-party code, or an unexpected registry, endpoint, volume, or destructive database
operation.
