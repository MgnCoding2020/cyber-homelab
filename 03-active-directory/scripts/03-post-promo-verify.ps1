<#
Lab 04 - Phase 3: Post-promotion verification for lab-dc-01
Confirms the forest/domain came up correctly after the Phase 2 reboot.
Run inside the VM logged in as CORP\Administrator (the local Administrator
account converts into the domain Administrator account on promotion of the
first DC in a new forest, keeping the same password).
Corresponding evidence: transcripts/03-post-promo-verify.txt
#>

Start-Transcript -Path "C:\Evidence\phase3-post-promo-verify.txt"

Get-ADDomain
Get-ADForest

Stop-Transcript
