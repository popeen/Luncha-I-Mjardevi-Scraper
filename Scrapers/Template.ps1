# Import common code
if(-not $commonLoaded){
    . Luncha/common.ps1
}

# Set the ID used in the luncha database
$lunchaID = "0"

# Scrape the website and add todays menu as an array to the $menu hashtable using $lunchaID as the key
$menu["$lunchaID"] = @("item1", "item2", "item3")