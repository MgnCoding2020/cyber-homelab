# Lab 03 — Networking (Wireshark + nmap)

> **Status:** Complete
> **Where:** VM — all captures and scans run inside Hyper-V guest (HomeEDR-lab-02)

## Problem

Network visibility is the foundation of both threat detection and compliance validation.
A defender who cannot read packet captures cannot confirm whether traffic is encrypted,
identify what services are exposed, or distinguish normal behavior from an intrusion.
This lab builds that baseline fluency — capturing the core protocol exchanges every
analyst encounters and scanning the VM's own attack surface the way an auditor or
attacker would.

---

## What I did

### 1. TCP three-way handshake capture

Ran Wireshark on the VM's Ethernet adapter (`172.18.x.x` subnet, Hyper-V internal
network). Navigated to `https://example.com` in Firefox and isolated TCP stream 0 to
capture the connection setup to `104.20.23.154:443` (Cloudflare edge).

The three-packet sequence:

| Packet | Flags | Direction | Meaning |
|--------|-------|-----------|---------|
| SYN | `[SYN]` Seq=0 | Client → Server | Initiate connection, advertise sequence number |
| SYN-ACK | `[SYN, ACK]` Seq=0 Ack=1 | Server → Client | Accept, synchronize server sequence number |
| ACK | `[ACK]` Seq=1 Ack=1 | Client → Server | Acknowledge — connection established |

The TLS handshake (Client Hello, Server Hello, Change Cipher Spec) followed immediately
after on the same stream, showing the layered relationship between TCP and TLS.

**Why it matters:** Every TCP connection — legitimate or malicious — starts with this
handshake. Detecting a flood of unanswered SYN packets is how you identify a SYN-flood
DoS. Detecting SYN packets to unusual ports or internal hosts is an early indicator of
lateral movement or port scanning.

---

### 2. DNS query/response capture

Used `nslookup example.com` from PowerShell to generate a controlled DNS exchange, then
filtered to `dns && dns.qry.name == "example.com"` to isolate the four relevant packets.

Windows issued both an A record query (IPv4) and an AAAA query (IPv6), demonstrating
real-world dual-stack resolution behavior. The responses resolved `example.com` to
Cloudflare addresses (`104.20.23.154` and `2606:4700:10::/48`).

Notably, Windows first attempted `example.com.mshome.net` (appending the
connection-specific DNS suffix) before falling back to the bare hostname — standard
DNS suffix search list behavior on Windows.

**Why it matters:** DNS is one of the most abused protocols in threat actor playbooks.
DNS exfiltration tunnels data out in query strings. Command-and-control (C2) beaconing
uses DNS to resolve dynamically generated domains. Monitoring DNS query volume, NXDOMAIN
rates, and unusual query patterns is a core detection technique.

---

### 3. HTTP traffic capture

Applied a `port 80` capture filter, then browsed with Firefox to generate HTTP traffic.
Filtered to `http && ip.addr == 146.75.125.91` to isolate a clean request/response pair.

The captured exchange was Firefox's captive portal detection (`detectportal.firefox.com`),
which is more realistic than a manually crafted request — it shows the kind of automatic
background HTTP traffic that browsers generate without user interaction.

The Hypertext Transfer Protocol detail panel showed the full request headers in plaintext:
`GET`, `Host`, `User-Agent`, `Accept-Encoding`, `Cache-Control` — all readable without
any decryption. The server responded `HTTP/1.1 200 OK (text/html)`.

**Why it matters:** HTTP carries no confidentiality. Every header, every cookie, every
form value is readable to anyone on the network path. This is why HTTPS adoption is a
compliance baseline (NIST 800-53 SC-8, SC-28) and why plain HTTP on an internal network
is a finding. This capture makes that concrete.

---

### 4. nmap host discovery

Ran `nmap -sn [VM-IP]` to confirm the VM was live on the Hyper-V internal subnet.
The scan confirmed one host up, resolved hostname `[vm-hostname].mshome.net`.

