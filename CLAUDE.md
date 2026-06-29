# CLAUDE.md — Cyber Home Lab

> Project brief for Claude Code. Read this first every session. It defines the
> goal, the one hard safety rule, the repo layout, the conventions, and the
> lab roadmap. Keep this file free of secrets — it ships with the repo.

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

- CompTIA **A+, Network+, Security+** certified; pursuing a B.A. in
  Cybersecurity. I know the vocabulary and the concepts — the exams were
  memorization-heavy, so I'm now building the **hands-on skills** they didn't.
- So: don't over-explain basic terminology, but **do** connect each step to the
  concrete commands and to the **control framework behind it**. I can follow
  PowerShell and a CLI; I often want the *why*, not just the *how*.
- Goal: an entry-level GRC / security analyst role within a few months. This is a
  **gradual, months-long build** — no need to rush or cram.

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
├─ .gitignore
├─ 00-environment/           # Lab 01: host/VM setup notes
│    └─ README.md
├─ 01-cloud-identity/        # Lab 02: Entra ID / Azure   (host, browser)
│    ├─ README.md
│    ├─ screenshots/
│    └─ notes/
├─ 02-networking/            # Lab 03: Wireshark / nmap    (VM)
│    ├─ README.md
│    ├─ captures/            # .pcapng
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
└─ docs/                     # Cross-cutting: glossary, crosswalk, POA&M
     ├─ glossary.md
     └─ poam.md
```

Numbered folders enforce the learning order and read cleanly top-to-bottom. This
generalizes the proven `controls / automation / evidence / mapping / docs`
pattern from my existing 800-171 lab.

---

## Conventions

- **READMEs are portfolio pieces.** Write each lab's README as if a hiring manager
  will read it: the *problem*, *what I did*, the *evidence* (a screenshot or
  output), the *control it maps to*, and *one thing I learned*. Keep it concise
  and scannable.
- **Secrets hygiene is a security control, not housekeeping.** Never commit
  credentials, tokens or PATs, private keys, real internal IPs, hostnames, Entra
  **tenant IDs**, or Azure **subscription IDs**. Respect `.gitignore`. If any of
  these appear in content about to be committed, **flag it before the commit.**
- **Sanitize evidence.** Mask IPs, usernames, and tenant/subscription IDs in
  screenshots and command output before committing anything that may go public.
- **Commit messages:** scoped and descriptive, e.g.
  `02-networking: TCP handshake capture + notes`.
- **Documentation style:** articulate, well-structured prose; minimal fluff.
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

- **Map every hands-on step back to a control or framework** where relevant
  (NIST 800-171/800-53, specific STIG IDs). That framing *is* the GRC skill I'm
  building — treat it as a first-class part of each answer, not an afterthought.
- **Label HOST vs VM** on every command (see the rule above).
- When I paste nmap output, a Wireshark detail, or a STIG finding, **explain it at
  the layer that builds intuition**, not just a dictionary definition.
- **Teach the *why* alongside the *how*** — I want transferable understanding, not
  copy-paste.
- Help me keep lab READMEs and the front-door index current as I finish each lab.
- Never suggest host-modifying changes. When in doubt, ask which machine I'm on.
