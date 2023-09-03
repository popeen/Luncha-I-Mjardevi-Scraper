# Import common code
if(-not $commonLoaded){
    . Luncha/common.ps1
}

# Set the ID used in the luncha database
$lunchaID = "13"


$source = Invoke-WebRequest -Uri "https://lafontanamjardevi.se/dagens-lunch/" -UseBasicParsing | Select -ExpandProperty Content
$source = [System.Web.HttpUtility]::HtmlDecode($source)

# Prepare source for parsing
$source = $source.replace("Lunchcatering", "Lördag");
$source = $source.replace('<p class="elementor-price-list-description">', "<br>")

# Only get the menu for today
$sourceToday = (Get-TextBetweenStrings -inputString $source -startString (Get-Weekday -language swe) -endString (Get-Weekday -language swe -tomorrow))

# Clear the array if another scraper has populated it
$menuItems = @()

# Parse the menu items
$menuItems = (Get-TextBetweenStringsAll -inputString $sourceToday -startString "<br>" -endString "`n").trim()| Where-Object { $PSItem -ne "" }| ForEach-Object { (Get-Culture).TextInfo.ToTitleCase($PSItem) }

# Scrape the website and add todays menu as an array to the $menu hashtable using $lunchaID as the key
$menu["$lunchaID"] = $menuItems