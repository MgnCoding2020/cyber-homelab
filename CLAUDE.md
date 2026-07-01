# CLAUDE.md — Cyber Home Lab

> Project brief for Claude Code **and** current status snapshot. Read this first
> every session. It defines the goal, the one hard safety rule, the repo layout,
> the conventions, the lab roadmap, and the current audit state. Keep this file
> free of secrets — it ships with the repo.

---

## 📋 Current status & audit snapshot

_Last reviewed: 2026-07-01 (full file-level review)_

### Lab completion

| # | Lab | Folder | Status |
|---|-----|--------|--------|
| 01 | Environment & Repo | `00-environment/` | ✅ Complete |
| 02 | Cloud Identity (Entra / Azure) | `01-cloud-identity/` | ✅ Complete* |
| 03 | Networking (Wireshark / nmap) | `02-networking/` | ✅ Complete* |
| 04 | Active Directory | `03-active-directory/` | ⬜ Planned (next up) |
| 05 | STIG & Compliance | `04-stig-compliance/` | ⬜ Planned |
| 06 | Capstone: Hybrid Identity | — | ⬜ Planned |

*\*Labs 02–03 are technically complete but have publish-blocking hygiene fixes
open below (H1–H2). They are **not** clean to make public until those are done.*

### Health

- **Structure is solid** and reads like an audit trail, as intended.
- **Per-lab control mapping (NIST SP 800-53) is the core strength** — it's what
  turns technical work into a GRC signal. Keep it first-class in every lab.
- Completed labs (01–03) have real configuration plus evidence. Sanitization is
  mostly good (scan `.txt` outputs and sysinfo file *bodies* use placeholders
  correctly), but two identifiers slipped through in prose — see H1/H2.

### 🔴 Remediation queue — work this top-down

**HIGH — fix before the repo is ever made public or shown to a reviewer**

- **H1 — Tenant identifier leak.** `01-cloud-identity/README.md` prints the real
  Entra tenant domain/name in prose (~4 places, including two user UPNs) even
  though the file claims the domain is "redacted in all images." The images may be
  clean; the markdown is not. Replace every instance with a placeholder
  (`<tenant>.onmicrosoft.com`, UPNs as `alice.admin@<tenant>.onmicrosoft.com`).
  This is exactly the tenant-ID class the Conventions section says never to commit.
- **H2 — VM hostname leak.** The real VM hostname appears in the `02-networking/README.md`
  "Where:" header **and** in the title line of `00-environment/notes/vm-sysinfo.txt`,
  despite both claiming the hostname is redacted (the sysinfo *body* is correctly
  masked). Replace both with `[vm-hostname]`.
- **After H1/H2:** re-word the "redacted in all images" lines in both READMEs so
  the claim is actually true. A redaction claim sitting next to a live identifier
  undermines trust in every other claim in the repo.

**MEDIUM — accuracy & broken links**

- **M1 — Stale front-door index.** `README.md` lab index lists Networking (Lab 03)
  as *Planned*; it is **Complete** with full evidence. Update the status cell.
- **M2 — POA&M out of date.** `docs/poam.md` items 001 (Entra) and 002 (Wireshark)
  are still *In progress / Planned* but their labs are done. Move both to the
  "Closed items" section (currently empty) with completion dates.
- **M3 — Screenshot filename case/name.** Files on disk are uppercase `.PNG`; the
  READMEs reference lowercase `.png`. GitHub is case-sensitive, so links break once
  they're clickable. Also `03-user-list.PNG` on disk is referenced as
  `03-users-list.png`. Standardize all files to lowercase `.png` and reconcile the
  one mismatched name against the README.

**LOW — polish**

- **L1 — Credentials line.** `README.md` "Certifications" still says
  "Pursuing B.A. in Cybersecurity." Correct to **B.S. in Cybersecurity and
  Information Assurance** and add **ITIL 4 Foundation** (already fixed in this file).
- **L2 — Index mappings are subsets.** The front-door index lists fewer controls
  per lab than the lab READMEs actually map (e.g., Lab 02 README also covers
  IA-2(2) and CA-2; Lab 03 also covers CM-7 / SC-8 / SC-28 / AU-12). Optional: sync
  for completeness.

**GRC-PRECISION — sharpens the portfolio signal (do alongside L-items)**

- **P1 — Don't overstate the Report-only CA policy.** In `01-cloud-identity/README.md`,
  the Conditional Access policy is in **Report-only**, so it does **not** enforce MFA
  yet — sign-ins are logged as if it applied, but access is granted regardless.
  Mapping IA-2, IA-2(1), and IA-2(2) as *satisfied* overstates it. Reframe those
  rows as **"configured; validated in report-only; enforcement pending."** CA-2
  (assessment) is correctly *met*. Knowing configured-vs-enforced is the assessor's
  whole job — this is the highest-value single edit for GRC credibility.
