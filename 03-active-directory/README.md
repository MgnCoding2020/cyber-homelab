# Lab 04 — Active Directory

> **Status:** In progress
> **Where:** VM — Windows Server 2022 Evaluation (`lab-dc-01`), all changes inside the Hyper-V guest

## Problem

_To be completed when lab begins._

## What I did

_To be completed._

## Evidence

- `screenshots/` — numbered screenshots of key setup and configuration steps.
- `scripts/` — cleaned/reference PowerShell for each configuration phase (network config, AD DS
  promotion, OU/GPO setup), matching what was actually run.
- `transcripts/` — raw `Start-Transcript` logs captured live inside the VM during each phase,
  as evidence the commands were actually executed (not just documented after the fact). Sanitized
  before commit — see note below.

**Sanitization note:** transcripts capture everything typed and displayed, including full command
output. Before committing, review each transcript for anything that shouldn't be public: real
passwords (never type one directly into a command that gets logged — use `Get-Credential` or
`Read-Host -AsSecureString` instead), and mask any internal IPs consistent with the rest of the repo.

## Control mapping

| Control | Source | Relevance |
|---------|--------|-----------|
| AC-2: Account Management | NIST SP 800-53 | AD user and group lifecycle management |
| CM-6: Configuration Settings | NIST SP 800-53 | Group Policy Objects enforcing baseline settings |
| AU-2: Event Logging | NIST SP 800-53 | Audit policy configuration via GPO |

## What I learned

_To be completed._
