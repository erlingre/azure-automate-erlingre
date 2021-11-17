[CmdletBinding()]
param(
    [Parameter(HelpMessage = "URL til kortstokk", Mandatory = $false)]    
    [string]
    $UrlKortstokk = 'http://nav-deckofcards.herokuapp.com/shuffle'
)

#$ErrorActionPreference = 'Stop'
$webrequest = Invoke-WebRequest -Uri $UrlKortstokk 

#try { 
#    $webrequest = Invoke-WebRequest -Uri $UrlKortstokk 
#}
# Todo: catch a specific exception.
#catch {
#   "An error occurred."
#   Exit 1
#}

$kortstokkJson = $webRequest.Content

$kortstokk = ConvertFrom-Json -InputObject $kortstokkJson

function kortstokkTilStreng {
    [OutputType([string])]
    param (
        [object[]]
        $kortstokk
    )
    $streng = ""
    foreach ($kort in $kortstokk) {
        $streng = $streng + "$($kort.suit[0])" + "$($kort.value[0])" + ","
    }
    return $streng.TrimEnd(',')
}

Write-Output "Kortstokk: $(kortstokkTilStreng -kortstokk $kortstokk)"