- **P2 — Tighter control cite.** The 8-hour sign-in frequency maps more precisely to
  **IA-11 (Re-authentication)** than AC-12 (Session Termination). AC-12 isn't wrong
  if framed as bounding session lifetime, but adding IA-11 reads as real Rev 5 fluency.

### ✅ Verified good — no action

- `.claude/` is correctly gitignored and **untracked** (confirmed via `git ls-files`).
- Scan `.txt` outputs and the sysinfo file *bodies* are sanitized with placeholders.
- Stub READMEs for Labs 04–05 are honestly marked *Planned* — no overclaiming.

### Next up (after the HIGH items)

- **Lab 04 (Active Directory):** Windows Server eval in the VM — promote a DC, join
  a client, push a GPO. **Take a Hyper-V checkpoint first.**

---

## What this project is

A hands-on cybersecurity home lab built toward a **GRC (Governance, Risk, and
Compliance)** career. The aim is broad, practical fluency — a deliberate
"jack of all trades" across **cloud identity, networking, Active Directory, and
STIG-based compliance** — not deep specialization in any single area.

Every lab turns a concept into **real configuration plus audit-ready evidence**,
and the repository doubles as a **portfolio**. It is private now and designed so
that "going public" later is just a secrets scan and a visibility toggle — never
a retrofit.

## Who I am (calibrate explanations to this)

- CompTIA **A+, Network+, Security+** certified, plus **ITIL 4 Foundation**;
  pursuing a **B.S. in Cybersecurity and Information Assurance**. I know the
  vocabulary and the concepts — the exams were memorization-heavy, so I'm now
  building the **hands-on skills** they didn't.
- So: don't over-explain basic terminology, but **do** connect each step to the
  concrete commands and to the **control framework behind it**. I can follow
  PowerShell and a CLI; I often want the *why*, not just the *how*.
- Goal: an entry-level GRC / security analyst role within a few months. This is a
  **gradual, months-long build** — no need to rush or cram. I'm still learning;
  keep explanations grounded and don't overstate what I've done.

---

## ⚠️ The one rule that governs everything: HOST vs VM

This is a **hard safety constraint, not a preference.** My host machine must stay
clean because I sit **proctored exams** on it. Breaking this rule could disable
features or lock down the firewall in ways that break proctoring.

| Where | What belongs there |
|-------|--------------------|
| **VM** — *does the work* | Anything that **changes a setting**: firewall rules, services, Group Policy, the registry, domain join, STIG application, any hardening, nmap scanning, Wireshark capture (the capture driver is itself a system change). |
| **Host** — *kept clean* | Anything that only **reads, analyzes, or documents**: VS Code, Claude, browsers (incl. the Entra/Azure portals), STIG Viewer (it reads checklists, it does not apply them), note-taking, Git. |
| **Cloud** — *browser* | Entra ID and Azure live in Microsoft's cloud. Reached from the host browser; nothing is stored or changed locally. |

**Rules for Claude Code:**

1. On every actionable command or change, **label whether it runs on the HOST or
   the VM.**
2. **Never** suggest applying STIGs, Group Policy, firewall changes, hardening, or
   any system modification to the **host**. If a task would modify the host,
   **stop and flag it** instead of proceeding.
3. Before any hardening lab, I take a **Hyper-V checkpoint** of the VM and roll
   back afterward. Remind me if I'm about to harden without one.

---

## Environment

- **Host:** Windows 10 (Extended Security Updates enrolled), running Hyper-V.
- **VM:** Windows 10 in Hyper-V — the target for hardening, AD, and networking labs.
- **Tools:** Sysmon, Wireshark, nmap, STIG Viewer, VS Code, PowerShell, Git.
- **Cloud:** Microsoft Entra ID + Azure (free / student tier), browser-accessed.
- **Frameworks:** NIST SP 800-171, NIST SP 800-53, DISA STIGs, CMMC (future).

## Workflow

- Repo is **created locally**, added to GitHub via **GitHub Desktop**; all commits
  are made through **VS Code**.
- The **host is the "thinking" machine** (analysis, documentation, review); the
  **VM is the "doing" machine**. **Git is the bridge**: commit and push from the
  machine that did the work, pull on the other.
- The repo is **private**, structured to be shown to a reviewer (as a
  collaborator) or flipped to public later with only a secrets scan first.

---

## Repository structure

