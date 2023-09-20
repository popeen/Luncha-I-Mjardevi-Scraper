# Import common code
if(-not $commonLoaded){
    . Luncha/common.ps1
}

$lunchaID = "18"

if($(Get-Weekday -Language "swe") -ne "Måndag"){
    $source = Invoke-WebRequest -Uri "https://www.gastromix.se/lunch/" -UseBasicParsing | Select -ExpandProperty Content
    $menuSource = Get-TextBetweenStrings -inputString $source -startString "Take away från" -endString "</div>"
    $menuItems = Get-TextBetweenStringsAll -inputString $menuSource -startString "<strong>" -endString "</strong>"

    $menuItems = $menuItems|ForEach-Object{
        ($PSItem.split("(")|Select-Object -First 1).trim()
    }
    # Create a blank array for todays menu that we can populate in the loop below
    $menu["$lunchaID"] = $menuItems
}