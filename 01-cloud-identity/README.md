# Lab 02 — Cloud Identity (Microsoft Entra ID / Azure)

> **Status:** Complete
> **Where:** HOST (browser) — no local system changes

## Problem

Cloud identity is the front door to most modern enterprise environments. Misconfigured
roles, missing MFA, and overly permissive access are consistently top findings in
real-world assessments. This lab builds hands-on fluency with Microsoft Entra ID
identity management, Azure RBAC, and Conditional Access in a way that connects
directly to the AC and IA control families from NIST SP 800-53.

---

## What I did

### 1. Tenant and subscription setup

Created a personal Microsoft Azure subscription (pay-as-you-go) tied to a dedicated
Microsoft account — separate from a university-managed tenant that would have
restricted administrative actions. A cost management budget alert was configured
immediately at a $5 threshold with email notification at 100% actual spend and 2%
forecasted spend. This ensures no unexpected charges accrue during lab work.

**Key decision:** Using a personal tenant rather than an institutional one provides
full Global Administrator rights, which is necessary to configure Conditional Access
policies, assign roles, and manage licenses — all of which are locked down in
managed educational tenants.

The tenant's primary domain is `<tenant>.onmicrosoft.com`, created through the
Microsoft 365 licensing flow when activating the Entra ID P2 trial.

**Lesson from this step:** Microsoft's multiple signup flows (Azure portal vs.
Microsoft 365 admin center vs. Entra admin center) can silently create separate
tenants for the same Microsoft account. This is a real-world IAM challenge —
organizations that acquire products piecemeal often end up with fragmented tenant
sprawl that complicates identity governance. Consolidating into a single authoritative
tenant is a standard remediation.

---

### 2. User provisioning

Created two internal users in the `<tenant>` Entra ID tenant via the Microsoft 365
admin center:

| User | UPN | Purpose |
|------|-----|---------|
| Alice | `alice.admin@<tenant>.onmicrosoft.com` | Represents a security analyst with elevated read access |
| Bob | `bob.reader@<tenant>.onmicrosoft.com` | Represents a standard user with no elevated permissions |

Both accounts were created as **Member** type (internal identities, not guest/B2B),
with accounts enabled and no product licenses assigned. Lab users do not need
Entra ID P2 licenses — only the administrator account requires it to manage
Conditional Access policies. This reflects least-privilege license assignment.

**Control:** NIST 800-53 **AC-2** (Account Management) — user accounts are
provisioned with defined identity attributes, explicitly enabled, and tied to
a specific role purpose.

---

### 3. Security group

Created a Security group named `lab-readers` with the following configuration:

| Field | Value |
|-------|-------|
| Group type | Security |
| Group name | `lab-readers` |
| Description | Read-Only access group for lab demonstration |
| Membership type | Assigned |
| Entra roles assignable | No |
| Members | Alice, Bob |

**Membership type: Assigned** means membership is explicitly controlled rather than
dynamically evaluated against user attributes. This is the correct choice when
membership should reflect deliberate authorization decisions, not automated rules.

The group is not role-assignable (`Microsoft Entra roles can be assigned to the group:
No`), which keeps the group's scope limited to resource-level access control rather
than directory-wide privilege elevation.

**Control:** NIST 800-53 **AC-2** — group-based access management supports the
account management lifecycle. Removing a user from the group revokes all
associated permissions in one action, which is essential for timely offboarding.

---

### 4. Role assignment (Entra RBAC)

Assigned the built-in **Security Reader** Entra ID role to `alice.admin` directly,
at **Directory** scope (tenant-wide).

| Field | Value |
|-------|-------|
| Role | Security Reader |
| Assignee | alice.admin |
| Assignment type | Active (direct) |
| Scope | Directory |

**Why Security Reader:** This role grants read-only access to security features across
the tenant — Microsoft Defender, Identity Protection, audit logs, and security
recommendations — without any write permissions. It is a realistic role for a junior
security analyst who needs visibility without the ability to modify security
configurations.

`bob.reader` received no role assignment, representing a standard user with no
elevated access. The contrast between Alice and Bob demonstrates the principle of
differentiated access levels within the same tenant.

