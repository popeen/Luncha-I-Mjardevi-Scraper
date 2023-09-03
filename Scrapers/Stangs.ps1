# Import common code
if(-not $commonLoaded){
    . Luncha/common.ps1
}

# Set the ID used in the luncha database
$lunchaID = "20"

$date = get-date -format yyyy-MM-dd
$weekNumber = [System.Globalization.ISOWeek]::GetWeekOfYear($date)
$menuItems = @()

$rawItems = @()

# Meal of the day
$rawItems += Invoke-WebRequest -UseBasicParsing -Uri "https://db20.bokad.se/find" `
-Method "POST" `
-ContentType "application/json; charset=utf-8" `
-Body "{`"system`":`"stangs-mjardevi`",`"table`":`"mealofthedays`",`"condition`":{`"workday`":{`"`$gte`":`"$date`",`"`$lte`":`"$date`"}}}"| select -ExpandProperty content|ConvertFrom-Json


# Meal of the weeks
$rawItems += Invoke-WebRequest -UseBasicParsing -Uri "https://db20.bokad.se/find" `
-Method "POST" `
-ContentType "application/json" `
-Body "{`"system`":`"stangs-mjardevi`",`"table`":`"mealoftheweeks`",`"condition`":{`"weekNumber`":$weekNumber}}"|select -ExpandProperty content|ConvertFrom-Json

# Classic
# This should be updated to fetch the id from the page instead of being hardcoded, most likely would not update if more classics are added
$rawItems += Invoke-WebRequest -UseBasicParsing -Uri "https://db20.bokad.se/find" `
-Method "POST" `
-ContentType "application/json" `
-Body "{`"system`":`"stangs-mjardevi`",`"table`":`"products`",`"condition`":{`"id`":{`"`$in`":[`"724424a0-f7f8-4ecf-9569-9f828163ff66`"]}}}"|select -ExpandProperty content|ConvertFrom-Json|Where-Object{ $_.description -ne "" }


$rawItems|ForEach-Object{
    # Blank these just in case
    $name = $description = ""
    $name = ($PSItem.name).replace("`n", "").trim()
    $description = ($PSItem.description).replace("`n", "").trim()

    if( $name -notlike "*AVH*:*" -and $name -ne "" -and $description -ne ""){
        $menuItems += "$name - $description"
    }

}

$menuItems = ($menuItems | Select -Unique | ForEach-Object { (Get-Culture).TextInfo.ToTitleCase($PSItem.ToLower()) })

$menu["$lunchaID"] = $menuItems