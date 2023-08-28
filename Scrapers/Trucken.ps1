# Import common code
if(-not $commonLoaded){
    . Luncha/common.ps1
}


# Set the ID used in the luncha database
$lunchaID = "21"

$source = Invoke-WebRequest -Uri "https://www.trucken.nu/Meny" -UseBasicParsing | Select -ExpandProperty Content
$source = [System.Web.HttpUtility]::HtmlDecode($source)


# Get menu
$items = Get-TextBetweenStringsAll -inputString $source -startString '<li style="text-align: center;"><strong>' -endString "li>"
$menuItems = @()
foreach($item in $items){

    # Blank out between items just in case
    $title = $description = ""

    $title = Get-TextBetweenStrings -inputString $item -startString '. ' -endString '</strong>'
    $description = Get-TextBetweenStrings -inputString $item -startString '<br />' -endString '</'
    $menuItems += @("$title - $description")

    
}

$menu["$lunchaID"] = $menuItems