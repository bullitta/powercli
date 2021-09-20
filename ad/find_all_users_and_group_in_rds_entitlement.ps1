<# 
Lo script trova l'elenco di tutti gli user 
e gruppi utilizzati negli entitlement di almeno un applicazione

esempio d'uso:
.\find_all_users_and_group_in_rds_entitlement.ps1 


#>

#Ricava l'elenco delle applicazioni e le salva in un file temporaneo
$all_application = (get-hvapplication).data.name > all_app_name

#Per ogni applicazione ricava l'elenco dei gruppi e degli user assegnati e li inserisce in un array
 foreach ($line in get-content .\all_app_name) {

     $ent_group = get-hventitlement  -resourcetype application -resourcename $line

    $array = $array + $ent_group.base.loginname 

     
     }


$array = $array| select  -Unique |sort
Remove-Item .\all_app_name
# Organizza gli elementi dell'array in modo da ricavare una stringa utilizzabile per ricerche su user
foreach ($elem in $array) {
  if ($elem -match "^VDI") {$elenco_gruppi = $elem + "," + $elenco_gruppi}
  else {$elenco_user = $elem + "," + $elenco_user}
}
# visualizza i due elenchi: gruppi utilizzati negli entitlement e user assegnati direttamente
# agli entitlement
  $elenco_gruppi
  $elenco_user