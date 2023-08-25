# Run all scrapers
Get-ChildItem Luncha/Scrapers | ForEach-Object { if($PSItem.Name -notlike "*Template*"){ . $PSItem.FullName } }

# Return the menu
$menu

# Push to Luncha Database, this file is confidential and not included in git
. Luncha/PushToDB.ps1