<#
Query ansible tower for host by hostname using GetAnsTowerHost module

Adam Estabrook


#>

Import-Module -Force "./Get-TowerHost.psm1"

$tower = Read-Host "Enter Tower Server FQDN"
$newhostname = Read-Host "Enter hostname to query"
$newhost = Get-TowerHost( $tower )

# assign variable to json query data
$hostvarJson = $newhost.query( $newhostname )

# convert json query data in to an object, expanding to the results property
# this is so we can call $hostvarObj.id instead of $hostvarObj.results.id
#
$hostvarObj = ConvertFrom-Json -InputObject $hostvarJson | Select-Object -ExpandProperty results | Select-Object -Property id,name,created,inventory,enabled

# output important values
if($hostvarObj){
    foreach($hostvar in $hostvarObj){
        $hostvar
    }
}else {Write-Host $newhostname not managed by tower}
