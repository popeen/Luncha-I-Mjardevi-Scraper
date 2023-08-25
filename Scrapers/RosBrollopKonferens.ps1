# Import common code
if(-not $commonLoaded){
    . Luncha/common.ps1
}


# Set the ID used in the luncha database
$lunchaID = "23"

$source = Invoke-WebRequest -Uri "https://rosbrollop.se/restaurang-lunch/" -UseBasicParsing | Select -ExpandProperty Content
$source = [System.Web.HttpUtility]::HtmlDecode($source)

# No need to run the parser while they are closed
if($source -notlike "*Vi har stängt pga renovering*"){
    #Get the source for todays menu
    $sourceToday = Get-TextBetweenStrings -inputString $source -startString (Get-Weekday -language swe) -endString "<strong>" 

    # Prepare source for scraping
    $sourceToday = Remove-HtmlTags -inputString $sourceToday

    # Parse the menu to array
    $menuItems = $sourceToday.split("`n").trim()| Where-Object { $PSItem -ne "" }| ForEach-Object { (Get-Culture).TextInfo.ToTitleCase($PSItem) }

    # Scrape the website and add todays menu as an array to the $menu hashtable using $lunchaID as the key
    $menu["$lunchaID"] = $menuItems
}