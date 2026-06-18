# Account AV Web Audit

Status: current as of 2026-06-18.

Account AV user-facing web was checked as part of the AV web visual audit.

## Contract

- Account AV is the user-facing account self-service surface.
- User-facing routes support `en`, `es`, `fr`, `de`, and `ca`.
- AV-owned links preserve the active language.
- Admin/operator work belongs in Admin AV, not Account AV.

## Latest Audit Result

- Desktop and mobile browser QA passed.
- Signed-in account, apps, billing, danger-zone, and deletion flows rendered
  correctly where a session was available.
- The final pass localized known account-deletion warning details in the
  user-facing Danger Zone, including linked apps, AI credits, Pro access, and
  billing warnings.
