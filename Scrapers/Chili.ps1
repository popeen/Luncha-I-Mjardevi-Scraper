# Import common code
if(-not $commonLoaded){
    . Luncha/common.ps1
}

# Set the ID used in the luncha database
$lunchaID = "2"

$source = Invoke-WebRequest -Uri "http://www.chili-lime.se/helaveckan.asp" -UseBasicParsing | Select -ExpandProperty Content
$source = [System.Web.HttpUtility]::HtmlDecode($source)
$source = $source.replace("Dagenstips", "Lördag");

# Cleanup the source
$toRemove = @('1.', '2.', '3.', '4.', '5.', '6.', '7.', '8.', '9.', '10.', 'A. ', 'B. ', 'A.', 'INDISK:', 'VEGAN: ', 'FISK: ', 'VEGETARISKT:', 'VEG', 'GRILL: ', '#8232;', '1:', '2:', '3:', '4:', '5:', '6:', '7:', '8:', '9:')
$toRemove | ForEach-Object{
    $source = $source.Replace($PSItem, "")
}

# Only get the menu for today
$sourceToday = Get-TextBetweenStrings -inputString $source -startString (Get-Weekday -language swe) -endString (Get-Weekday -language swe -tomorrow)

# Clear the array if another scraper has populated it
$menuItems = @()

# Parse the menu to array
$menuItems = (Get-TextBetweenStringsAll -inputString $sourceToday -startString "br>" -endString "<").trim()| Where-Object { $PSItem -ne "" }| ForEach-Object { (Get-Culture).TextInfo.ToTitleCase($PSItem) }


# Scrape the website and add todays menu as an array to the $menu hashtable using $lunchaID as the key
$menu["$lunchaID"] = $menuItems