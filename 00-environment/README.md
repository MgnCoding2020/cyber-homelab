# Lab 01 — Environment & Repository Setup

## Problem

Before any technical lab can produce useful evidence, the environment itself needs to be
intentionally designed. An ad-hoc folder of screenshots doesn't demonstrate process;
a structured, versioned repository does. This lab establishes the foundation everything
else builds on.

## What I did

Designed and initialized the repository structure, tooling baseline, and host/VM discipline
that governs every subsequent lab.

**Key decisions:**

- **Numbered folders** enforce the intended learning sequence and read cleanly top-to-bottom.
- **Separate `evidence/`, `automation/`, and `mapping/` subdirectories** in each lab mirror the
  structure a GRC practitioner would use: raw controls → automated checks → documented evidence
  → framework crosswalk.
- **Host stays clean:** the host machine (where proctored exams run) does not receive any
  configuration changes, hardening, or scanning. All system-level work happens in the Hyper-V VM.
  This separation maps to a real separation-of-duties control and is enforced throughout.
- **`.gitignore` designed upfront** to block OS artifacts, raw packet captures, STIG backup files,
  VM export artifacts, and a secrets catch-all — so secrets hygiene is a default, not an afterthought.

---

## Setup walkthrough

The following commands were run on the **HOST** machine (PowerShell) to establish the repository
structure. They are shown here to document process and to make the setup reproducible.

### 1. Repository initialization

The git repository was created locally via GitHub Desktop, then cloned into the working directory.

```powershell
# HOST — verify git is available
git --version
# git version 2.x.x

# Clone the newly created GitHub repo (replace <username> with your own)
git clone https://github.com/<username>/cyber-homelab.git
cd cyber-homelab
```

### 2. Folder structure

```powershell
# HOST — create the full lab directory tree in one pass
$folders = @(
    "00-environment",
    "01-cloud-identity\screenshots",
    "01-cloud-identity\notes",
    "02-networking\captures",
    "02-networking\scans",
    "02-networking\screenshots",
    "03-active-directory\scripts",
    "03-active-directory\screenshots",
    "04-stig-compliance\controls",
    "04-stig-compliance\automation",
    "04-stig-compliance\evidence",
    "04-stig-compliance\mapping",
    "docs"
)
foreach ($f in $folders) {
    New-Item -ItemType Directory -Force -Path $f | Out-Null
}
```

`New-Item -Force` creates parent directories automatically and does not error if the path already
exists — safe to re-run.

### 3. Baseline files

```powershell
# HOST — create placeholder .gitkeep files so empty dirs are tracked by git
$emptyDirs = @(
    "01-cloud-identity\screenshots",
    "01-cloud-identity\notes",
    "02-networking\captures",
    "02-networking\scans",
    "02-networking\screenshots",
    "03-active-directory\scripts",
    "03-active-directory\screenshots",
    "04-stig-compliance\controls",
    "04-stig-compliance\automation",
    "04-stig-compliance\evidence",
    "04-stig-compliance\mapping"
)
foreach ($d in $emptyDirs) {
    New-Item -ItemType File -Force -Path "$d\.gitkeep" | Out-Null
}
```

Git does not track empty directories. `.gitkeep` is a zero-byte convention file that preserves
directory structure in the repository without adding any meaningful content.

### 4. Initial commit

```powershell
# HOST
git add .
git status          # review what's staged before committing
git commit -m "00-environment: repo structure, .gitignore, baseline READMEs"
git push origin main
```

---

## Evidence

The repository structure itself is the evidence for this lab. Reviewing the commit history
(`git log --oneline`) shows the incremental build of the environment from an empty repo.

---

## Control mapping

| Control | Source | Relevance |
|---------|--------|-----------|
| CM-2: Baseline Configuration | NIST SP 800-53 | The repo structure and `.gitignore` define a controlled, documented baseline for all lab artifacts. |
| CM-3: Configuration Change Control | NIST SP 800-53 | All changes are version-controlled via git; commit messages provide a change log. |
| PL-2: System Security Plan | NIST SP 800-53 | `CLAUDE.md` and this README collectively define the lab's scope, constraints, and operating rules — the functional equivalent of an SSP for a small system. |

---

## What I learned

Designing the folder structure before writing a single lab step forced me to think about the
*output* of each lab — what evidence would exist, where it would live, and how it would be
reviewed — before I started producing it. That's exactly how a GRC practitioner approaches
a compliance program: define the framework first, then collect evidence to it.
