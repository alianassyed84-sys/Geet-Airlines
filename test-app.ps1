# Self-check for Geet Airlines local server
param (
    [string]$BaseUrl = "http://localhost:8080"
)

try {
    $login = Invoke-WebRequest -Uri "$BaseUrl/login.jsp" -UseBasicParsing -TimeoutSec 5
    if ($login.StatusCode -ne 200) { throw "Login page returned status $($login.StatusCode)" }
    
    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $body = @{ email = "test@geetairlines.com"; password = "Password123!" }
    $homePage = Invoke-WebRequest -Uri "$BaseUrl/login" -Method Post -Body $body -WebSession $session -MaximumRedirection 5
    if ($homePage.StatusCode -ne 200 -or -not ($homePage.Content -match "GEET AIRLINES")) {
        throw "Home page verification failed"
    }

    $flights = Invoke-WebRequest -Uri "$BaseUrl/viewflights.jsp" -WebSession $session
    if ($flights.StatusCode -ne 200 -or -not ($flights.Content -match "Flight Booking")) {
        throw "View flights page verification failed"
    }

    Write-Host "[PASS] Geet Airlines server and database verified healthy at $BaseUrl" -ForegroundColor Green
    exit 0
} catch {
    Write-Host "[FAIL] Verification error: $_" -ForegroundColor Red
    exit 1
}
