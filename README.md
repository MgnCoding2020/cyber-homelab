# Cyber Home Lab

I built this lab to bridge the gap between certification theory and real-world practice. Each section is a structured exercise in a core security domain — cloud identity, networking, Active Directory, and STIG-based hardening — producing genuine configuration, working evidence, and control-framework mappings rather than tutorial screenshots.

Every lab README explains the problem, what I did, the evidence that supports it, the control framework it maps to, and one concrete thing I took away from it. The goal is a portfolio that reads like an audit trail, not a slideshow.

---

## Skills demonstrated

| Domain | Tools / Techniques |
|--------|--------------------|
| Cloud Identity & IAM | Microsoft Entra ID, Azure RBAC, Conditional Access |
| Network Analysis | Wireshark (protocol dissection, TCP/DNS/HTTP), nmap |
| Active Directory | Windows Server, DC promotion, GPO, user/group management |
| STIG Compliance | Hardening application, evidence collection, POA&M |
| Control Mapping | NIST SP 800-171, NIST SP 800-53, DISA STIGs, CMMC |

---

## Lab index

| # | Lab | Status | Framework mapping |
|---|-----|--------|-------------------|
| 01 | [Environment & Repo Setup](00-environment/) | Complete | CM-2, PL-2 |
| 02 | [Cloud Identity (Entra / Azure)](01-cloud-identity/) | Complete | AC-2, AC-2(3), AC-2(7), AC-2(12), AC-3, AC-6, AC-12, IA-2, IA-2(1), IA-2(2), IA-11, CA-2, CA-7 |
| 03 | [Networking](02-networking/) | Complete | SI-4, CA-7, CM-7, SC-8, SC-28, AU-12 |
| 04 | [Active Directory](03-active-directory/) | In progress | AC-2, IA-2, CM-6, AU-2 |
| 05 | [STIG & Compliance](04-stig-compliance/) | Planned | CM-6, CM-7, SI-2 |
| 06 | Capstone: Hybrid Identity | Planned | Multiple |

---

## Environment

- **Host:** Windows 10 (Extended Security Updates), Hyper-V enabled — read/analyze/document only
- **VM:** Windows 10 (Hyper-V guest) — receives all configuration changes, hardening, and scanning
- **Cloud:** Microsoft Entra ID + Azure (browser, accessed from host)
- **Tools:** Sysmon, Wireshark, nmap, STIG Viewer, VS Code, PowerShell, Git
- **Frameworks:** NIST SP 800-171, NIST SP 800-53, DISA STIGs, CMMC (future)

> **Host/VM discipline:** The host machine stays clean — it only reads, analyzes, and documents.
> All configuration changes, hardening, and scanning happen inside the VM.
> This is a deliberate constraint tied to exam-environment requirements, and mirrors a real
> separation-of-duties control.

---

## Certifications

CompTIA A+ · CompTIA Network+ · CompTIA Security+ · ITIL 4 Foundation
Pursuing B.S. in Cybersecurity and Information Assurance
