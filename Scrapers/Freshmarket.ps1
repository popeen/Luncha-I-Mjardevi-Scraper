# Import common code
Write-Host "Freshmarket Start"
if(-not $commonLoaded){
    . Luncha/common.ps1
}

$lunchaID = "17"

$source = Invoke-WebRequest -Uri "https://freshmarket.ostgotakok.se/lunchmeny/" -UseBasicParsing | Select -ExpandProperty Content
$source = $source.Replace("<footer", "Lördag");

$week = Get-Date -UFormat %V
$weeksource = Get-TextBetweenStrings -inputString $source -startString "vecka $week" -endString "--footer"
$daySource = Get-TextBetweenStrings -inputString $weeksource -startString $(Get-Weekday -Language "swe") -endString $(Get-Weekday -Language "swe" -Tomorrow)
$menuItems = Get-TextBetweenStringsAll -inputString $daySource -startString "<strong>" -endString "</strong>"

# Create a blank array for todays menu that we can populate in the loop below
$menu["$lunchaID"] = @($menuItems.trim())
Write-Host "Freshmarket Stop"