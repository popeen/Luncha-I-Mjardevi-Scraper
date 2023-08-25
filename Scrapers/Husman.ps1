# Import common code
if(-not $commonLoaded){
    . Luncha/common.ps1
}

$lunchaID = "4"

$source = Invoke-WebRequest -Uri "https://restauranghusman.se/husman-lunch/" -UseBasicParsing | Select -ExpandProperty Content
$source = [System.Web.HttpUtility]::HtmlDecode($source)

if(-not ($source -like "*Kan inte hitta någon lunch*")){
    $daySource = Get-TextBetweenStrings -inputString $source -startString 'Dagens lunch</h2>' -endString 'default">Priser'

    # Cleanup strings
    $daySource = $daySource.Replace("Veg:", "")
    $daySource = $daySource.Replace("Grill:", "")
    $daySource = $daySource.Replace("Wok:", "Wokad")
    $daySource = $daySource.Replace("Pasta:", "Pasta")

    # Find all the menu items
    $pattern = '<[^>]*heading-title[^>]*>(.*?)<\/[^>]*>'
    $matches = [Regex]::Matches($daySource, $pattern)

    # Create a blank array for todays menu that we can populate in the loop below
    $menu["$lunchaID"] = @()

    foreach ($item in $matches) {

        $content = $item.Groups[1].Value

        [Int32]$OutNumber = $null # Dummy variable TryParse needs when checking if the string is an Integer
        if (
            -not [Int32]::TryParse($content, [ref]$OutNumber) -and # Half of the matches will always be the numbers displayed before the fooditem, we don't want these lines
            -not ($content -like "*Välkommen*") # Don't include the Välkommen line    
        ){

            # Grillen serverar includes several items comma separated, split them up
            if($content -like "Grillen serverar:*"){
                $content.Replace("Grillen serverar:", "").split(",")|ForEach-Object{
                    $menu["$lunchaID"] += $PSItem.trim()
                }
            }else{
                $menu["$lunchaID"] += $content.trim()
            }

        }

    }
}