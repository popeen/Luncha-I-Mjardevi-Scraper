# Import common code
if(-not $commonLoaded){
    . Luncha/common.ps1
}

$lunchaID = "11"

$source = Invoke-WebRequest -Uri "https://ellasrestaurang.se/dagens-lunch/" -UseBasicParsing | Select -ExpandProperty Content
$source = [System.Web.HttpUtility]::HtmlDecode($source)
$source = $source.Replace("Pris 1", "Lördag")

$daySource = Get-TextBetweenStrings -inputString $source -startString $(Get-Weekday -Language "swe") -endString $(Get-Weekday -Language "swe" -Tomorrow)
$menuItems = Get-TextBetweenStringsAll -inputString $daySource -startString "<b>" -endString "</b>"

# Create a blank array for todays menu that we can populate in the loop below
$menu["$lunchaID"] = $menuItems