**Controls:**
- NIST 800-53 **AC-3** (Access Enforcement) — role assignments enforce what each
  identity is authorized to access.
- NIST 800-53 **AC-6** (Least Privilege) — Security Reader provides the minimum
  access necessary for the analyst function; no write capabilities are included.

---

### 5. Conditional Access policy

Activated a **Microsoft Entra ID P2 free trial** (30 days, 100 licenses) to unlock
Conditional Access policy creation. P2 is the license tier required for CA; it is
licensed separately from Azure services.

Created the following policy via Entra ID → Security → Conditional Access:

| Field | Value |
|-------|-------|
| Policy name | `require-mfa-all-users` |
| Users | All users |
| Target resources | All resources (all cloud apps) |
| Grant control | Require multifactor authentication |
| Session control | Sign-in frequency — 8 hours |
| State | Report-only |

**Grant control — Require MFA:** Forces every user to complete a second factor at
sign-in. This is the single most impactful identity control available and is a
baseline requirement in most compliance frameworks.

**Session control — Sign-in frequency (8 hours):** Forces re-authentication after
a full work day. A stolen session token or persistent browser session cannot be
used indefinitely — it expires at the 8-hour mark. This limits the blast radius
of a session hijack.

**State: Report-only:** The policy evaluates every sign-in and logs what *would*
have happened (blocked, granted with MFA, etc.) without enforcing the outcome.
This is the correct first deployment step in any production environment — you
validate that the policy does not break legitimate access patterns before switching
to enforcement mode. Enabling an untested CA policy as "On" can lock administrators
out of the tenant.

**Controls:**
- NIST 800-53 **IA-2** (Identification and Authentication) — configured to require
  identity verification at sign-in; **validated in report-only, enforcement pending**
  since the policy has not yet been switched to "On."
- NIST 800-53 **IA-2(1)** (MFA for privileged accounts) and **IA-2(2)** (MFA for
  non-privileged accounts) — the "All users / All resources" scope would satisfy
  both enhancement requirements once enforced; **configured, not yet enforced**.
- NIST 800-53 **AC-12** (Session Termination) and **IA-11** (Re-authentication) —
  the 8-hour sign-in frequency bounds session lifetime and forces re-authentication
  after a defined interval, limiting exposure from unattended or hijacked sessions
  once enforced. IA-11 is the more precise cite for a re-authentication interval.
- NIST 800-53 **CA-2** (Control Assessments) — **met**: Report-only mode functions
  as a continuous assessment of the policy's effect before enforcement, consistent
  with a test-before-enforce methodology.

---

### 6. Privileged Identity Management (PIM) — standing access to just-in-time

`alice.admin`'s Security Reader assignment started as a standing **Active (Direct)**
assignment with no expiration — the same configuration created in step 4. Using PIM,
that was converted to a **PIM-eligible** assignment, and the original standing
assignment was removed.

| Field | Before | After |
|-------|--------|-------|
| Assignment type | Active (Direct) | Eligible (Direct) |
| Duration | Permanent | Permanently eligible |
| Standing access | Yes | No — requires activation |

**Why this matters:** a standing privileged assignment is accessible the instant the
account is compromised. An eligible assignment has no access until it is explicitly
activated, shrinking the window an attacker (or a compromised credential) could exploit
the role.

**Controls:**
- NIST 800-53 **AC-2(7)** (Privileged User Accounts) — **met**: Security Reader is no
  longer a standing assignment; eligibility replaces persistent access.
- NIST 800-53 **AC-6** (Least Privilege) — reinforced: privileged access now exists
  only when actively invoked, not by default.

**PIM Role Settings — adding an approval workflow to activation.** By default, an
eligible assignment can be self-activated with only a typed justification and no
oversight. The Security Reader role's settings were edited to also **require approval**
before activation, with the Global Administrator set as the approver.

| Setting | Before | After |
|---------|--------|-------|
| Require approval to activate | No | **Yes** (Approver: Global Administrator) |
| Require justification on activation | Yes | Yes (unchanged) |

This turns self-service JIT access into a two-party control: `alice.admin` can request
activation, but the role does not actually grant access until an approver signs off —
closer to a real separation-of-duties model than eligibility alone provides.

