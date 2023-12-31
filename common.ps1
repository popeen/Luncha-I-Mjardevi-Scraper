﻿# A common file that should be loaded at the top of all scrapers
Add-Type -AssemblyName System.Web

# Used so we only load it once
$commonLoaded = $true

#The hashtable that will contain all the menus when the scrapers are done
$menu = @{}

### Functions in alphabetical order below this line ###

function Get-TextBetweenStrings {
    param(
        [string]$inputString,
        [string]$startString,
        [string]$endString
    )

    $startIndex = $inputString.IndexOf($startString)
    $endIndex = $inputString.IndexOf($endString, $startIndex + $startString.Length)

    if ($startIndex -eq -1 -or $endIndex -eq -1) {
        return $null
    }

    $inputString.Substring($startIndex + $startString.Length, $endIndex - $startIndex - $startString.Length)

}


function Get-TextBetweenStringsAll {
    param (
        [string]$inputString,
        [string]$startString,
        [string]$endString
    )

    $startIndex = 0
    $matches = @()

    while ($startIndex -ne -1) {
        $startIndex = $inputString.IndexOf($startString, $startIndex)
        if ($startIndex -ne -1) {
            $startIndex += $startString.Length
            $endIndex = $inputString.IndexOf($endString, $startIndex)
            if ($endIndex -ne -1) {
                $matches += $inputString.Substring($startIndex, $endIndex - $startIndex)
                $startIndex = $endIndex + $endString.Length
            }
        }
    }

    $matches
}

function Get-Weekday{
    param(
        [ValidateSet("swe", "eng")]
        [string]$language = "swe",
        [switch]$tomorrow
    )
    
    $date = Get-Date
    
    if($tomorrow){
        $date = $date.AddDays(1)
    }
    
    $currentDayOfWeek = $date.DayOfWeek
    
    if($language -eq "eng"){
        return $currentDayOfWeek
    }
    else{
        switch ($currentDayOfWeek) {
            "Monday"    { "Måndag" }
            "Tuesday"   { "Tisdag" }
            "Wednesday" { "Onsdag" }
            "Thursday"  { "Torsdag" }
            "Friday"    { "Fredag" }
            "Saturday"  { "Lördag" }
            "Sunday"    { "Söndag" }
        }
    }

}

function Invoke-OcrOnlineImage{
    param(
        [ValidateSet("swe", "eng")]
        [String]$Language = "eng",
        [String]$Url
    )
    
    $ocrApiKey = $secret:API_KEY_OCR_SPACE

    $form = @{
        language = $Language
        url = $Url
    }
    
    return Invoke-RestMethod -Method Post -Uri "https://api.ocr.space/Parse/Image" -Headers @{apikey = $ocrApiKey} -Form $form | Select-Object -ExpandProperty ParsedResults | Select-Object -ExpandProperty ParsedText

}

function Remove-HtmlTags {
    param (
        [string]$inputString
    )
    
    $cleanedString = [Regex]::Replace($inputString, "<.*?>", "")
    return $cleanedString
}

function Set-FirstLetterCapital{
    param(
        [string]$string,
        [switch]$lowerRest
    )
    $firstLetter = $string.Substring(0,1).ToUpper()
    $restOfTheString = $string.Substring(1)

    if($lowerRest){ $restOfTheString = $restOfTheString.ToLower() }

    $($firstLetter + $restOfTheString)
}