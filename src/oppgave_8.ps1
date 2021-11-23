[CmdletBinding()]
param(
    [Parameter(HelpMessage = "URL til kortstokk", Mandatory = $false)]    
    [string]
    $UrlKortstokk = 'http://nav-deckofcards.herokuapp.com/shuffle'
)

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

function skrivUtResultat {
    [OutputType([String])]
    param (
        [object[]] $minKortstokk, [object[]] $magnusKortstokk, [string] $vinner
    )

    Write-Host "Kortstokk: $(kortstokkTilStreng -kortstokk ($meg + $magnus))"
    Write-Host "Poengsum: $(samletPoengsum -kortstokk ($meg + $magnus))"

    $minPoengsum = samletPoengsum -kortstokk $meg
    $magnusPoengsum = samletPoengsum -kortstokk $magnus
  
    if ($vinner) {
        Write-Host "Vinner: $vinner"
    }
    Write-Host ("{0,-8} | {1,-2} | {2,-15}" -f "Magnus", $magnusPoengsum, $(kortstokkTilStreng -kortstokk $magnus))
    Write-Host ("{0,-8} | {1,-2} | {2,-15}" -f "Meg", $minPoengsum, $(kortstokkTilStreng -kortstokk $meg))
    
}  



$ErrorActionPreference = 'Stop'
$webrequest = Invoke-WebRequest -Uri $UrlKortstokk 
$kortstokkJson = $webRequest.Content
$kortstokk = ConvertFrom-Json -InputObject $kortstokkJson

$meg = $kortstokk[0,1]
$kortstokk = $kortstokk[2..$kortstokk.Length]
$magnus = $kortstokk[0,1]
$kortstokk = $kortstokk[2..$kortstokk.Length]
$vinner = ""


$minPoengsum = samletPoengsum -kortstokk $meg
$magnusPoengsum = samletPoengsum -kortstokk $magnus

if (($magnusPoengsum -eq 21) -and ($minPoengsum -eq 21)) {
    $vinner = "Draw"
    break
}
elseif ($minPoengsum -eq 21) {
    $vinner = "meg"
    break
}
elseif ($magnusPoengsum -eq 21 ) {
    $vinner = "Magnus"
    break
}
else { # trekk kort
    while ($minPoengsum -le 17) {
        $meg += $kortstokk[0]
        $kortstokk = $kortstokk[1..$kortstokk.Length]
        $minPoengsum = samletPoengsum -kortstokk $meg

        if ($minPoengsum -eq 21) {
            $vinner = "meg"
            break
        }
        if ($minPoengsum -gt 21) {
            $vinner = "Magnus"
            break
        }
    }   
}   
       
skrivUtResultat -minKortstokk $meg -magnusKortstokk $magnus -vinner $vinner