**Control:**
- NIST 800-53 **AC-3** (Access Enforcement) — reinforced: activation now requires
  a second party's explicit approval, not just self-service eligibility.

---

### 8. Access Reviews — recertifying the PIM-eligible assignment

Created a one-time access review, **Reader Role Recertification**, scoped to the
Security Reader role and covering all active and eligible assignments (i.e., Alice's
new PIM-eligible assignment from step 6). "Require reason on approval" was enabled.

| Field | Value |
|-------|-------|
| Scope | Microsoft Entra roles — Security Reader |
| Assignment type reviewed | All active and eligible assignments |
| Reviewer | Global Administrator (self — no second admin exists in this lab tenant) |
| Frequency | One-time |
| Require reason on approval | Enabled |
| Outcome | **Approved** — "Still requires read access for lab monitoring tasks." |

**Notable detail:** Entra's system-generated recommendation was **Deny**, based on
Alice's account having no sign-in activity in the last 30 days. The reviewer's actual
decision was **Approve**, with a recorded justification overriding that recommendation.
That gap is the point of an access review — the recommendation engine flags dormant
access, but a human reviewer makes and documents the final call. That produces an
auditable decision trail, not a rubber stamp.

**Controls:**
- NIST 800-53 **AC-2(3)** (Disable Accounts) — **met**: the privileged assignment was
  formally recertified with a recorded decision and justification, the mechanism this
  enhancement requires for periodic review of account necessity.
- NIST 800-53 **CA-7** (Continuous Monitoring) — **met**: the access review functions
  as a point-in-time assessment of a privileged assignment's continued necessity.

---

### 9. Risk-based Conditional Access policy

Created a second CA policy, layering sign-in risk detection on top of the existing
MFA baseline policy from step 5.

| Field | Value |
|-------|-------|
| Policy name | `risk-based-signin-mfa` |
| Users | `alice.admin`, `bob.reader` — **admin account deliberately excluded** |
| Target resources | All cloud apps |
| Conditions | Sign-in risk: Medium and High |
| Grant control | Require multifactor authentication |
| State | Report-only |

**Why the admin account is excluded:** this mirrors the standard break-glass/admin
exclusion pattern used for Conditional Access policies in production tenants — a false
positive on sign-in risk should never be able to lock out the only administrator, even
though Report-only mode carries no enforcement risk today.

**Caveat — configured, not exercised:** this is a fresh trial tenant with no real
attacker telemetry (no genuine anomalous sign-ins, impossible travel, or leaked
credentials to detect). Identity Protection's risk engine will most likely never
generate a genuine Medium/High risk signal here. This control is documented as
**configured only**, demonstrating how the policy is constructed rather than claiming
it has been operationally validated — the same configured-vs-enforced precision
applied to the MFA policy in step 5.

**Controls:**
- NIST 800-53 **AC-2(12)** (Account Monitoring for Atypical Usage) — **configured,
  not exercised**: the policy acts on atypical sign-in risk signals, but no genuine
  risk event has occurred in this tenant to validate it end-to-end.
- NIST 800-53 **IA-2** (Identification and Authentication) — **configured**: requires
  an additional authentication factor specifically when risk is detected, layered on
  top of the baseline MFA policy.

---

### 10. Sign-in log review — validating configured CA policies against live evaluation

Reviewed the Entra ID sign-in logs (`Identity → Monitoring & health → Sign-in logs`) to confirm
the two Report-only CA policies from steps 5 and 9 are actually being evaluated against real
sign-ins, not just sitting configured and unused.

**Lesson — two separate tabs, not one.** A sign-in's activity detail panel has both a
**Conditional Access** tab and a separate **Report only** tab. The Conditional Access tab only
lists policies actually set to **On** (plus **Security Defaults**, a distinct tenant-wide
baseline — see below); a policy in **Report-only** state is evaluated and logged, but its result
only shows up on the separate **Report only** tab. Checking the wrong tab first made it look like
neither custom policy was running at all.

