$ErrorActionPreference = 'Stop'

$webrequest = Invoke-WebRequest -Uri http://nav-deckofcards.herokuapp.com/shuffle
$kortstokkJson = $webRequest.Content

$kortstokk = ConvertFrom-Json -InputObject $kortstokkJson

#foreach ($kort in $kortstokk) {
#    Write-Output $kort
#}
#foreach ($kort in $kortstokk) {
#    Write-Output "$($kort.suit[0])+$($kort.value)"
#}

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