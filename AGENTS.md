# Account AV Agent Rules

Before work that touches signed runtime, backend-owned identity, billing,
deletion, deployment, TestFlight/App Store, Convex, Cloudflare remote state, or
cross-app workflow behavior, run the private workspace preflight first:

```bash
bash ../../private/avalsys-suite/scripts/agent-preflight.sh --app account-av --intent <intent>
```

Read `../../private/avalsys-suite/docs/agents/workspace-guardrails.md` and every doc
printed by the preflight before executing commands. If the private repo is
unavailable, stop instead of guessing.

Account AV is the shared native authentication package for AV product apps. It
does not define product ownership, credits, subscriptions, Convex documents,
D1 rows, R2 keys, or analytics identity by itself.

For any native app workflow validation that touches signed account state,
provider tokens, backend-owned identity, subscriptions, purchases, credits, or
deletion flows, follow the private AVALSYS guides. Do not invent a local runtime
flow from this public repo.

- `private/avalsys-suite/docs/platform/native-preview-dev-validation-guide.md`
- `private/avalsys-suite/docs/platform/native-account-identity-contract.md`
- `private/avalsys-suite/docs/platform/account-av-ios-testflight-contract.md`
- `private/avalsys-suite/docs/agents/plan-step.md` when the user says
  `usa plan-step` or asks for step-by-step plan execution.
- `private/avalsys-suite/docs/agents/plan-goal.md` when the user says
  `usa plan-goal` or asks for reviewed full-plan execution.

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
- keep Account AV iOS keychain configuration provider-neutral and compatible
  with the Tune AV contract: publishable key, keychain service, and keychain
  access group must be accepted by the shared Clerk wrapper;
- keep private URLs, service identifiers, approval status, and operations
  evidence out of this public repo.

If the private repo is unavailable, stop and say that the authoritative runbook
cannot be checked. Do not substitute a guessed local workflow.
