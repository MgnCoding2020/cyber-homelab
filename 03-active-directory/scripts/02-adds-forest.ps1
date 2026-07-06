<#
Lab 04 - Phase 2: AD DS role install + forest promotion for lab-dc-01
Installs the AD Domain Services role and promotes the VM to the first
domain controller of a new forest (corp.lab). Run inside the VM as the
local Administrator (pre-promotion).
Corresponding evidence: transcripts/02-adds-forest.txt
#>

Start-Transcript -Path "C:\Evidence\phase2-adds-forest.txt"

Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

Import-Module ADDSDeployment

$dsrm = Read-Host -Prompt "DSRM password" -AsSecureString

Install-ADDSForest `
    -DomainName "corp.lab" `
    -DomainNetbiosName "CORP" `
    -SafeModeAdministratorPassword $dsrm `
    -InstallDns:$true `
    -Force:$true

# Install-ADDSForest reboots the VM automatically on completion, so
# Stop-Transcript is never reached here. Start-Transcript flushes to disk
# continuously, so the file is still complete evidence up to the reboot.
