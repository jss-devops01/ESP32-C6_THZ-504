<#
.SYNOPSIS
    Discovers unknown CAN properties from ESP32 ESPHome logs and generates
    ready-to-paste C++ and YAML stubs for property.h and thz504.yaml.

.DESCRIPTION
    Parses UNKNOWN_PROPERTY log blocks produced by the THZ504 firmware.
    For each unknown property ID it collects all observed raw values,
    infers the most likely encoding type, cross-references against the
    already-registered properties in src/property.h, and outputs:
      • a summary table  (console)
      • PROPERTY() macros (console + optional -OutputFile)
      • wp_generic.yaml !include lines (console + optional -OutputFile)

.PARAMETER LogFile
    Path to a captured ESPHome log file.
    Tip: capture with:
        esphome logs esp32-c6-thz504.yaml 2>&1 | Tee-Object esp32_logs.txt

.PARAMETER PropertyHeader
    Path to src/property.h  (default: auto-detected relative to this script).

.PARAMETER OutputFile
    Optional path to write the generated stubs (in addition to console output).

.PARAMETER MinObservations
    Minimum number of times a property must be observed before it is reported.
    Default: 1.

.EXAMPLE
    # Analyze a captured log
    .\analyze-unknown-properties.ps1 -LogFile .\esp32_logs.txt

.EXAMPLE
    # Capture live and pipe directly (Ctrl-C to stop)
    esphome logs esp32-c6-thz504.yaml 2>&1 | .\analyze-unknown-properties.ps1

.EXAMPLE
    # Write stubs to a file and only show properties seen >= 3 times
    .\analyze-unknown-properties.ps1 -LogFile .\esp32_logs.txt -MinObservations 3 -OutputFile .\new_properties.txt
#>

[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline = $true)]
    [string]$LogFile = "",

    [string]$PropertyHeader = "",

    [string]$OutputFile = "",

    [int]$MinObservations = 1
)

# ---------------------------------------------------------------------------
# Resolve paths
# ---------------------------------------------------------------------------
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

if (-not $PropertyHeader) {
    $PropertyHeader = Join-Path $scriptDir "src\property.h"
}

# ---------------------------------------------------------------------------
# Step 1 — Read input (file or stdin)
# ---------------------------------------------------------------------------
$logLines = @()

if ($LogFile -and (Test-Path $LogFile)) {
    Write-Host "Reading log file: $LogFile" -ForegroundColor Cyan
    $logLines = Get-Content -Path $LogFile -Encoding UTF8
}
elseif ($MyInvocation.ExpectingInput) {
    # Piped input — collect all lines first
    $logLines = @($input)
}
else {
    Write-Host ""
    Write-Host "ESP32 Unknown CAN Properties Analyzer" -ForegroundColor Green
    Write-Host "Usage:  .\analyze-unknown-properties.ps1 -LogFile <path>" -ForegroundColor Yellow
    Write-Host "        esphome logs esp32-c6-thz504.yaml 2>&1 | .\analyze-unknown-properties.ps1" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "No log input provided." -ForegroundColor Red
    exit 1
}

# ---------------------------------------------------------------------------
# Step 2 — Parse src/property.h to collect already-known property IDs
# ---------------------------------------------------------------------------
$knownProperties = @{}   # key: 0x???? (lower), value: name

if (Test-Path $PropertyHeader) {
    $headerContent = Get-Content -Path $PropertyHeader -Raw
    $macroPattern = [regex]'PROPERTY\(\s*(\w+)\s*,\s*(0x[0-9a-fA-F]+)'
    foreach ($m in $macroPattern.Matches($headerContent)) {
        $propName = $m.Groups[1].Value
        $propId   = [Convert]::ToInt32($m.Groups[2].Value, 16)
        $key      = "0x{0:x4}" -f $propId
        $knownProperties[$key] = $propName
    }
    Write-Host "Loaded $($knownProperties.Count) known properties from property.h" -ForegroundColor Cyan
}
else {
    Write-Host "Warning: property.h not found at '$PropertyHeader' - cross-reference skipped." -ForegroundColor Yellow
}

