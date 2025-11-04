Write-Host "Testing PowerShell profile load time..." -ForegroundColor Cyan
Write-Host ""

$profilePath = Join-Path $PSScriptRoot "Microsoft.PowerShell_profile.ps1"

# Test 5 times and average
$times = @()
for ($i = 1; $i -le 5; $i++) {
    $time = Measure-Command {
        . $profilePath
    }
    $times += $time.TotalMilliseconds
    $roundedTime = [math]::Round($time.TotalMilliseconds, 2)
    Write-Host "Test ${i}: ${roundedTime}ms" -ForegroundColor Gray
}

$avgTime = ($times | Measure-Object -Average).Average
Write-Host ""
Write-Host "Average load time: $([math]::Round($avgTime, 2))ms" -ForegroundColor Green
Write-Host ""

if ($avgTime -lt 100) {
    Write-Host "Excellent! Profile loads in under 100ms" -ForegroundColor Green
} elseif ($avgTime -lt 200) {
    Write-Host "Good! Profile loads in under 200ms" -ForegroundColor Yellow
} else {
    Write-Host "Profile loads in over 200ms - consider further optimization" -ForegroundColor Red
}
