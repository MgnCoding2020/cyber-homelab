<#
Lab 04 - Phase 1: Network configuration for lab-dc-01
Renames the freshly-installed Server 2022 VM and assigns a static IP so it can
reliably serve AD DS/DNS later. Run inside the VM as Administrator.
Corresponding evidence: transcripts/01-network-config.txt
#>

Start-Transcript -Path "C:\Lab-Evidence\01-network-config.txt"

Rename-Computer -NewName "lab-dc-01"

New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress <DC-IP> -PrefixLength 20 -DefaultGateway <GATEWAY-IP>
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses <GATEWAY-IP>

Get-NetIPConfiguration

Stop-Transcript
Restart-Computer
