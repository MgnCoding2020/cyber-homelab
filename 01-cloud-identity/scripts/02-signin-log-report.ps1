<#
Pulls Entra ID sign-in log entries via Microsoft Graph and writes a
pre-masked CSV summary - automates the manual sign-in / Conditional
Access evaluation review done by hand in step 10 of this lab (AU-2, AU-6
evidence), so it's repeatable instead of a one-time screenshot pass.

Run in Azure Cloud Shell (PowerShell) or any machine with the
Microsoft.Graph module installed. Requires an account with at least the
Reports Reader or Security Reader role.

UPNs and IP addresses are masked before they ever touch disk - still
re-check the output before it leaves Cloud Shell (see CLAUDE.md secrets
hygiene).

Corresponding evidence: transcripts/02-signin-log-report.txt
#>

param(
    [int]$DaysBack = 7,
    [string]$OutputPath = "./signin-log-report.csv"
)

Start-Transcript -Path "./02-signin-log-report.txt"

if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Reports)) {
    Write-Host "Installing Microsoft.Graph.Reports module (current user scope)..."
    Install-Module Microsoft.Graph.Reports -Scope CurrentUser -Force
}
Import-Module Microsoft.Graph.Reports

Connect-MgGraph -Scopes "AuditLog.Read.All", "Directory.Read.All" -NoWelcome

function Mask-Upn {
    param([string]$Upn)
    if (-not $Upn) { return $Upn }
    $local = $Upn.Split('@')[0]
    $prefix = if ($local.Length -ge 3) { $local.Substring(0, 3) } else { $local }
    return "$prefix***@<redacted-domain>"
}

function Mask-Ip {
    param([string]$Ip)
    if (-not $Ip) { return $Ip }
    $parts = $Ip -split '\.'
    if ($parts.Count -eq 4) { return "$($parts[0]).$($parts[1]).x.x" }
    return "<redacted-ip>"
}

function Mask-Location {
    param($Location)
    if (-not $Location -or -not $Location.CountryOrRegion) { return "" }
    return "<redacted-city>, $($Location.CountryOrRegion)"
}

$since = (Get-Date).AddDays(-$DaysBack).ToString("yyyy-MM-ddTHH:mm:ssZ")
$signIns = Get-MgAuditLogSignIn -Filter "createdDateTime ge $since" -All

$rows = $signIns | ForEach-Object {
    [PSCustomObject]@{
        DateTimeUtc             = $_.CreatedDateTime
        UserPrincipalName       = Mask-Upn $_.UserPrincipalName
        AppDisplayName          = $_.AppDisplayName
        IPAddress               = Mask-Ip $_.IpAddress
        Location                = Mask-Location $_.Location
        Status                  = if ($_.Status.ErrorCode -eq 0) { "Success" } else { "Failure ($($_.Status.ErrorCode))" }
        ConditionalAccessStatus = $_.ConditionalAccessStatus
        RiskLevelDuringSignIn   = $_.RiskLevelDuringSignIn
    }
}

$rows | Export-Csv -Path $OutputPath -NoTypeInformation

Write-Host "Wrote $($rows.Count) sign-in events (last $DaysBack days) to $OutputPath"

Disconnect-MgGraph | Out-Null

Stop-Transcript