# ---------------------------------------------------------------------------
# Step 3 — Parse the log lines
#
# The firmware emits two complementary log formats for unknown properties:
#
# Format A — UNKNOWN_PROPERTY block (multi-line):
#   [HH:MM:SS][W][UNKNOWN_PROPERTY:???]: Unknown Property Detected!
#   [HH:MM:SS][W][UNKNOWN_PROPERTY:???]: CAN Member: Kessel (0x180)
#   [HH:MM:SS][W][UNKNOWN_PROPERTY:???]: Property ID: 0x019a
#   [HH:MM:SS][W][UNKNOWN_PROPERTY:???]: Raw Value: 200 (0x00c8)
#   [HH:MM:SS][W][UNKNOWN_PROPERTY:???]: Decimal Value: 20.00
#   [HH:MM:SS][W][UNKNOWN_PROPERTY:???]: Raw CAN Frame: [...]
#
# Format B — Communication INFO (single line, also appears for known props):
#   [...][I][Communication:???]: Decoded: CAN Member=Kessel CANId=0x180 Property=UNKNOWN (0x019a) Raw=200 (0x00c8)
# ---------------------------------------------------------------------------

# Stores: key = property ID string (0x019a), value = hashtable of observations
$unknownProps = @{}

# State machine for multi-line block (Format A)
$inBlock    = $false
$blockId    = ""
$blockMember= ""
$blockRaw   = 0
$blockDec   = 0.0
$blockFrame = ""

foreach ($line in $logLines) {

    # --- Format A parsing ---
    if ($line -match 'Unknown Property Detected!') {
        $inBlock     = $true
        $blockId     = ""
        $blockMember = ""
        $blockRaw    = 0
        $blockDec    = 0.0
        $blockFrame  = ""
        continue
    }

    if ($inBlock) {
        if ($line -match 'CAN Member:\s*(\w+)') {
            $blockMember = $Matches[1]
        }
        elseif ($line -match 'Property ID:\s*(0x[0-9a-fA-F]+)') {
            $blockId = $Matches[1].ToLower()
        }
        elseif ($line -match 'Raw Value:\s*(\d+)') {
            $blockRaw = [int]$Matches[1]
        }
        elseif ($line -match 'Decimal Value:\s*([\d.]+)') {
            $blockDec = [double]$Matches[1]
        }
        elseif ($line -match 'Raw CAN Frame:\s*\[([^\]]+)\]') {
            $blockFrame = $Matches[1].Trim()
        }
        elseif ($line -match '={5,}' -and $blockId -ne "") {
            # End of block — record observation
            $inBlock = $false
            if (-not $unknownProps.ContainsKey($blockId)) {
                $unknownProps[$blockId] = @{
                    Id          = $blockId
                    Member      = $blockMember
                    RawValues   = [System.Collections.Generic.List[int]]::new()
                    DecValues   = [System.Collections.Generic.List[double]]::new()
                    Frames      = [System.Collections.Generic.List[string]]::new()
                    Count       = 0
                }
            }
            $entry = $unknownProps[$blockId]
            $entry.RawValues.Add($blockRaw)
            $entry.DecValues.Add($blockDec)
            if ($blockFrame) { $entry.Frames.Add($blockFrame) }
            $entry.Count++
        }
        continue
    }

    # --- Format B parsing (Communication INFO line) ---
    if ($line -match '\[Communication[^\]]*\].*Property=UNKNOWN\s*\(?(0x[0-9a-fA-F]+)\)?\s+Raw=(\d+)') {
        $propId  = $Matches[1].ToLower()
        $rawVal  = [int]$Matches[2]

        # Also try to extract CAN member from same line
        $member = "Unknown"
        if ($line -match 'CAN Member=(\w+)') { $member = $Matches[1] }

        if (-not $unknownProps.ContainsKey($propId)) {
            $unknownProps[$propId] = @{
                Id        = $propId
                Member    = $member
                RawValues = [System.Collections.Generic.List[int]]::new()
                DecValues = [System.Collections.Generic.List[double]]::new()
                Frames    = [System.Collections.Generic.List[string]]::new()
                Count     = 0
            }
        }
        $e = $unknownProps[$propId]
        $e.RawValues.Add($rawVal)
        $e.DecValues.Add($rawVal * 0.1)
        $e.Count++
    }
}

