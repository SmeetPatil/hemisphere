param(
    [string]$BuildType = "apk",
    [switch]$Release
)

$pubspecPath = "pubspec.yaml"

# Read content
$content = Get-Content -Path $pubspecPath -Raw

# Find the version string (e.g. version: 1.0.0+1)
$match = [regex]::Match($content, '(?m)^version:\s*(\d+\.\d+\.\d+)\+(\d+)\r?$')

if ($match.Success) {
    $versionName = $match.Groups[1].Value
    $buildNumber = [int]$match.Groups[2].Value + 1
    
    $newVersion = "version: ${versionName}+${buildNumber}"
    $newContent = $content -replace '(?m)^version:\s*\d+\.\d+\.\d+\+\d+\r?$', $newVersion
    
    Set-Content -Path $pubspecPath -Value $newContent -NoNewline
    Write-Host "Successfully bumped version to ${versionName}+${buildNumber}" -ForegroundColor Green
} else {
    Write-Host "Could not find version pattern in pubspec.yaml. Skipping version bump." -ForegroundColor Yellow
}

# Run Flutter build
$buildCommand = "flutter build $BuildType"
if ($Release) {
    $buildCommand += " --release --obfuscate --split-debug-info=build/app/outputs/symbols"
} else {
    $buildCommand += " --debug"
}

Write-Host "Executing: $buildCommand" -ForegroundColor Cyan
Invoke-Expression $buildCommand