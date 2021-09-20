<# 
Lo script trova l'elenco di tutti gli user 
e gruppi utilizzati negli entitlement di almeno un desktop pool

esempio d'uso:
.\find_all_users_and_group_in_desktop_pool_entitlement.ps1 


#>

#Ricava l'elenco dei desktop pool  e li salva in un file temporaneo
$all_pool = (get-hvpool).base.name > all_pool_name

#Per ogni desktop pool ricava l'elenco dei gruppi assegnati e li inserisce in un array
 foreach ($line in get-content .\all_pool_name) {

     $ent_group = get-hventitlement  -resourcetype desktop -resourcename $line

    $array = $array + $ent_group.base.name 

     
     }

$array = $array| select  -Unique |sort
Remove-item .\all_pool_name

# Organizza gli elementi dell'array in modo da ricavare una stringa utilizzabile per ricerche su user
foreach ($elem in $array) {
  if ($elem -match "^VDI" ) {$elenco_gruppi = $elem + "," + $elenco_gruppi}
  elseif ($elem -match "^Utenti") {}
   else {$elenco_user = $elem + "," + $elenco_user}
}
# visualizza i due elenchi: gruppi utilizzati negli entitlement e user assegnati direttamente
# agli entitlement
  $elenco_gruppi
  $elenco_user
