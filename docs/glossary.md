# Glossary

Key terms and control framework references used across the lab.

_Populated as labs progress._

---

| Term | Definition |
|------|------------|
| STIG | Security Technical Implementation Guide — DISA-published configuration standards |
| CKL | STIG Viewer checklist file format (.ckl) used to track control status |
| GPO | Group Policy Object — AD mechanism for pushing configuration to domain-joined machines |
| RBAC | Role-Based Access Control — access governed by role assignment, not individual identity |
| POA&M | Plan of Action and Milestones — document tracking open findings and remediation timelines |
| PIM | Privileged Identity Management — Entra ID P2 feature for just-in-time, time-bound, and approval-gated role activation instead of standing access |
| JIT | Just-in-Time access — a privilege is activated only when needed and expires afterward, rather than being granted permanently |
| Conditional Access (CA policy) | Entra ID engine that grants, blocks, or adds requirements (e.g., MFA) to sign-ins based on conditions like user, app, and risk |
| Report-only | A Conditional Access policy state that logs what *would* happen without enforcing it — the standard safe first step before switching a policy to On |
| Access Review | A recurring or one-time attestation process where a reviewer approves or revokes continued access/role membership, producing an auditable decision |
| Identity Protection | Entra ID P2 feature that scores sign-ins and users for risk (e.g., impossible travel, leaked credentials) and can feed that risk into Conditional Access |
| AD DS | Active Directory Domain Services — the Windows Server role that provides centralized directory, authentication, and policy for a domain |
| Forest / Domain | A forest is the top-level AD security boundary; a domain within it is the administrative unit holding users, groups, and computers |
| OU | Organizational Unit — a container within a domain used to organize objects and scope GPO links, distinct from a security group |
| DC | Domain Controller — a server running AD DS that authenticates logons and replicates directory data |
| Kerberos / NTLM | The two authentication protocols AD DS supports; Kerberos (ticket-based) is preferred, NTLM is the legacy fallback |
| DSRM | Directory Services Restore Mode — a recovery boot mode for a DC with its own separate password, used only for AD DS repair |
| AC | Access Control (NIST SP 800-53 control family) |
| CM | Configuration Management (NIST SP 800-53 control family) |
| IA | Identification and Authentication (NIST SP 800-53 control family) |
| SI | System and Information Integrity (NIST SP 800-53 control family) |
| AU | Audit and Accountability (NIST SP 800-53 control family) |
| CA | Assessment, Authorization, and Monitoring (NIST SP 800-53 control family) |
| SC | System and Communications Protection (NIST SP 800-53 control family) |
| PL | Planning (NIST SP 800-53 control family) |
| Configured vs. enforced | A GRC precision distinction: a control being *set up* (configured) is not the same claim as it *actually applying* (enforced) — e.g., a Report-only CA policy or a GPO linked to an OU with no members in it yet |
