param (
    [int]$Port = 8085
)

$workspace = $PSScriptRoot
$jars = @(
    "$workspace\work\.m2\org\apache\tomcat\embed\tomcat-embed-jasper\9.0.123\tomcat-embed-jasper-9.0.123.jar",
    "$workspace\work\.m2\org\apache\tomcat\embed\tomcat-embed-core\9.0.123\tomcat-embed-core-9.0.123.jar",
    "$workspace\work\.m2\org\apache\tomcat\tomcat-annotations-api\9.0.123\tomcat-annotations-api-9.0.123.jar",
    "$workspace\work\.m2\org\apache\tomcat\embed\tomcat-embed-el\9.0.123\tomcat-embed-el-9.0.123.jar",
    "$workspace\work\.m2\org\eclipse\jdt\ecj\3.26.0\ecj-3.26.0.jar"
) -join ";"

$cp = "$workspace\work\runtime\server\classes;$jars"
$app = "$workspace\target\AirlineProject-1.0-SNAPSHOT"
$base = "$workspace\work\runtime\server\tomcat-base"
New-Item -ItemType Directory -Path "$workspace\work\data" -Force | Out-Null
New-Item -ItemType Directory -Path $base -Force | Out-Null

$dbPath = "$workspace/work/data/airline".Replace('\', '/')
$env:AIRLINE_DB_URL = "jdbc:h2:file:$dbPath;AUTO_SERVER=TRUE;MODE=MySQL;DB_CLOSE_DELAY=-1"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Starting Geet Airlines Local Server      " -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "URL:      http://localhost:$Port/" -ForegroundColor Yellow
Write-Host "Database: H2 Embedded (file: $dbPath)" -ForegroundColor Gray
Write-Host "Admin:    Run .\make-admin.ps1 -Email <email>" -ForegroundColor Gray
Write-Host "Press Ctrl+C to stop the server.`n" -ForegroundColor DarkGray

java -cp $cp LocalTomcat $app $base $Port
