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
        [object[]] $kortstokkStart, [object[]] $kortstokkRest, [object[]] $minKortstokk, [object[]] $magnusKortstokk, [string] $vinner
    )

    Write-Host "Kortstokk: $(kortstokkTilStreng -kortstokk $kortstokkStart)"
    Write-Host "Poengsum: $(samletPoengsum -kortstokk $kortstokkStart)"

    $minPoengsum = samletPoengsum -kortstokk $meg
    $magnusPoengsum = samletPoengsum -kortstokk $magnus
  
    if ($vinner) {
        Write-Host "Vinner: $vinner"
    }

    Write-Host ("{0,-8} | {1,-2} | {2,-15}" -f "Magnus", $magnusPoengsum, $(kortstokkTilStreng -kortstokk $magnus))
    Write-Host ("{0,-8} | {1,-2} | {2,-15}" -f "Meg", $minPoengsum, $(kortstokkTilStreng -kortstokk $meg))

    Write-Host "Kortstokk: $(kortstokkTilStreng -kortstokk $kortstokkRest)"
}  

function finnVinner {
    param (
        [object[]] $minKortstokk, [object[]] $magnusKortstokk
    )

    if (($magnusPoengsum -eq 21) -and ($minPoengsum -eq 21)) {
        return "Draw"
    }
    elseif ($minPoengsum -eq 21) {
        return "meg" 
    }
    elseif ($magnusPoengsum -eq 21 ) {
        return "Magnus"
    }
    elseif ($magnusPoengsum -gt 21 ) {
        return "meg"
    }
    elseif ($minPoengsum -gt 21 ) {
        return "Magnus"
    }
    return ""
}

$ErrorActionPreference = 'Stop'
$webrequest = Invoke-WebRequest -Uri $UrlKortstokk 
$kortstokkJson = $webRequest.Content
$kortstokk = ConvertFrom-Json -InputObject $kortstokkJson
$komplettKortstokk = $kortstokk
# Del ut kort
$meg = $kortstokk[0,1]
$kortstokk = $kortstokk[2..$kortstokk.Length]
$magnus = $kortstokk[0,1]
$kortstokk = $kortstokk[2..$kortstokk.Length]
$vinner = ""

$minPoengsum = samletPoengsum -kortstokk $meg
$magnusPoengsum = samletPoengsum -kortstokk $magnus

$vinner = finnVinner -minKortstokk $meg -magnusKortstokk $magnus

if (!$vinner) {
    while ($minPoengsum -lt 17) {
        $meg += $kortstokk[0]
        $kortstokk = $kortstokk[1..$kortstokk.Length]
        $minPoengsum = samletPoengsum -kortstokk $meg
    }   

    $vinner = finnVinner -minKortstokk $meg -magnusKortstokk $magnus

    if (!$vinner) {
        while ($magnusPoengsum -le $minPoengsum) {
            $magnus += $kortstokk[0]
            $kortstokk = $kortstokk[1..$kortstokk.Length]
            $magnusPoengsum = samletPoengsum -kortstokk $magnus
        }  
        $vinner = finnVinner -minKortstokk $meg -magnusKortstokk $magnus   
    }
}   
       
skrivUtResultat -kortstokkStart $komplettKortstokk -kortstokkRest $kortstokk -minKortstokk $meg -magnusKortstokk $magnus -vinner $vinner