param (
    [Parameter(Mandatory=$true)]
    [string]$Email
)

$workspace = $PSScriptRoot
$h2jar = "$workspace\work\.m2\com\h2database\h2\2.3.232\h2-2.3.232.jar"
$cp = "$workspace\work\runtime\server\classes;$h2jar"
$dbPath = "$workspace/work/data/airline".Replace('\', '/')
$dbUrl = "jdbc:h2:file:$dbPath;AUTO_SERVER=TRUE;MODE=MySQL;DB_CLOSE_DELAY=-1"

java -cp $cp MakeAdmin $dbUrl $Email
