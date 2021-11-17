[CmdletBinding()]
param(
    [Parameter(HelpMessage = "URL til kortstokk", Mandatory = $false)]    
    [string]
    $UrlKortstokk = 'http://nav-deckofcards.herokuapp.com/shuffle'
)

$ErrorActionPreference = 'Stop'
$webrequest = Invoke-WebRequest -Uri $UrlKortstokk 
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

function samletPoengsum {    
    [OutputType([string])]
    param (
        [object[]]
        $kortstokk
    )
    $totalsum = 0
    
    foreach ($kort in $kortstokk) {
        $totalsum += switch ($kort.value) {
            'J' { 10 }
            'Q' { 10 }
            'K' { 10 }
            'A' { 11 }
            Default { $kort.value }
        }
    }
    return $totalsum
}
 
Write-Output "Kortstokk: $(kortstokkTilStreng -kortstokk $kortstokk)"
Write-Output "Poengsum: $(samletPoengsum -kortstokk $kortstokk)"