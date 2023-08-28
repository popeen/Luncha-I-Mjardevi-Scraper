# Import common code
if(-not $commonLoaded){
    . Luncha/common.ps1
}


# Set the ID used in the luncha database
$lunchaID = "19"

$source = Invoke-WebRequest -Uri "https://sukaldari.se/" -UseBasicParsing | Select -ExpandProperty Content
$source = [System.Web.HttpUtility]::HtmlDecode($source)


# Get menu
$sourceMenu = Get-TextBetweenStrings -inputString $source -startString 'Glutenfri alternativ finns' -endString "et_pb_row_3"
$items = Get-TextBetweenStringsAll -inputString $sourceMenu -startString 'inner"><h' -endString "/p>"
$menuItems = @()
foreach($item in $items){

    # Blank out between items just in case
    $title = $description = ""

    $title = Get-TextBetweenStrings -inputString $item -startString '5>' -endString '</h5>'
    $description = Get-TextBetweenStrings -inputString $item -startString '<p>' -endString '<'
    $menuItems += @("$title - $description")

    
}

$menu["$lunchaID"] = $menuItems