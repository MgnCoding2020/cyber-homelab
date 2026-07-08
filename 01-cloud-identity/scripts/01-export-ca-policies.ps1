<#
Exports every Conditional Access policy as JSON via Microsoft Graph -
policy-as-code evidence that can be diffed run over run to catch
undocumented drift (the admin exclusion the manual sign-in log review
in step 10 found the hard way).

Run in Azure Cloud Shell (PowerShell) or any machine with the
Microsoft.Graph module installed. Requires an account with at least the
Conditional Access Administrator or Security Reader role.

Corresponding evidence: transcripts/01-export-ca-policies.txt
#>

param(
    [string]$OutputPath = "./ca-policies-export.json"
)

Start-Transcript -Path "./01-export-ca-policies.txt"

if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Identity.SignIns)) {
    Write-Host "Installing Microsoft.Graph.Identity.SignIns module (current user scope)..."
    Install-Module Microsoft.Graph.Identity.SignIns -Scope CurrentUser -Force
}
Import-Module Microsoft.Graph.Identity.SignIns

Connect-MgGraph -Scopes "Policy.Read.All" -NoWelcome

$policies = Get-MgIdentityConditionalAccessPolicy -All

$policies |
    Select-Object Id, DisplayName, State, CreatedDateTime, ModifiedDateTime, Conditions, GrantControls, SessionControls |
    ConvertTo-Json -Depth 10 |
    Out-File -FilePath $OutputPath -Encoding utf8

Write-Host "Exported $($policies.Count) Conditional Access policies to $OutputPath"
Write-Host "Review the file for anything sensitive before it leaves Cloud Shell (see CLAUDE.md secrets hygiene)."

Disconnect-MgGraph | Out-Null

Stop-Transcript
