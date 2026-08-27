# Lab 06 — SharePoint Administration (Governance & Access Control)

> **Status:** In progress — Day 1 done (license/role assignment, site creation, permission
> inheritance); Days 2–4 (sharing policy, sensitivity label, access reports) remaining
> **Where:** Host (browser) — SharePoint admin center and M365 admin center are cloud-hosted;
> no local install, same host-only pattern as Lab 02's cloud identity work

## Problem

SharePoint Online permissions, external sharing, and information governance are some of the
most common findings in a real Microsoft 365 audit — over-shared sites and unmanaged external
links show up constantly in access reviews. This lab builds hands-on SharePoint admin skills
to round out the identity/access work from Lab 02.

## Environment

The Microsoft 365 Developer Program sandbox (originally planned) didn't qualify for this account,
so this lab instead uses a **Microsoft 365 E3 30-day free trial** added directly to the existing
tenant from Lab 02 — one tenant, one admin center, no separate reclamation clock to track. E3 covers the full SharePoint Online admin surface (sites, permissions, external sharing,
reports) plus basic Azure Information Protection P1 labeling; it does **not** include Microsoft
Purview DLP, which is an E5-only capability — noted below as a scope substitution rather than
silently dropped.

## What I did

**Day 1 — foundation.** Assigned an E3 license and the **SharePoint Administrator** role to
`alice.admin` (scoped role, not Global Admin — least privilege for day-to-day site work).
Created two sites representing different real-world templates: a Team site (`Compliance-Evidence`,
backed by an M365 group and its own default document library) and a Communication site
(`GRC-Portal`, broadcast-style). Inside `Compliance-Evidence`, created a second document library,
`Restricted-Evidence`, and broke its permission inheritance from the parent site — copying the
site's default groups, then explicitly granting `alice.admin` **Edit** access. `bob.reader` was
never added as a site member, so he has no access to the library by omission; confirmed via the
library's own permissions list, which shows only `alice.admin` and the three `Compliance-Evidence`
groups — no `bob.reader` entry anywhere.

## Evidence

| # | File | Shows |
|---|------|-------|
| 01 | `01-alice-e3-license-assignment.png` | E3 license assigned to `alice.admin` |
| 02 | `02-alice-sharepoint-admin-role.png` | SharePoint Administrator role selected (not Global Admin) |
| 03 | `03-alice-account-summary.png` | Post-save confirmation: role persisted, licenses/groups visible |
| 04 | `04-compliance-evidence-site-creation.png` | Team site `Compliance-Evidence` creation |
| 05 | `05-grc-portal-site-details.png` | Communication site `GRC-Portal`, post-creation detail view |
| 06 | `06-active-sites-list.png` | Both sites live in SharePoint admin center's Active sites |
| 07 | `07-restricted-evidence-unique-permissions.png` | `Restricted-Evidence` library after breaking inheritance |
| 08 | `08-restricted-evidence-explicit-permissions.png` | Explicit permissions: `alice.admin` = Edit; `bob.reader` absent |

## Remaining scope

- ~~Site collection creation and permission levels~~ — done, see Evidence above
- External sharing policy: org-wide default vs. a site-level override
- A sensitivity label applied to a document library, classifying its content by sensitivity
  (E3-tier Azure Information Protection P1; auto-apply/DLP enforcement is E5-only and out of
  scope — see Environment)
- Sharing/access report review — who has access to what, and why
- Stretch: a PnP PowerShell permission-audit script, mirroring the Graph automation pattern
  from Lab 02

## Control mapping (planned)

| Control | Source | Relevance |
|---------|--------|-----------|
| AC-3: Access Enforcement | NIST SP 800-53 | Site/library permission levels |
| RA-2: Security Categorization | NIST SP 800-53 | Sensitivity label classifying a document library's content |
| AC-21: Information Sharing | NIST SP 800-53 | Org-wide vs. site-level external sharing policy |
| AU-6: Audit Record Review, Analysis, and Reporting | NIST SP 800-53 | Sharing/access report review |

## What I learned

_To be completed._
