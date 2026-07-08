# CLAUDE.md — Cyber Home Lab

> Project brief for Claude Code **and** current status snapshot. Read this first
> every session. It defines the goal, the one hard safety rule, the repo layout,
> the conventions, the lab roadmap, and the current audit state. Keep this file
> free of secrets — it ships with the repo.

---

## 📋 Current status & audit snapshot

_Last reviewed: 2026-07-07_

### Lab completion

| # | Lab | Folder | Status |
|---|-----|--------|--------|
| 01 | Environment & Repo | `00-environment/` | ✅ Complete |
| 02 | Cloud Identity (Entra / Azure) | `01-cloud-identity/` | ✅ Complete (PIM, Access Reviews, risk-based CA added) |
| 03 | Networking (Wireshark / nmap) | `02-networking/` | ✅ Complete |
| 04 | Active Directory | `03-active-directory/` | 🟡 In progress — Phases 1–4 done (network config, forest promotion, OU/group/user, GPO); Phase 5 (client join + `gpresult /r` verification) next |
| 05 | STIG & Compliance | `04-stig-compliance/` | ⬜ Planned |
| 06 | Capstone: Hybrid Identity | — | ⬜ Planned |

### Health

- The original HIGH/MEDIUM/LOW remediation queue (tenant identifier leak, VM
  hostname leak, stale index, POA&M drift, screenshot casing, GRC precision on
  the Report-only CA policy) was fully resolved in commit `c0a173f` — nothing
  open there. If new evidence gets added, re-check it against the **Conventions**
  section below rather than assuming it's still clean.
- **Per-lab control mapping (NIST SP 800-53) is the core strength** — it's what
  turns technical work into a GRC signal. Keep it first-class in every lab,
  including the *configured vs. enforced* distinction (see Lab 04's AU-2, which
  is honestly marked enforcement-pending until Phase 5's client join).
- **Entra ID P2 trial** started 2026-06-29, expires 2026-07-28 — cancel by
  **2026-07-20** to avoid the $10.80/mo charge. Entitlement Management/Access
  Packages was deliberately scoped out as too deep for this lab's
  breadth-over-depth goal; don't re-propose it unless the user raises it.

### ✅ Verified good — no action

- `.claude/` is correctly gitignored and **untracked** (confirmed via `git ls-files`).
- Scan `.txt` outputs, AD transcripts, and sysinfo file *bodies* are sanitized
  with placeholders.
- Stub README for Lab 05 is honestly marked *Planned* — no overclaiming.

### Next up

- **Lab 04 Phase 5 (VM required):** join a client VM to `corp.lab` under the
  `Computers` OU, then confirm `Audit-Policy-Baseline` actually applies via
  `gpresult /r`. **Take a Hyper-V checkpoint of the client VM before joining.**
- **Host-only, no VM needed:** Lab 02's sign-in/audit log review (AU-2, AU-6) is
  now done — it also caught and corrected an undocumented admin exclusion on
  `require-mfa-all-users` and clarified that Security Defaults, not the
  Report-only CA policies, is what's actually enforcing MFA today. Remaining
  P2 headroom before the 2026-07-20 cancel date: exercising the two Report-only
  CA policies against their real target scope (`alice.admin`/`bob.reader` have
  never signed in interactively, so neither policy has a real Success/Failure
  result yet — only "Not applied" against the excluded admin account).

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
