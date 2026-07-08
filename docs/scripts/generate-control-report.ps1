<#
Parses the Control mapping table out of every lab README and renders a
single audit-ready workbook - no cloud credentials needed, this only reads
local files. Run from anywhere; paths resolve relative to the repo root.
#>

param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")),
    [string]$OutputPath = (Join-Path $RepoRoot "docs\reports\control-mapping-report.xlsx")
)

if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
    Write-Host "Installing ImportExcel module (current user scope)..."
    Install-Module ImportExcel -Scope CurrentUser -Force
}
Import-Module ImportExcel

function Get-LabStatus {
    param([string]$ReadmePath)
    $line = Get-Content $ReadmePath | Where-Object { $_ -match '^\>\s*\*\*Status:\*\*' } | Select-Object -First 1
    if ($line -and $line -match '\*\*Status:\*\*\s*(.+)$') { return $Matches[1].Trim() }
    return 'Complete'
}

function Get-ControlMappingRows {
    param([string]$ReadmePath, [string]$LabName, [string]$LabStatus)

    $lines = Get-Content $ReadmePath
    $rows = @()
    $state = 'seeking'
    $headerColCount = 0

    foreach ($line in $lines) {
        if ($state -eq 'seeking' -and $line -match '^##\s+Control mapping') {
            $state = 'header'
            continue
        }
        if ($state -eq 'header') {
            if ($line -match '^\|') {
                $headerColCount = (($line.Trim('|') -split '\|')).Count
                $state = 'separator'
            }
            continue
        }
        if ($state -eq 'separator') {
            if ($line -match '^\|[-\s|]+\|$') { $state = 'rows' }
            continue
        }
        if ($state -eq 'rows') {
            if ($line -notmatch '^\|') { break }

            $cells = ($line.Trim('|') -split '\|') | ForEach-Object { $_.Trim() }
            if ($cells.Count -lt 3) { continue }

            $controlCell = $cells[0]
            $source      = $cells[1]
            $description = $cells[-1]
            $rowStatus   = if ($headerColCount -ge 4 -and $cells.Count -ge 4) { $cells[2] } else { '' }

            $parts = $controlCell -split ':', 2
            $controlId   = $parts[0].Trim()
            $controlName = if ($parts.Count -gt 1) { $parts[1].Trim() } else { '' }
            $family      = ($controlId -split '[\s(-]')[0]

            $rows += [PSCustomObject]@{
                Lab           = $LabName
                LabStatus     = $LabStatus
                ControlId     = $controlId
                ControlFamily = $family
                ControlName   = $controlName
                Source        = $source
                RowStatus     = $rowStatus
                Description   = $description
            }
        }
    }
    return $rows
}

$labFiles = @(
    @{ Path = "00-environment\README.md";      Name = "01 - Environment & Repo" }
    @{ Path = "01-cloud-identity\README.md";    Name = "02 - Cloud Identity" }
    @{ Path = "02-networking\README.md";        Name = "03 - Networking" }
    @{ Path = "03-active-directory\README.md";  Name = "04 - Active Directory" }
)

$allRows = @()
$labSummary = @()
foreach ($lab in $labFiles) {
    $path = Join-Path $RepoRoot $lab.Path
    if (-not (Test-Path $path)) { continue }

    $status = Get-LabStatus -ReadmePath $path
    $rows = Get-ControlMappingRows -ReadmePath $path -LabName $lab.Name -LabStatus $status
    $allRows += $rows

    $labSummary += [PSCustomObject]@{
        Lab           = $lab.Name
        Status        = $status
        ControlCount  = $rows.Count
    }
}

$outDir = Split-Path $OutputPath -Parent
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }
if (Test-Path $OutputPath) { Remove-Item $OutputPath -Force }

$labSummary | Export-Excel -Path $OutputPath -WorksheetName "Lab Status" `
    -AutoSize -BoldTopRow -FreezeTopRow -TableStyle Medium6

$allRows | Sort-Object ControlFamily, ControlId | Export-Excel -Path $OutputPath -WorksheetName "Control Mapping" `
    -AutoSize -BoldTopRow -FreezeTopRow -TableStyle Medium2 -Append

Write-Host "Report written to $OutputPath - $($allRows.Count) control rows across $($labFiles.Count) labs."
