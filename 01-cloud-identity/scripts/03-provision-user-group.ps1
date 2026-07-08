<#
Provisions a user and adds them to a group via Microsoft Graph - the
scripted equivalent of the manual account creation done by hand in
steps 2-3 of this lab. Demonstrates account management (AC-2) as
repeatable, auditable code instead of one-off portal clicks, and is
idempotent: safe to re-run against an existing user/group.

Run in Azure Cloud Shell (PowerShell) or any machine with the
Microsoft.Graph module installed. Requires an account with at least the
User Administrator role.

The temporary password is generated locally and never written to
output, transcript, or disk - communicate it to the user out-of-band.

Corresponding evidence: transcripts/03-provision-user-group.txt
#>

param(
    [Parameter(Mandatory = $true)][string]$DisplayName,
    [Parameter(Mandatory = $true)][string]$UserPrincipalName,
    [Parameter(Mandatory = $true)][string]$GroupDisplayName,
    [string]$MailNickname = ($UserPrincipalName.Split('@')[0])
)

Start-Transcript -Path "./03-provision-user-group.txt"

if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Users)) {
    Write-Host "Installing Microsoft.Graph.Users and Microsoft.Graph.Groups modules (current user scope)..."
    Install-Module Microsoft.Graph.Users, Microsoft.Graph.Groups -Scope CurrentUser -Force
}
Import-Module Microsoft.Graph.Users
Import-Module Microsoft.Graph.Groups

Connect-MgGraph -Scopes "User.ReadWrite.All", "Group.ReadWrite.All" -NoWelcome

$existingUser = Get-MgUser -Filter "userPrincipalName eq '$UserPrincipalName'" -ErrorAction SilentlyContinue
if ($existingUser) {
    Write-Host "User $UserPrincipalName already exists (Id: $($existingUser.Id)) - skipping creation."
    $user = $existingUser
}
else {
    $tempPassword = [System.Guid]::NewGuid().ToString().Substring(0, 16) + "!Aa1"
    $passwordProfile = @{
        Password                      = $tempPassword
        ForceChangePasswordNextSignIn = $true
    }
    $user = New-MgUser -DisplayName $DisplayName -UserPrincipalName $UserPrincipalName `
        -MailNickname $MailNickname -AccountEnabled -PasswordProfile $passwordProfile
    Write-Host "Created user $UserPrincipalName (Id: $($user.Id)). Temp password was generated but is not logged - relay it out-of-band."
    Remove-Variable tempPassword
}

$group = Get-MgGroup -Filter "displayName eq '$GroupDisplayName'" -ErrorAction SilentlyContinue
if (-not $group) {
    Write-Host "Group '$GroupDisplayName' not found - create it first, or check the spelling."
}
else {
    $members = Get-MgGroupMember -GroupId $group.Id -All
    if ($members.Id -contains $user.Id) {
        Write-Host "$DisplayName is already a member of $GroupDisplayName."
    }
    else {
        New-MgGroupMember -GroupId $group.Id -DirectoryObjectId $user.Id
        Write-Host "Added $DisplayName to $GroupDisplayName."
    }
}

Disconnect-MgGraph | Out-Null

Stop-Transcript
