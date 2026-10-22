# Current project root (folder containing this script)
$ProjectRoot = $PSScriptRoot

$InputFile = Join-Path $ProjectRoot "input.txt"
$OutputPrefix = Join-Path $ProjectRoot "context"

# Maximum lines per output file
$MaxLinesPerFile = 1000

if (!(Test-Path $InputFile)) {
    Write-Host "input.txt not found."
    exit
}

# Remove previous context files
Get-ChildItem -Path $ProjectRoot -Filter "context-*.txt" -File |
    Remove-Item -Force

$OutputLines = New-Object System.Collections.Generic.List[string]
$FileIndex = 1

function Save-Chunk {
    param (
        [System.Collections.Generic.List[string]]$Lines,
        [int]$Index
    )

    if ($Lines.Count -eq 0) {
        return
    }

    $OutputFile = "{0}-{1:D3}.txt" -f $OutputPrefix, $Index

    $Lines | Set-Content $OutputFile -Encoding UTF8

    Write-Host "Created: $(Split-Path $OutputFile -Leaf) [$($Lines.Count) lines]"
}

$Files = Get-Content $InputFile

foreach ($File in $Files) {

    $File = $File.Trim()

    if ([string]::IsNullOrWhiteSpace($File)) {
        continue
    }

    $FullPath = Join-Path $ProjectRoot $File

    # Header
    $Header = @(
        "============================================================"
        "FILE: $File"
        "============================================================"
        ""
    )

    foreach ($Line in $Header) {

        if ($OutputLines.Count -ge $MaxLinesPerFile) {
            Save-Chunk $OutputLines $FileIndex

            $OutputLines.Clear()
            $FileIndex++
        }

        $OutputLines.Add($Line)
    }

    if (Test-Path $FullPath) {

        # Read file line-by-line
        $SourceLines = Get-Content $FullPath

        foreach ($Line in $SourceLines) {

            if ($OutputLines.Count -ge $MaxLinesPerFile) {
                Save-Chunk $OutputLines $FileIndex

                $OutputLines.Clear()
                $FileIndex++
            }

            $OutputLines.Add($Line)
        }
    }
    else {

        $MissingLine = "<< FILE NOT FOUND >>"

        if ($OutputLines.Count -ge $MaxLinesPerFile) {
            Save-Chunk $OutputLines $FileIndex

            $OutputLines.Clear()
            $FileIndex++
        }

        $OutputLines.Add($MissingLine)
    }

    # Separation between source files
    foreach ($Line in @("", "")) {

        if ($OutputLines.Count -ge $MaxLinesPerFile) {
            Save-Chunk $OutputLines $FileIndex

            $OutputLines.Clear()
            $FileIndex++
        }

        $OutputLines.Add($Line)
    }
}

# Save remaining lines
if ($OutputLines.Count -gt 0) {
    Save-Chunk $OutputLines $FileIndex
}

# ---------------------------------------------------------
# Copy all generated context files to clipboard
# ---------------------------------------------------------

$AllContext = Get-ChildItem -Path $ProjectRoot -Filter "context-*.txt" -File |
    Sort-Object Name |
    ForEach-Object {
        Get-Content $_.FullName -Raw
    }

$AllContext -join "`r`n" | Set-Clipboard

Write-Host ""
Write-Host "=========================================="
Write-Host "Done!"
Write-Host "Maximum lines per file: $MaxLinesPerFile"
Write-Host "Output files:"
Write-Host ""

Get-ChildItem -Path $ProjectRoot -Filter "context-*.txt" -File |
    Sort-Object Name |
    ForEach-Object {
        $LineCount = (Get-Content $_.FullName).Count
        Write-Host "  $($_.Name) -> $LineCount lines"
    }

Write-Host ""
Write-Host "All output copied to clipboard."
