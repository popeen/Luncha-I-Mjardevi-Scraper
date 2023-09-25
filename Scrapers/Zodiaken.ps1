# Import common code
Write-Host "Zodiaken Start"
if(-not $commonLoaded){
    . Luncha/common.ps1
}

$lunchaID = "25"

$source = Invoke-WebRequest -Uri "https://www.hors.se/linkoping/17/3/zodiaken-asiatiska/" -UseBasicParsing | Select -ExpandProperty Content

$week = Get-Date -UFormat %V
$weeksource = Get-TextBetweenStrings -inputString $source -startString "menu-col" -endString "Menyn kan variera beroende"
$daySource = Get-TextBetweenStrings -inputString $weeksource -startString $(Get-Weekday -Language "swe") -endString "</div>"
$menuItems = Get-TextBetweenStringsAll -inputString $daySource -startString "<p>" -endString "</p>"

# Create a blank array for todays menu that we can populate in the loop below
$menu["$lunchaID"] = @($menuItems.trim())
Write-Host "Zodiaken Stop"