```
cyber-homelab/
├─ README.md                 # Front door: index + skills demonstrated
├─ CLAUDE.md                 # This file: brief + current status
├─ .gitignore
├─ 00-environment/           # Lab 01: host/VM setup notes
│    └─ README.md
├─ 01-cloud-identity/        # Lab 02: Entra ID / Azure   (host, browser)
│    ├─ README.md
│    ├─ screenshots/
│    └─ notes/
├─ 02-networking/            # Lab 03: Wireshark / nmap    (VM)
│    ├─ README.md
│    ├─ captures/            # .pcapng (gitignored — screenshots are the evidence)
│    ├─ scans/
│    └─ screenshots/
├─ 03-active-directory/      # Lab 04: Windows Server + AD (VM)
│    ├─ README.md
│    ├─ scripts/
│    └─ screenshots/
├─ 04-stig-compliance/       # Lab 05: hardening + evidence (VM)
│    ├─ README.md
│    ├─ controls/
│    ├─ automation/
│    ├─ evidence/
│    └─ mapping/
└─ docs/                     # Cross-cutting: glossary, POA&M
     ├─ glossary.md
     └─ poam.md
```

Numbered folders enforce the learning order and read cleanly top-to-bottom. This
generalizes the proven `controls / automation / evidence / mapping / docs`
pattern from my existing 800-171 lab. **Note:** folder numbers start at `00`, so
they run one behind the lab numbers (folder `02-networking` = Lab 03); the status
table at the top maps both.

---

## Conventions

- **READMEs are portfolio pieces.** Write each lab's README as if a hiring manager
  will read it: the *problem*, *what I did*, the *evidence* (a screenshot or
  output), the *control it maps to*, and *one thing I learned*. Keep it concise
  and scannable.
- **Secrets hygiene is a security control, not housekeeping.** Never commit
  credentials, tokens or PATs, private keys, real internal IPs, hostnames, Entra
  **tenant IDs / domains**, or Azure **subscription IDs** — in images **or in prose**.
  Respect `.gitignore`. If any of these appear in content about to be committed,
  **flag it before the commit.** (See H1/H2 above for how this slipped through.)
- **Redaction claims must be true.** If a README says something is redacted, verify
  the identifier is absent from the *text* too, not just the screenshots.
- **Sanitize evidence.** Mask IPs, usernames, hostnames, and tenant/subscription IDs
  in screenshots and command output before committing anything that may go public.
- **Evidence filenames:** lowercase, hyphenated, numbered (`01-tenant-overview.png`).
  Keep the files and the README evidence tables in exact agreement — GitHub is
  case-sensitive.
- **Commit messages:** scoped and descriptive, e.g.
  `02-networking: TCP handshake capture + notes`.
- **Documentation style:** articulate, well-structured prose; minimal fluff. Honest
  about what's a learning exercise vs. production-grade, and about *configured* vs.
  *enforced* (see P1).
- **Front-door README:** keep its lab index/status table updated as labs complete.

---

## Lab roadmap (host-first, then into the VM)

| # | Lab | Where | Focus |
|---|-----|-------|-------|
| 01 | Environment & Repo | Host | Repo design, sync workflow, tooling, baseline checkpoint |
| 02 | Cloud Identity (Entra / Azure) | Host (browser) | Tenant, users/groups/roles, RBAC, a Conditional Access policy |
| 03 | Networking | VM | Wireshark capture of TCP handshake / DNS / HTTP; nmap against the VM |
| 04 | Active Directory | VM | Windows Server eval, promote a DC, join a client, push a GPO |
| 05 | STIG & Compliance | VM | Apply a STIG, validate, collect evidence, map to 800-171 / 800-53 |
| 06 | Capstone | VM + cloud | Connect on-prem AD to Entra (hybrid identity); GRC summary |

---

## How to help me

- **Start each session by checking the remediation queue above** and offer to work
  it top-down (each item names the file and the fix). HIGH items block publishing.
- **Map every hands-on step back to a control or framework** where relevant
  (NIST 800-171/800-53, specific STIG IDs). That framing *is* the GRC skill I'm
  building — treat it as a first-class part of each answer, not an afterthought.
  Distinguish **configured** from **enforced** when describing control status.
- **Label HOST vs VM** on every command (see the rule above).
- When I paste nmap output, a Wireshark detail, or a STIG finding, **explain it at
  the layer that builds intuition**, not just a dictionary definition.
- **Teach the *why* alongside the *how*** — I want transferable understanding, not
  copy-paste.
- Help me keep lab READMEs and the front-door index current as I finish each lab,
  and keep the status snapshot at the top of this file up to date.
- Never suggest host-modifying changes. When in doubt, ask which machine I'm on.
