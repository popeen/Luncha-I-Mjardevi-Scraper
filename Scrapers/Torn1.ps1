# Import common code
if(-not $commonLoaded){
    . Luncha/common.ps1
}

# Set the ID used in the luncha database
$lunchaID = "24"

# Get the menu image
$source = Invoke-WebRequest -Uri "https://torn1.se/meny/lunchmeny/" -UseBasicParsing | Select -ExpandProperty Content
$menuImage = Get-TextBetweenStrings -inputString $source -startString 'menu-img"> <a href="' -endString '"'

# Run OCR on the menu image
$ocrSource = Invoke-OcrOnlineImage -Language "swe" -Url $menuImage
$ocrSource = $ocrSource.replace("VECKANS DESSERT", "LÖRDAG");

# Get todays menu
$today = (Get-Weekday -Language "swe").toUpper()
$tommorow = (Get-Weekday -Language "swe" -tomorrow).toUpper()
$daySource = Get-TextBetweenStrings -inputString $ocrSource -startString "$today DEN" -endString $tommorow
$menuItems = Get-TextBetweenStringsAll -inputString $daySource -startString "-" -endString ".`r"

# Remove linebreaks
$menuItems = $menuItems|Foreach-Object{
    $item = $PSItem.replace("`r", "").replace("`n", " ")
    Set-FirstLetterCapital -String $item -LowerRest
}

# Add to the $menu hashtable
$menu["$lunchaID"] = $menuItems