| Policy | Report-only result on the admin's sign-in |
|--------|------|
| `require-mfa-all-users` | Not applied |
| `risk-based-signin-mfa` | Not applied |

**Finding — undocumented admin exclusion.** Checking the policies' **Exclude** tab (not just
Include, which is all step 5's original write-up covered) turned up that `require-mfa-all-users`
excludes the tenant's Global Administrator account. This wasn't previously documented — only
`risk-based-signin-mfa`'s admin exclusion (step 9) was. It's the same standard break-glass
rationale, just missing from the record until this review caught it. Both policies' "Not applied"
result above is fully explained by this: the admin account is the only one that has ever signed
in interactively in this tenant, and both policies exclude it by design.

**Caveat — target scope still unexercised.** `alice.admin` and `bob.reader` — the accounts these
policies actually target — have never authenticated interactively in this tenant (provisioned,
never used to sign in). So neither policy has ever produced a Report-only **Success/Failure**
result against its real target scope; "Not applied" against the excluded admin account is the
only evaluation evidence available today. Actually exercising either policy requires signing in
as `alice.admin` or `bob.reader` at least once.

**Finding — Security Defaults is enabled and already enforcing baseline MFA.** Separate from
both custom CA policies, this tenant has **Security Defaults** enabled, which requires MFA
tenant-wide today — not report-only, not pending. Baseline MFA enforcement already exists in
this tenant; `require-mfa-all-users` is a more granular, still-validating replacement layered on
top of that baseline, not the only thing standing between this tenant and unauthenticated access.

**Controls:**
- NIST 800-53 **AU-2** (Event Logging) — met: Entra natively generates and retains sign-in and
  Conditional Access evaluation events; no configuration was required to enable this.
- NIST 800-53 **AU-6** (Audit Review, Analysis, and Reporting) — met: this review of the sign-in
  and CA evaluation logs directly surfaced an undocumented policy exclusion and corrected the
  record — exactly the point of log review as a control.
- NIST 800-53 **IA-2** (Identification and Authentication) — reframe: **Security Defaults already
  enforces MFA tenant-wide**, separate from and prior to the custom CA policies in steps 5 and 9,
  which remain Report-only and layered on top for more granular, risk-aware control.
- NIST 800-53 **CM-6** (Configuration Settings) — met: comparing documented policy scope against
  actual configured scope caught a real drift (the undocumented admin exclusion on
  `require-mfa-all-users`), and the record has been corrected to match reality.

---

## Evidence

All screenshots are in `screenshots/`. Tenant ID and primary domain are redacted
in all images and referred to only as `<tenant>` throughout this document.

| File | What it shows |
|------|---------------|
| `01-tenant-overview.png` | Entra ID Default Directory overview — confirms tenant, license level, user count |
| `02-user-creation-alice.png` | New user form for `alice.admin` — identity fields and account enabled |
| `03-users-list.png` | All users list — Alice, Bob, and admin account provisioned |
| `04-group-lab-readers.png` | `lab-readers` group configuration — type, membership, and member count |
| `05-role-assignment.png` | Security Reader role assignments — Alice listed at Directory scope |
| `06-conditional-access-policy.png` | CA policy configuration — assignments, grant, and session controls |
| `07-ca-policy-enabled.png` | CA policies list — `require-mfa-all-users` in Report-only state |
| `08-pim-security-reader-active-before.png` | PIM Security Reader assignments — Alice as standing Active/Direct/Permanent, before conversion |
| `09-pim-security-reader-eligible.png` | PIM Security Reader assignments — Alice as Eligible/Permanent, after conversion |
| `10-pim-security-reader-active-removed.png` | PIM Security Reader Active assignments — empty, confirming standing access removed |
| `15-pim-role-settings-before.png` | Security Reader role settings — before, no approval required to activate |
| `16-pim-role-settings-after.png` | Security Reader role settings — after, approval + justification both required to activate |
| `11-access-review-created.png` | Access Reviews list — "Reader Role Recertification," status Not started |
| `12-access-review-pending.png` | Access review results — Alice Not reviewed, system-recommended action: Deny |
| `13-access-review-completed.png` | Access review results — Alice Approved, reviewed by Global Administrator |
| `14-conditional-access-policies-list.png` | CA policies list — both policies shown, `risk-based-signin-mfa` in Report-only state |
| `17-signin-report-only-results.png` | Sign-in activity detail, Report-only tab — both custom CA policies evaluated, result "Not applied" |
| `18-require-mfa-policy-assignments.png` | `require-mfa-all-users` policy summary — assignments and session controls, confirming the "all users included and specific users excluded" scope |