# ---------------------------------------------------------------------------
# Step 4 — Enrich each entry: compute statistics and infer encoding type
# ---------------------------------------------------------------------------
function Get-InferredType {
    param([System.Collections.Generic.List[int]]$values)

    if ($values.Count -eq 0) { return "et_default" }

    $distinct = $values | Sort-Object -Unique
    $min = ($values | Measure-Object -Minimum).Minimum
    $max = ($values | Measure-Object -Maximum).Maximum

    # Boolean: only 0 and 1
    if ($distinct.Count -le 2 -and ($distinct | Where-Object { $_ -ne 0 -and $_ -ne 1 }).Count -eq 0) {
        return "et_bool"
    }

    # Little-endian hint: low byte is always 0x00, variation in high byte only
    $lowBytes  = $values | ForEach-Object { $_ -band 0xFF }
    $highBytes = $values | ForEach-Object { ($_ -shr 8) -band 0xFF }
    $lowDistinct = ($lowBytes | Sort-Object -Unique).Count
    if ($lowDistinct -eq 1 -and $lowBytes[0] -eq 0 -and ($highBytes | Sort-Object -Unique).Count -gt 1) {
        return "et_little_endian"
    }

    # Decimal (×0.1) hint: all values in a range plausible for temperatures (-500..+1000 raw = -50..100°C)
    # and divisible by 1 (no obvious sub-unit)
    if ($min -ge -500 -and $max -le 1000 -and $values.Count -gt 2) {
        return "et_dec_val    # e.g. value*0.1 => $(($min*0.1).ToString('F1'))..$(($max*0.1).ToString('F1'))"
    }

    # Centesimal (×0.01)
    if ($min -ge -10000 -and $max -le 10000 -and $values.Count -gt 2) {
        return "et_cent_val   # e.g. value*0.01 => $(($min*0.01).ToString('F2'))..$(($max*0.01).ToString('F2'))"
    }

    return "et_default"
}

$results = @()
foreach ($entry in $unknownProps.Values) {
    if ($entry.Count -lt $MinObservations) { continue }

    $rawVals = $entry.RawValues
    $stats = $rawVals | Measure-Object -Minimum -Maximum -Average
    $isKnown = $knownProperties.ContainsKey($entry.Id)

    $results += [PSCustomObject]@{
        Id            = $entry.Id
        Member        = $entry.Member
        Count         = $entry.Count
        Min           = $stats.Minimum
        Max           = $stats.Maximum
        Avg           = [math]::Round($stats.Average, 2)
        InferredType  = Get-InferredType -values $rawVals
        AlreadyKnown  = $isKnown
        KnownName     = if ($isKnown) { $knownProperties[$entry.Id] } else { "" }
        SampleFrame   = if ($entry.Frames.Count -gt 0) { $entry.Frames[0] } else { "" }
    }
}

$results = $results | Sort-Object Id

# ---------------------------------------------------------------------------
# Step 5 — Display summary
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "=======================================================" -ForegroundColor Green
Write-Host "  ESP32 Unknown CAN Properties - Analysis Report" -ForegroundColor Green
Write-Host "=======================================================" -ForegroundColor Green
Write-Host ""

if ($results.Count -eq 0) {
    Write-Host "No unknown properties found (min observations: $MinObservations)." -ForegroundColor Yellow
    exit 0
}

# Split into truly new vs already-known-but-still-showing-as-UNKNOWN
$newProps   = $results | Where-Object { -not $_.AlreadyKnown }
$knownProps = $results | Where-Object { $_.AlreadyKnown }

