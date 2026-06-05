# Account AV Agent Rules

Account AV is the shared native authentication package for AV product apps. It
does not define product ownership, credits, subscriptions, Convex documents,
D1 rows, R2 keys, or analytics identity by itself.

For any native app workflow validation that touches signed account state,
provider tokens, backend-owned identity, subscriptions, purchases, credits, or
deletion flows, follow the private AVALSYS guides. Do not invent a local runtime
flow from this public repo.

- `private/avalsys-suite/docs/platform/native-preview-dev-validation-guide.md`
- `private/avalsys-suite/docs/platform/native-account-identity-contract.md`

Mandatory rules:

- treat `providerSessionUser` as provider session metadata only;
- never use the provider subject as product ownership identity;
- resolve the internal Apps AV user through the platform API `/v1/me`;
- if `/v1/me` fails, do not fall back to the provider subject for
  backend-owned state;
- use Cloudflare preview for signed API runtime;
- use Convex cloud `dev`, not local Convex, when a native app workflow depends
  on Convex-backed state;
- do not use `wrangler dev` or another local Worker as product app backend;
- use Infisical/Varlock-backed private tooling for config, deploy keys, and
  secret resolution;
- keep private URLs, service identifiers, approval status, and operations
  evidence out of this public repo.

If the private repo is unavailable, stop and say that the authoritative runbook
cannot be checked. Do not substitute a guessed local workflow.
