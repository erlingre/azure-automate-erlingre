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
        $streng = $streng + "$($kort.suit[0])" + "$($kort.value)" + ","
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
 
Write-Host "Kortstokk: $(kortstokkTilStreng -kortstokk $kortstokk)"
Write-Host "Poengsum: $(samletPoengsum -kortstokk $kortstokk)"

$meg = $kortstokk[0,1]
$kortstokk = $kortstokk[2..$kortstokk.Length]
$magnus = $kortstokk[0,1]
$kortstokk = $kortstokk[2..$kortstokk.Length]

Write-Host "meg: $(kortstokkTilStreng -kortstokk $meg)"
Write-Host "magnus: $(kortstokkTilStreng -kortstokk $magnus)"
Write-Host "Kortstokk: $(kortstokkTilStreng -kortstokk $kortstokk)"
