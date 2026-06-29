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

The tenant's primary domain is `micnaulty.onmicrosoft.com`, created through the
Microsoft 365 licensing flow when activating the Entra ID P2 trial.

**Lesson from this step:** Microsoft's multiple signup flows (Azure portal vs.
Microsoft 365 admin center vs. Entra admin center) can silently create separate
tenants for the same Microsoft account. This is a real-world IAM challenge —
organizations that acquire products piecemeal often end up with fragmented tenant
sprawl that complicates identity governance. Consolidating into a single authoritative
tenant is a standard remediation.

---

### 2. User provisioning

Created two internal users in the `micnaulty` Entra ID tenant via the Microsoft 365
admin center:

| User | UPN | Purpose |
|------|-----|---------|
| Alice | `alice.admin@micnaulty.onmicrosoft.com` | Represents a security analyst with elevated read access |
| Bob | `bob.reader@micnaulty.onmicrosoft.com` | Represents a standard user with no elevated permissions |

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
- NIST 800-53 **IA-2** (Identification and Authentication) — policy enforces
  identity verification at sign-in.
- NIST 800-53 **IA-2(1)** (MFA for privileged accounts) and **IA-2(2)** (MFA for
  non-privileged accounts) — the "All users / All resources" scope satisfies both
  enhancement requirements.
- NIST 800-53 **AC-12** (Session Termination) — the 8-hour sign-in frequency
  control enforces session expiry, limiting exposure from unattended or hijacked
  sessions.
- NIST 800-53 **CA-2** (Control Assessments) — Report-only mode functions as a
  continuous assessment of the policy's effect before enforcement, consistent with
  a test-before-enforce methodology.

---

## Evidence

All screenshots are in `screenshots/`. Tenant ID and primary domain are redacted
in all images.

| File | What it shows |
|------|---------------|
| `01-tenant-overview.png` | Entra ID Default Directory overview — confirms tenant, license level, user count |
| `02-user-creation-alice.png` | New user form for `alice.admin` — identity fields and account enabled |
| `03-users-list.png` | All users list — Alice, Bob, and admin account provisioned |
| `04-group-lab-readers.png` | `lab-readers` group configuration — type, membership, and member count |
| `05-role-assignment.png` | Security Reader role assignments — Alice listed at Directory scope |
| `06-conditional-access-policy.png` | CA policy configuration — assignments, grant, and session controls |
| `07-ca-policy-enabled.png` | CA policies list — `require-mfa-all-users` in Report-only state |

---

## Control mapping

| Control | Source | How it was demonstrated |
|---------|--------|------------------------|
| AC-2: Account Management | NIST SP 800-53 | User accounts provisioned with defined attributes; group membership controls access lifecycle |
| AC-3: Access Enforcement | NIST SP 800-53 | Security Reader role assigned to alice.admin; bob.reader receives no elevated access |
| AC-6: Least Privilege | NIST SP 800-53 | Security Reader provides read-only access; P2 license assigned only to admin account |
| AC-12: Session Termination | NIST SP 800-53 | CA policy enforces 8-hour sign-in frequency, expiring sessions after one work day |
| IA-2: Identification and Authentication | NIST SP 800-53 | CA policy requires MFA for all users across all cloud apps |
| IA-2(1): MFA — Privileged Accounts | NIST SP 800-53 | "All users" scope includes privileged accounts; satisfied by the CA policy |
| IA-2(2): MFA — Non-Privileged Accounts | NIST SP 800-53 | "All users" scope includes standard accounts; satisfied by the CA policy |
| CA-2: Control Assessments | NIST SP 800-53 | CA policy deployed in Report-only mode to assess impact before enforcement |

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
