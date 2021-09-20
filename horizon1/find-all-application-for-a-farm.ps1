<# Ricava il nome di tutte le applicazioni con almeno un  entitlement

presenti su una farm

prende un unico parametro d'ingresso:

nome farm 

esempio di utilizzo

.\find-all-application-for-a-farm.ps1  -f poiu

#>
param ([Parameter(Mandatory)]$farm )



$farmid = (get-hvfarm -farmname $farm).id 

$applications = Get-HVApplication

foreach ($app in $applications) {
$farid = $app.executiondata.farm
if ($farid.id -eq $farmid.id) {
    $ent =  get-hventitlement -resourcetype application -resourcename $app.data.name -warningaction 0
    if ($ent ) {$active_app = $active_app + "," + $app.data.name}
    }

}

$active_app