**Why it matters:** Host discovery is the first phase of any network reconnaissance.
An attacker enumerates live hosts before targeting ports. A defender runs the same scan
to validate network segmentation — hosts that appear where they shouldn't are an
immediate flag.

---

### 5. nmap service version scan

Ran `nmap -sV [VM-IP]` against the VM itself to enumerate open ports and service versions.

| Port | State | Service | Version |
|------|-------|---------|---------|
| 135/tcp | open | msrpc | Microsoft Windows RPC |
| 139/tcp | open | netbios-ssn | Microsoft Windows netbios-ssn |
| 445/tcp | open | microsoft-ds | Microsoft Windows |

These three ports are the default Windows SMB/RPC stack. All three are standard STIG
findings on internet-facing or untrusted-network-connected Windows hosts, and all three
were exploited by EternalBlue (MS17-010 / WannaCry) in 2017.

**Why it matters:** Knowing your own attack surface is a prerequisite for hardening it.
This scan output feeds directly into Lab 05 (STIG compliance), where these ports and
services will be evaluated against DISA STIG controls.

---

## Evidence

| File | What it shows |
|------|---------------|
| `screenshots/01-tcp-handshake-wireshark.png` | TCP stream 0 — SYN, SYN-ACK, ACK sequence to 104.20.23.154:443, followed by TLS handshake |
| `screenshots/02-dns-wireshark.png` | DNS A and AAAA query/response pair for example.com (4 packets, filtered) |
| `screenshots/03-http-wireshark.png` | HTTP GET request with full plaintext headers and 200 OK response |
| `scans/01-host-discovery.txt` | nmap -sn output — host up confirmation, hostname resolved |
| `scans/02-port-scan.txt` | nmap -sV output — ports 135, 139, 445 open with service versions |

All screenshots have VM IP addresses and interface identifiers redacted.

---

## Control mapping

| Control | Source | How it was demonstrated |
|---------|--------|------------------------|
| SI-4: System Monitoring | NIST SP 800-53 | Wireshark used to capture and inspect live network traffic; demonstrates the monitoring capability that detects anomalous connections |
| CA-7: Continuous Monitoring | NIST SP 800-53 | Packet capture provides the technical evidence layer for continuous monitoring — traffic is observable, not assumed |
| CM-7: Least Functionality | NIST SP 800-53 | nmap scan revealed ports 135, 139, 445 open — each represents a service that must be justified or disabled per least-functionality principle |
| SC-8: Transmission Confidentiality | NIST SP 800-53 | HTTP capture demonstrated that plaintext traffic exposes all header data; contrast with TLS stream on the TCP capture |
| SC-28: Protection of Information at Rest/Transit | NIST SP 800-53 | HTTP packet content is readable in transit; absence of encryption is a direct control gap |
| AU-12: Audit Record Generation | NIST SP 800-53 | Packet capture is a form of network audit record; demonstrates the principle that network events must be observable and recordable |

---

## What I learned

Two things sharpened my thinking in this lab beyond tool mechanics.

First, **the same scan an attacker runs is the same scan a defender runs — the difference
is authorization and intent.** Running `nmap -sV` against my own VM is the first step
in understanding what an adversary would see. Every open port is a question: is this
service necessary? Is it patched? Is it exposed to the right network segment? That mental
model — looking at your own infrastructure through an attacker's lens — is how you
prioritize hardening work, which is exactly what a GRC analyst does when reviewing
vulnerability scan results.

Second, **HTTP being readable in Wireshark in 2026 is a finding, not a curiosity.**
Even on an internal network, cleartext protocol usage is a STIG category and a NIST
800-53 SC-8 gap. The fact that Firefox's background captive portal check runs over HTTP
(not HTTPS) is a real-world example of how plaintext traffic persists even in modern
environments — and why network monitoring is a compensating control, not just a
nice-to-have.
