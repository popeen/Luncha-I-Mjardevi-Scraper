Write-Host "Brodernas Start"
if(-not $commonLoaded){
    . Luncha/common.ps1
}


# Set the ID used in the luncha database
$lunchaID = "1"

$source = Invoke-WebRequest -Uri "https://www.brodernaskok.se/meny" -UseBasicParsing | Select -ExpandProperty Content
$source = [System.Web.HttpUtility]::HtmlDecode($source)

#Get the source for todays menu
$lunchTodayTitle = Get-TextBetweenStrings -inputString $source -startString "$(Get-Weekday -language swe) l " -endString "</div>"
$lunchTodayDesc =  (Get-TextBetweenStrings -inputString $source -startString "$(Get-Weekday -language swe) l " -endString "</div>`n`n") -split 'description">' |Select -last 1

$menuItems = @("(Dagens) $lunchTodayTitle - $lunchTodayDesc")


# Get seasons menu
$sourceSeason = Get-TextBetweenStrings -inputString $source -startString 'title">Säsongens meny' -endString "menu-section"
$items = Get-TextBetweenStringsAll -inputString $sourceSeason -startString "price-top" -endString "price-bottom"

foreach($item in $items){

    # Blank out between items just in case
    $title = $description = ""

    $title = Get-TextBetweenStrings -inputString $item -startString 'title">' -endString '</div>'
    $description = Get-TextBetweenStrings -inputString $item -startString 'description">' -endString '</div>'
    $menuItems += @("$title - $description")
    
}


$menu["$lunchaID"] = $menuItems
Write-Host "Brodernas Stop"