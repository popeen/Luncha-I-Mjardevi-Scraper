# Import common code
Write-Host "PegsTails Start"
if(-not $commonLoaded){
    . Luncha/common.ps1
}

# Set the ID used in the luncha database
$lunchaID = "22"

$source = Invoke-WebRequest -Uri "https://www.pegsandtails.se/lunch/" -UseBasicParsing | Select -ExpandProperty Content
$source = [System.Web.HttpUtility]::HtmlDecode($source)

# Prepare source for scraping
$source = $source.Replace("Se helgens luncher", "Lördag")

# Scrape the weekly items
$dailyDriveAndWeeklySource = Get-TextBetweenStrings -inputString $source -startString "Dagens drive" -endString "hela veckans meny"
$food = Get-TextBetweenStringsAll -inputString $dailyDriveAndWeeklySource -startString "meny-titel" -endString "meny-allergi"

$menuItems = $food | ForEach-Object{ 
    $array = Get-TextBetweenStringsAll -inputString $PSItem -startString '<div class="elementor-shortcode">' -endString '</div>'
    $title = $array[0]
    $desc = $array[2]

    # We clean out some none items that happens sometimes
    if( -not ($title -eq "" -or $title -eq "-" -or $title -eq $null -or $title -like "*:-*")){
        
        # Format the return string so it has title and desc according to how Luncha handles it internally
        "$title - $desc"

    }
} 

# Scrape daily item
$sourceToday = Get-TextBetweenStrings -inputString $source -startString (Get-Weekday -language swe) -endString (Get-Weekday -language swe -tomorrow)
$todayFoodItem = Get-TextBetweenStringsAll -inputString $sourceToday -startString '<div class="elementor-shortcode">' -endString '</div>'
$menuItems += "$($todayFoodItem[0]) - $($todayFoodItem[1])"

# Scrape the website and add todays menu as an array to the $menu hashtable using $lunchaID as the key
$menu["$lunchaID"] = $menuItems
Write-Host "PegsTails Stop"