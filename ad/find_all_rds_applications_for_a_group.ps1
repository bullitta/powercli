<# 
Lo script trova l'elenco dei nomi delle applicazioni rds a cui un gruppo è stato abilitato

esempio d'uso:
.\find_all_rds_applications_for_a_group.ps1 -g as_group


#>
param ([Parameter(Mandatory)]$group)

#Ricava l'elenco delle applicazioni e le salva in un file temporaneo
$all_application = (get-hvapplication).data.name > all_app_name

#Per ogni applicazione ricava l'elenco dei gruppi assegnati e li confronta con $group
 foreach ($line in get-content .\all_app_name) {

     $ent_group = get-hventitlement  -resourcetype application -resourcename $line

     $ent_group.base.loginname > group

     foreach ($group_app in get-content .\group) {
     if ($group_app -eq $group) {write-host ("$line")}
     }


}
Remove-Item .\all_app_name
  Remove-Item .\group