if ($knownProps.Count -gt 0) {
    Write-Host "--- Properties already in property.h but still seen as UNKNOWN ---" -ForegroundColor Yellow
    Write-Host "(These may be missing the #if defined(THZ_504) guard or the type is wrong)" -ForegroundColor DarkYellow
    Write-Host ""
    foreach ($p in $knownProps) {
        Write-Host ("  {0,-10} => {1} (seen {2}x, raw min={3} max={4})" -f `
            $p.Id, $p.KnownName, $p.Count, $p.Min, $p.Max) -ForegroundColor DarkYellow
    }
    Write-Host ""
}

if ($newProps.Count -eq 0) {
    Write-Host "No genuinely new properties found." -ForegroundColor Green
    exit 0
}

Write-Host ("Found {0} new unknown propert{1}:" -f $newProps.Count, $(if($newProps.Count -eq 1){"y"}else{"ies"})) -ForegroundColor Cyan
Write-Host ""

# Table header
$col = @(
    @{ Label="PropertyID"; Width=12 }
    @{ Label="Member";     Width=10 }
    @{ Label="Seen";       Width=6  }
    @{ Label="Min";        Width=7  }
    @{ Label="Max";        Width=7  }
    @{ Label="Avg";        Width=8  }
    @{ Label="Dec(Min)";   Width=10 }
    @{ Label="Dec(Max)";   Width=10 }
    @{ Label="InferredType"; Width=30 }
)

$header = ($col | ForEach-Object { $_.Label.PadRight($_.Width) }) -join " "
$divider = ($col | ForEach-Object { "-" * $_.Width }) -join " "
Write-Host $header -ForegroundColor White
Write-Host $divider

foreach ($p in $newProps) {
    $decMin = ($p.Min * 0.1).ToString("F1")
    $decMax = ($p.Max * 0.1).ToString("F1")
    $row = @(
        $p.Id.PadRight(12)
        $p.Member.PadRight(10)
        ([string]$p.Count).PadRight(6)
        ([string]$p.Min).PadRight(7)
        ([string]$p.Max).PadRight(7)
        ([string]$p.Avg).PadRight(8)
        $decMin.PadRight(10)
        $decMax.PadRight(10)
        $p.InferredType.PadRight(30)
    )
    Write-Host ($row -join " ")
}

# ---------------------------------------------------------------------------
# Step 6 — Generate C++ PROPERTY() stubs for property.h
# ---------------------------------------------------------------------------
$cppLines = [System.Collections.Generic.List[string]]::new()
$cppLines.Add("")
$cppLines.Add("// ============================================================")
$cppLines.Add("// Auto-generated stubs - add inside struct Property (property.h)")
$cppLines.Add("// under #if defined(THZ_504)")
$cppLines.Add("// Review name, type, and range before committing!")
$cppLines.Add("// ============================================================")
$cppLines.Add("")

foreach ($p in $newProps) {
    $nameStub = "UNKNOWN_{0}" -f ($p.Id -replace "0x","").ToUpper()
    # Extract just the type token (first word before any comment)
    $typeToken = ($p.InferredType -split '\s')[0]
    if ($typeToken -eq "et_default") {
        $cppLines.Add("    PROPERTY($nameStub, $($p.Id));   // src=$($p.Member) seen=$($p.Count) raw=$($p.Min)..$($p.Max)")
    } else {
        $cppLines.Add("    PROPERTY($nameStub, $($p.Id), Type::$typeToken);   // src=$($p.Member) seen=$($p.Count) raw=$($p.Min)..$($p.Max)")
    }
}

# ---------------------------------------------------------------------------
# Step 7 — Generate YAML !include stubs for thz504.yaml
# ---------------------------------------------------------------------------
$yamlLines = [System.Collections.Generic.List[string]]::new()
$yamlLines.Add("")
$yamlLines.Add("  # ============================================================")
$yamlLines.Add("  # Auto-generated stubs - add to packages: section in thz504.yaml")
$yamlLines.Add("  # Review icon, unit, and update_interval before committing!")
$yamlLines.Add("  # ============================================================")
$yamlLines.Add("")

foreach ($p in $newProps) {
    $nameStub = "UNKNOWN_{0}" -f ($p.Id -replace "0x","").ToUpper()
    $typeToken = ($p.InferredType -split '\s')[0]

    switch ($typeToken) {
        "et_bool" {
            $yamlLines.Add("  ${nameStub}:  !include { file: wp_binary.yaml, vars: { name: `"${nameStub}`" }}")
        }
        "et_dec_val" {
            $yamlLines.Add("  ${nameStub}:  !include { file: wp_temperature.yaml, vars: { property: `"${nameStub}`" }}  # verify unit/icon")
        }
        default {
            $yamlLines.Add("  ${nameStub}:  !include { file: wp_generic.yaml, vars: { property: `"${nameStub}`", icon: `"mdi:help-circle`", unit: `"`", update_interval: `$interval_slow }}")
        }
    }
}

# ---------------------------------------------------------------------------
# Step 8 — Output stubs to console and optionally to file
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host "  GENERATED STUBS" -ForegroundColor Cyan
Write-Host "=======================================================" -ForegroundColor Cyan

Write-Host ""
Write-Host ">>> property.h  (inside struct Property, under #if defined(THZ_504))" -ForegroundColor Green
$cppLines | ForEach-Object { Write-Host $_ }

Write-Host ""
Write-Host ">>> thz504.yaml  (inside packages:)" -ForegroundColor Green
$yamlLines | ForEach-Object { Write-Host $_ }

if ($OutputFile) {
    $allOutput = $cppLines + $yamlLines
    $allOutput | Set-Content -Path $OutputFile -Encoding UTF8
    Write-Host ""
    Write-Host "Stubs written to: $OutputFile" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "=== Next steps ===" -ForegroundColor Yellow
Write-Host "1. Rename UNKNOWN_XXXX to a meaningful name (check the THZ504 manual / community wiki)"
Write-Host "2. Verify the inferred Type by observing value range and comparing to known sensors"
Write-Host "3. Add the PROPERTY() line to src/property.h under #if defined(THZ_504)"
Write-Host "4. Add the !include line to yaml/thz504.yaml under packages:"
Write-Host "5. Flash and observe - if the value looks correct, keep it; otherwise adjust Type"
Write-Host "6. Remove the UNKNOWN_ prefix and give the property its final name"
Write-Host ""
Write-Host "Done!" -ForegroundColor Green
