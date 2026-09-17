# Verify edition images

One reviewed private source revision produces paired CE and EE images with the same Gateway version.
CE is public at `ghcr.io/dxheroes/mcp-gateway-ce`; EE stays private at
`docker.io/devdxheroes/mcp-gateway-ee`. Each release index contains native `linux/amd64` and
`linux/arm64` subjects. The workflow does not publish `latest` or `stable`.

Every native subject is content-audited, exercised as its actual architecture, scanned for fixed
HIGH/CRITICAL vulnerabilities, and published with BuildKit SBOM and provenance attestations. Only
after all four CE/EE subjects pass does the release job assemble the two multi-platform indexes and
sign their immutable digests with keyless Cosign. CE is tagged last, after its private EE counterpart
succeeds.

## Verify before deployment

Read `release.json` from the matching public Git tag. Confirm its version, platforms, source revision,
terms version, image repository, digest, and signing identity. Do not infer trusted identity from the
image. The expected OIDC issuer is `https://token.actions.githubusercontent.com`.

```sh
IMAGE="$(jq -r '.image + "@" + .digest' release.json)"
SIGNER="$(jq -r .signingIdentity release.json)"

cosign verify "$IMAGE" \
  --certificate-identity "$SIGNER" \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com

docker buildx imagetools inspect "$IMAGE" --format '{{json .SBOM}}' | jq .
docker buildx imagetools inspect "$IMAGE" --format '{{json .Provenance.SLSA}}' | jq .
```

Require exactly `linux/amd64` and `linux/arm64` image subjects plus their attestation manifests. A
failed signature, attestation, digest, platform, source-revision, or edition check stops deployment.
The Cosign signature covers the final OCI index, including the BuildKit SBOM and provenance
descriptors referenced by that index. The BuildKit attestations are not separate Cosign attestations.
Vulnerability scans ignore unfixed findings, so operators should still review the SBOM and current
advisories under their own policy.

For an offline deployment, verify online first, then mirror the digest and OCI referrers with tooling
that preserves signatures and attestations. Verify the destination digest again. Copying a tag alone
does not preserve the complete evidence.

EE verification uses the same process after authenticating to its private Docker Hub repository.
Offline product-license signatures and image supply-chain signatures are separate mechanisms; an
EE image contains only public verification keys, never issuer private keys.
