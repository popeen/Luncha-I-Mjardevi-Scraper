# Import common code
Write-Host "Torn1 Start"
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
$ocrSource = $ocrSource -replace 'VECKA \d+', ''
$ocrSource = $ocrSource.Replace("MANDAG", "MÅNDAG")

# Get todays menu
$today = (Get-Weekday -Language "swe").toUpper()
$tommorow = (Get-Weekday -Language "swe" -tomorrow).toUpper()
$daySource = Get-TextBetweenStrings -inputString $ocrSource -startString "$today DEN" -endString $tommorow
$menuItems = Get-TextBetweenStringsAll -inputString $daySource -startString "-" -endString ".`r"

# Get todays veg menu
if(@("Måndag", "Tisdag").contains((Get-Weekday -Language "swe"))){
    $vegSource = Get-TextBetweenStrings -inputString $ocrSource -startString "NDAG-TISDAG" -endString "VEGETARISK"
    $menuItems += Get-TextBetweenStringsAll -inputString $vegSource -startString "-" -endString ".`r"
}
elseif(@("Onsdag", "Torsdag", "Fredag").contains((Get-Weekday -Language "swe"))){
    $vegSource = Get-TextBetweenStrings -inputString $ocrSource -startString "ONSDAG-FREDAG" -endString "NDAG"
    $menuItems += Get-TextBetweenStringsAll -inputString $vegSource -startString "-" -endString ".`r"
}

# Remove linebreaks
$menuItems = $menuItems|Foreach-Object{
    $item = $PSItem.replace("`r", "").replace("`n", " ").replace("/ ", ",")
    Set-FirstLetterCapital -String $item -LowerRest
}

# Add to the $menu hashtable
$menu["$lunchaID"] = @($menuItems)
Write-Host "Torn1 Stop"