---

## Control mapping

| Control | Source | How it was demonstrated |
|---------|--------|------------------------|
| AC-2: Account Management | NIST SP 800-53 | User accounts provisioned with defined attributes; group membership controls access lifecycle |
| AC-3: Access Enforcement | NIST SP 800-53 | Security Reader role assigned to alice.admin; bob.reader receives no elevated access |
| AC-6: Least Privilege | NIST SP 800-53 | Security Reader provides read-only access; P2 license assigned only to admin account |
| AC-12: Session Termination | NIST SP 800-53 | CA policy configures an 8-hour sign-in frequency, bounding session lifetime once enforced |
| IA-11: Re-authentication | NIST SP 800-53 | 8-hour sign-in frequency is the more precise fit — it forces re-authentication after a defined interval |
| IA-2: Identification and Authentication | NIST SP 800-53 | Met via Security Defaults (tenant-wide MFA already enforced today); `require-mfa-all-users` is a more granular replacement still validated in report-only, enforcement pending |
| IA-2(1): MFA — Privileged Accounts | NIST SP 800-53 | Configured; validated in report-only; enforcement pending — "All users" scope includes privileged accounts |
| IA-2(2): MFA — Non-Privileged Accounts | NIST SP 800-53 | Configured; validated in report-only; enforcement pending — "All users" scope includes standard accounts |
| CA-2: Control Assessments | NIST SP 800-53 | Met — CA policy deployed in Report-only mode to assess impact before enforcement |
| AC-2(7): Privileged User Accounts | NIST SP 800-53 | Met — Security Reader converted from standing Active assignment to PIM-eligible; no persistent access |
| AC-3: Access Enforcement (reinforced) | NIST SP 800-53 | Met — PIM Role Settings now require approver sign-off, not just self-service justification, before activation |
| AC-2(3): Disable Accounts | NIST SP 800-53 | Met — PIM-eligible assignment formally recertified via a one-time Access Review with recorded justification |
| CA-7: Continuous Monitoring | NIST SP 800-53 | Met — Access Review functions as a point-in-time assessment of a privileged assignment's continued necessity |
| AC-2(12): Account Monitoring for Atypical Usage | NIST SP 800-53 | Configured, not exercised — risk-based CA policy acts on sign-in risk signals, but no genuine risk event has occurred to validate it |
| AU-2: Event Logging | NIST SP 800-53 | Met — Entra natively generates and retains sign-in and Conditional Access evaluation events |
| AU-6: Audit Review, Analysis, and Reporting | NIST SP 800-53 | Met — sign-in log review directly surfaced an undocumented policy exclusion and corrected the record |
| CM-6: Configuration Settings | NIST SP 800-53 | Met — documented policy scope was compared against actual configured scope, catching a real drift on `require-mfa-all-users` |

---

## What I learned

Two things stood out in this lab beyond the mechanics of clicking through the portal.

First, **the identity plane and the resource plane are separate**. An Entra ID role
(like Security Reader) controls what you can see and do within the identity directory
itself — users, groups, audit logs, security alerts. An Azure RBAC role (like Reader
on a subscription) controls what you can see within Azure resources — VMs, storage,
networking. They use different assignment interfaces, different scopes, and different
permission models. Conflating them is a common misconfiguration; understanding the
boundary is foundational to any cloud IAM audit.

Second, **Conditional Access policy deployment has a defined lifecycle for a reason**.
Report-only → pilot group → all users is not bureaucratic caution — it is the correct
engineering approach. A CA policy set directly to "On" for all users with no prior
validation is how organizations lock their admins out at 2 a.m. The Report-only state
exists precisely because the blast radius of a misconfigured CA policy is the entire
tenant. That design decision maps directly to how change management controls work in
practice.
